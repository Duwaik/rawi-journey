import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/debug_log_service.dart';
import '../services/prefs_service.dart';

/// B27: Global floating debug panel shown on ALL screens during testing.
///
/// - Tiny FAB in the bottom-leading corner (language-aware).
/// - Visible only when [PrefsService.isDebugOverlayEnabled] is true.
/// - Tap opens a full log panel with category filters + copy action.
/// - Keep enabled until launch, then disable for production via pref.
class DebugReporterOverlay extends StatefulWidget {
  final Widget child;
  const DebugReporterOverlay({super.key, required this.child});

  @override
  State<DebugReporterOverlay> createState() => _DebugReporterOverlayState();
}

class _DebugReporterOverlayState extends State<DebugReporterOverlay> {
  bool _panelOpen = false;

  void _onLogUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    DebugLogService.addListener(_onLogUpdate);
  }

  @override
  void dispose() {
    DebugLogService.removeListener(_onLogUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!PrefsService.isDebugOverlayEnabled) {
      return widget.child;
    }
    return Stack(
      children: [
        widget.child,
        // Floating FAB — opens panel
        if (!_panelOpen)
          Positioned(
            bottom: 24,
            left: 12,
            child: GestureDetector(
              onTap: () => setState(() => _panelOpen = true),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withAlpha(170),
                  border: Border.all(color: Colors.white70, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${DebugLogService.entries.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        if (_panelOpen) _buildPanel(),
      ],
    );
  }

  Widget _buildPanel() {
    final entries = DebugLogService.entries.reversed.toList();
    return Positioned.fill(
      child: Material(
        color: Colors.black.withAlpha(230),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Row(
                  children: [
                    const Icon(Icons.bug_report,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text('Debug Log (${entries.length})',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Copy',
                      icon: const Icon(Icons.copy, color: Colors.white70),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: DebugLogService.exportText()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Log copied'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.white70),
                      onPressed: () => DebugLogService.clear(),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => setState(() => _panelOpen = false),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'No events logged yet',
                          style: GoogleFonts.nunito(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        itemCount: entries.length,
                        separatorBuilder: (c, i) =>
                            const Divider(color: Colors.white10, height: 12),
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _categoryColor(e.category)
                                      .withAlpha(80),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  e.category,
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.message,
                                      style: GoogleFonts.robotoMono(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTime(e.time),
                                      style: GoogleFonts.robotoMono(
                                        color: Colors.white54,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              // Footer: hint
              Container(
                color: Colors.white10,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                child: Text(
                  'Toggle in Settings → About → triple-tap version',
                  style: GoogleFonts.nunito(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'hotspot':
        return Colors.orange;
      case 'video':
        return Colors.redAccent;
      case 'nav':
        return Colors.blueAccent;
      case 'state':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static String _formatTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${t.millisecond.toString().padLeft(3, '0')}';
  }
}
