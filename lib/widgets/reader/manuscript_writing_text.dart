import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

import '../../services/debug_log_service.dart';
import '../../services/prefs_service.dart';

/// R28 S3-P1-03 · Manuscript-style writing animation widget.
///
/// Self-contained, importable. Public API:
///
///   • [text]      — the string to reveal.
///   • [isAr]      — true for Arabic word-by-word; false for EN char-by-char.
///                   Char-by-char in AR breaks letter connections — DO NOT.
///   • [textStyle] — caller-supplied typography (Aref Ruqaa for AR, italic
///                   serif for EN).
///   • [textAlign] / [textDirection] — caller controls layout direction.
///   • [onComplete] — fired once when the reveal is fully done (natural
///                    completion OR after [ManuscriptWritingController.completeNow]).
///   • [controller] — optional [ManuscriptWritingController] exposing
///                    [ManuscriptWritingController.completeNow] for tap-to-skip
///                    (R28 S3-P1-06).
///
/// Reveal pattern:
///   • EN: each character is a unit. Base cadence 35 ms; `,`/`;`/`:`
///     hold 500 ms; `.`/`?`/`!` hold 900 ms.
///   • AR: each whitespace-separated word is a unit. Base cadence 130 ms;
///     trailing `،`/`؛` 500 ms; trailing `.`/`؟`/`!` 900 ms. Words are
///     never split internally so glyph clusters stay intact.
///
/// Per revealed unit: an ~100 ms ink-bloom fade from alpha 0 → 1, driven
/// off the same Ticker as the reveal pacing.
///
/// A pen-nib cursor (inline `▎` glyph, pulsing alpha) tracks the current
/// write position. Visible during the animation, hidden after completion.
///
/// Quill audio: tries to play `assets/audio/sfx/quill_writing_loop.mp3`
/// at volume 0.22 in a private [AudioPlayer] (no shared state in
/// AudioService — keeps blast radius minimal). On asset-missing the
/// player swallows the failure and the widget continues silently with a
/// debug log entry. Respects [PrefsService.sfxEnabled]. Ducks to 0
/// immediately on [completeNow]; fades out over 200 ms on natural
/// completion.
class ManuscriptWritingText extends StatefulWidget {
  final String text;
  final bool isAr;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final VoidCallback? onComplete;
  final ManuscriptWritingController? controller;

  /// R28-RFT-02 · optional scroll-follow. When the caller's page text
  /// can overflow the viewport, pass the SAME [ScrollController] that
  /// drives the enclosing scrollable (do NOT add a second one — the
  /// spec's diagnostic-first note). While revealing, the widget keeps
  /// the write cursor near viewport-centre by animating this
  /// controller. Null → no scroll-follow (short pages, or callers that
  /// don't scroll).
  final ScrollController? followController;

  const ManuscriptWritingText({
    super.key,
    required this.text,
    required this.isAr,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.onComplete,
    this.controller,
    this.followController,
  });

  @override
  State<ManuscriptWritingText> createState() => _ManuscriptWritingTextState();
}

/// External controller — pass into [ManuscriptWritingText.controller] to
/// trigger [completeNow] from a tap handler higher up the tree.
class ManuscriptWritingController {
  _ManuscriptWritingTextState? _state;

  void _attach(_ManuscriptWritingTextState s) => _state = s;
  void _detach(_ManuscriptWritingTextState s) {
    if (_state == s) _state = null;
  }

  bool get isComplete => _state?._completed ?? false;

  void completeNow() => _state?.completeNow();
}

class _Unit {
  final String text;
  final int nextDelayMs;
  Duration? revealedAt;
  _Unit(this.text, this.nextDelayMs);
}

class _ManuscriptWritingTextState extends State<ManuscriptWritingText>
    with SingleTickerProviderStateMixin {
  // Cadence values — tuned to spec.
  static const int _baseEnCharMs = 35;
  static const int _baseArWordMs = 130;
  static const int _commaMs      = 500;
  static const int _periodMs     = 900;
  static const int _inkBloomMs   = 100;
  static const int _initialDelayMs = 80;
  static const String _quillAsset = 'assets/audio/sfx/quill_writing_loop.mp3';

  late Ticker _ticker;
  late List<_Unit> _units;
  int _revealedCount = 0;
  Duration _now = Duration.zero;
  Duration _nextRevealAt = const Duration(milliseconds: _initialDelayMs);
  Duration? _naturalCompletionAt;
  bool _completed = false;

  AudioPlayer? _quill;

  @override
  void initState() {
    super.initState();
    _units = _splitText(widget.text, widget.isAr);
    _ticker = createTicker(_onTick);
    widget.controller?._attach(this);
    if (_units.isEmpty) {
      // Empty text → instant completion, no ticker, no audio.
      _completed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onComplete?.call();
      });
      return;
    }
    _ticker.start();
    _startQuillAudio();
  }

  @override
  void didUpdateWidget(covariant ManuscriptWritingText old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (old.text != widget.text || old.isAr != widget.isAr) {
      _resetForNewText();
    }
  }

  void _resetForNewText() {
    _stopQuillImmediate();
    if (_ticker.isActive) _ticker.stop();
    _ticker.dispose();
    _ticker = createTicker(_onTick);
    _units = _splitText(widget.text, widget.isAr);
    _revealedCount = 0;
    _now = Duration.zero;
    _nextRevealAt = const Duration(milliseconds: _initialDelayMs);
    _naturalCompletionAt = null;
    _completed = false;
    if (_units.isEmpty) {
      _completed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onComplete?.call();
      });
      return;
    }
    _ticker.start();
    _startQuillAudio();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    if (_ticker.isActive) _ticker.stop();
    _ticker.dispose();
    _stopQuillImmediate();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _now = elapsed;
    if (_completed) return;

    // Cumulative scheduling: advance _nextRevealAt by each unit's
    // nextDelayMs from its OWN scheduled deadline (not from _now). If
    // a frame is late (or a test pumps a large interval at once),
    // multiple units catch up in a single frame instead of stalling
    // one-per-frame.
    while (_revealedCount < _units.length && _now >= _nextRevealAt) {
      _units[_revealedCount].revealedAt = _now;
      final justRevealed = _units[_revealedCount];
      _revealedCount++;
      _nextRevealAt = _nextRevealAt +
          Duration(milliseconds: justRevealed.nextDelayMs);
    }

    if (_revealedCount >= _units.length) {
      // Hold for one ink-bloom window after the last unit is revealed
      // so its fade-in plays through before we fire onComplete.
      _naturalCompletionAt ??=
          _now + const Duration(milliseconds: _inkBloomMs + 50);
      if (_now >= _naturalCompletionAt!) {
        _completeInternal(natural: true);
        return;
      }
    }

    _maybeFollowCursor();
    setState(() {});
  }

  /// R28-RFT-02 · keep the write cursor near viewport-centre while
  /// revealing. The full text is laid out from frame 1 (un-revealed
  /// units are opacity-0 spans, not unmounted), so the scroll content
  /// height is constant and the cursor's Y is well-approximated by the
  /// reveal fraction × content height — robust across EN char-by-char,
  /// AR word-by-word, and mixed spans, with no costly per-tick
  /// TextPainter remeasure (reasoned deviation from the spec's
  /// "rendered text up to cursor index"; flagged in handoff).
  ///
  /// Forward-only and epsilon-throttled: never yanks the view back up
  /// mid-type, and only re-animates when the target moves a meaningful
  /// amount — so `animateTo` doesn't fire every 35 ms EN char. Stops
  /// firing once `_completed`, so the reader can freely scroll back to
  /// re-read (spec acceptance 3). On page swipe the caller rebuilds a
  /// fresh page+controller (keyed by hotspot id) → next page at top.
  void _maybeFollowCursor() {
    final ctrl = widget.followController;
    if (ctrl == null || _completed || _units.isEmpty) return;
    if (!ctrl.hasClients) return;
    final pos = ctrl.position;
    // Page shorter than viewport → nothing to follow (spec: pages that
    // don't overflow trigger no scroll at all).
    if (pos.maxScrollExtent <= 0) return;
    final double content = pos.maxScrollExtent + pos.viewportDimension;
    final double frac = _revealedCount / _units.length;
    final double cursorY = content * frac;
    final double target =
        (cursorY - pos.viewportDimension / 2).clamp(0.0, pos.maxScrollExtent);
    // Forward-only + 4px epsilon: smooth follow, no jitter, no fight
    // with a reader who scrolled up.
    if (target <= pos.pixels + 4.0) return;
    ctrl.animateTo(
      target,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  /// Public — called by [ManuscriptWritingController.completeNow].
  void completeNow() {
    if (_completed) return;
    final flashAt = _now - const Duration(milliseconds: _inkBloomMs);
    for (int i = _revealedCount; i < _units.length; i++) {
      _units[i].revealedAt = flashAt;
    }
    _revealedCount = _units.length;
    _completeInternal(natural: false);
  }

  void _completeInternal({required bool natural}) {
    _completed = true;
    if (_ticker.isActive) _ticker.stop();
    if (natural) {
      _fadeOutQuill(const Duration(milliseconds: 200));
    } else {
      _stopQuillImmediate();
    }
    widget.onComplete?.call();
    if (mounted) setState(() {});
  }

  // ── Text splitting ─────────────────────────────────────────────────

  static List<_Unit> _splitText(String text, bool isAr) {
    if (text.isEmpty) return const [];
    return isAr ? _splitArWords(text) : _splitEnChars(text);
  }

  static List<_Unit> _splitEnChars(String text) {
    final out = <_Unit>[];
    final runes = text.runes.toList();
    for (int i = 0; i < runes.length; i++) {
      final ch = String.fromCharCode(runes[i]);
      out.add(_Unit(ch, _delayForChar(ch)));
    }
    return out;
  }

  /// AR word splitter — preserves whitespace as part of the preceding word
  /// so layout doesn't change between reveals. Punctuation attached to a
  /// word triggers cadence on that word.
  static List<_Unit> _splitArWords(String text) {
    final out = <_Unit>[];
    final ws = RegExp(r'\s+');
    int i = 0;
    while (i < text.length) {
      // skip leading whitespace into the previous unit if any
      if (ws.hasMatch(text[i]) && out.isNotEmpty) {
        // attach contiguous whitespace to last unit
        int j = i;
        while (j < text.length && ws.hasMatch(text[j])) {
          j++;
        }
        final last = out.removeLast();
        out.add(_Unit(last.text + text.substring(i, j), last.nextDelayMs));
        i = j;
        continue;
      }
      // read word until next whitespace
      int j = i;
      while (j < text.length && !ws.hasMatch(text[j])) {
        j++;
      }
      final word = text.substring(i, j);
      out.add(_Unit(word, _delayForArWord(word)));
      i = j;
    }
    return out;
  }

  static int _delayForChar(String ch) {
    switch (ch) {
      case ',': case ';': case ':':
      case '،': case '؛':
        return _commaMs;
      case '.': case '?': case '!':
      case '؟':
        return _periodMs;
      default:
        return _baseEnCharMs;
    }
  }

  static int _delayForArWord(String word) {
    if (word.isEmpty) return _baseArWordMs;
    final last = word[word.length - 1];
    if (last == '،' || last == '؛' || last == ',' || last == ';' || last == ':') {
      return _commaMs;
    }
    if (last == '؟' || last == '?' || last == '.' || last == '!') {
      return _periodMs;
    }
    return _baseArWordMs;
  }

  // ── Quill audio (private to this widget) ───────────────────────────

  Future<void> _startQuillAudio() async {
    if (!PrefsService.sfxEnabled) return;
    if (_quill != null) return;
    final p = AudioPlayer();
    try {
      await p.setAsset(_quillAsset);
      await p.setLoopMode(LoopMode.all);
      await p.setVolume(0.22);
      // ignore: discarded_futures — fire-and-forget play
      p.play();
      _quill = p;
    } catch (e) {
      DebugLogService.log('audio',
          'quill_writing_loop missing — silent fallback ($e)');
      try {
        await p.dispose();
      } catch (_) {}
    }
  }

  Future<void> _fadeOutQuill(Duration dur) async {
    final p = _quill;
    if (p == null) return;
    _quill = null;
    const steps = 10;
    final stepDur =
        Duration(milliseconds: (dur.inMilliseconds / steps).round());
    final initial = p.volume;
    for (int i = 1; i <= steps; i++) {
      if (!mounted) break;
      final v = initial * (1 - i / steps);
      try {
        await p.setVolume(v);
      } catch (_) {}
      await Future<void>.delayed(stepDur);
    }
    try {
      await p.stop();
    } catch (_) {}
    try {
      await p.dispose();
    } catch (_) {}
  }

  void _stopQuillImmediate() {
    final p = _quill;
    if (p == null) return;
    _quill = null;
    () async {
      try {
        await p.setVolume(0);
      } catch (_) {}
      try {
        await p.stop();
      } catch (_) {}
      try {
        await p.dispose();
      } catch (_) {}
    }();
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        widget.textStyle ?? DefaultTextStyle.of(context).style;
    final inkColor = defaultStyle.color ?? const Color(0xFF1A1611);

    final spans = <InlineSpan>[];
    for (int i = 0; i < _units.length; i++) {
      final u = _units[i];
      double opacity;
      if (u.revealedAt == null) {
        opacity = 0.0;
      } else {
        final since = (_now - u.revealedAt!).inMilliseconds;
        opacity = (since / _inkBloomMs).clamp(0.0, 1.0).toDouble();
      }
      // Insert pen-nib cursor at the current write position (after the
      // last revealed unit, before the next un-revealed one).
      if (!_completed && i == _revealedCount && _revealedCount > 0) {
        spans.add(_buildCursorSpan(inkColor, defaultStyle));
      }
      spans.add(TextSpan(
        text: u.text,
        style: defaultStyle.copyWith(
          color: inkColor.withAlpha((opacity * 255).round()),
        ),
      ));
    }
    // Trailing cursor if all units revealed but completion hasn't fired.
    if (!_completed &&
        _revealedCount == _units.length &&
        _units.isNotEmpty) {
      spans.add(_buildCursorSpan(inkColor, defaultStyle));
    }

    return Text.rich(
      TextSpan(children: spans, style: defaultStyle),
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
    );
  }

  InlineSpan _buildCursorSpan(Color inkColor, TextStyle baseStyle) {
    // Pulse alpha 0.4 → 1.0 → 0.4 over 800 ms via abs(sin).
    final pulseT = (_now.inMilliseconds % 800) / 800.0;
    final pulseAlpha = 0.4 + 0.6 * math.sin(pulseT * math.pi).abs();
    return TextSpan(
      text: '▎',
      style: baseStyle.copyWith(
        color: inkColor.withAlpha((pulseAlpha * 255).round()),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
