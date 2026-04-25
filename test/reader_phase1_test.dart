// R28 S3 Phase 1 widget tests.
//
// Covers the four required surfaces from §9 of the Phase 1 spec:
//   • EN char-by-char reveal completes
//   • AR word-by-word reveal completes (no glyph-split crash)
//   • controller.completeNow() snaps text and fires onComplete
//   • ReaderBottomCard horizontal swipe advances the page index
//
// Visual fidelity (e.g. AR letter-joins, ink-bloom alpha, cursor pulse)
// is not asserted here — those are device-judged on A56. These tests
// assert the lifecycle/state contract that the Reader card depends on.
//
// Implementation note: the ManuscriptWritingText ticker fires on every
// pumped frame, and pumpAndSettle would loop forever waiting for the
// ticker to stop. All tests drive the widget with explicit pump loops
// rather than pumpAndSettle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rawi/app_colors.dart';
import 'package:rawi/models/scene_config.dart';
import 'package:rawi/widgets/reader/manuscript_writing_text.dart';
import 'package:rawi/widgets/reader/reader_bottom_card.dart';

/// Pump a sequence of small frames so per-frame Tickers actually fire.
/// One big tester.pump(5s) only fires a Ticker once with elapsed=5s,
/// which doesn't allow the widget's "hold one ink-bloom window after
/// the last unit revealed" deadline to be reached on the next frame.
Future<void> pumpFrames(
  WidgetTester tester, {
  required int totalMs,
  int stepMs = 60,
  bool Function()? until,
}) async {
  final steps = (totalMs / stepMs).ceil();
  for (int i = 0; i < steps; i++) {
    await tester.pump(Duration(milliseconds: stepMs));
    if (until != null && until()) return;
  }
}

void main() {
  group('ManuscriptWritingText — reveal lifecycle', () {
    testWidgets('EN char-by-char reveal completes and fires onComplete',
        (tester) async {
      var completed = false;
      const text = 'Hello, world.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManuscriptWritingText(
              text: text,
              isAr: false,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      // Worst-case duration: 13 chars × 35 ms + 500 ms (comma) +
      // 900 ms (period) + 80 ms initial + 150 ms completion buffer
      // ≈ 2.1 s. Use 6 s window to leave generous margin.
      await pumpFrames(tester, totalMs: 6000, until: () => completed);

      expect(completed, isTrue,
          reason: 'EN reveal should complete within 6 s of pumped frames');
    });

    testWidgets('AR word-by-word reveal completes (no letter-split crash)',
        (tester) async {
      var completed = false;
      // 2 AR words including punctuation; whitespace attaches to
      // preceding word so unit count = 2.
      const text = 'السلام، عليكم.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: ManuscriptWritingText(
                text: text,
                isAr: true,
                textDirection: TextDirection.rtl,
                onComplete: () => completed = true,
              ),
            ),
          ),
        ),
      );

      // 2 words × 130 ms base + 500 ms comma + 900 ms period + 80 ms
      // initial + 150 ms buffer ≈ 1.8 s. Use 5 s window.
      await pumpFrames(tester, totalMs: 5000, until: () => completed);

      expect(completed, isTrue,
          reason: 'AR reveal should complete within 5 s of pumped frames');
    });

    testWidgets('controller.completeNow() snaps text and fires onComplete',
        (tester) async {
      var completed = false;
      final controller = ManuscriptWritingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManuscriptWritingText(
              // Long-enough text that natural completion would not
              // happen within our short pump window — completeNow() is
              // the only path that finishes within this test.
              text:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing '
                  'elit, sed do eiusmod tempor incididunt ut labore et '
                  'dolore magna aliqua.',
              isAr: false,
              controller: controller,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      // Animation in flight, not yet complete.
      await tester.pump(const Duration(milliseconds: 200));
      expect(completed, isFalse);
      expect(controller.isComplete, isFalse);

      // Force completion.
      controller.completeNow();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(completed, isTrue,
          reason:
              'controller.completeNow() should fire onComplete synchronously');
      expect(controller.isComplete, isTrue);
    });

    testWidgets('completeNow is idempotent (post-completion calls are no-ops)',
        (tester) async {
      var completeCount = 0;
      final controller = ManuscriptWritingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManuscriptWritingText(
              text: 'Short.',
              isAr: false,
              controller: controller,
              onComplete: () => completeCount++,
            ),
          ),
        ),
      );

      controller.completeNow();
      await tester.pump();
      controller.completeNow();
      controller.completeNow();
      await tester.pump(const Duration(milliseconds: 100));

      expect(completeCount, 1,
          reason:
              'onComplete must fire exactly once even after multiple '
              'completeNow calls');
    });
  });

  group('ReaderBottomCard — page navigation', () {
    SceneHotspot makeHotspot(int i) => SceneHotspot(
          id: 'h$i',
          x: 0.5,
          y: 0.5,
          label: 'Hotspot $i',
          labelAr: 'موقع $i',
          fragment: 'Hotspot $i fragment.',
          fragmentAr: 'فقرة الموقع $i.',
        );

    /// Find the 4 page-dot AnimatedContainers (6×6 squares inside the
    /// dot row). Predicate: tightly-bounded constraints to width/height
    /// = 6. Returns dots in render order.
    Finder findDots() {
      return find.byWidgetPredicate((w) {
        if (w is! AnimatedContainer) return false;
        final c = w.constraints;
        if (c == null) return false;
        return c.minWidth == 6 &&
            c.maxWidth == 6 &&
            c.minHeight == 6 &&
            c.maxHeight == 6;
      });
    }

    Color? dotColor(WidgetTester tester, Finder finder, int idx) {
      final w = tester.widget<AnimatedContainer>(finder.at(idx));
      final dec = w.decoration;
      if (dec is BoxDecoration) return dec.color;
      return null;
    }

    testWidgets('all 4 page dots render with correct initial gold accent',
        (tester) async {
      final hotspots = List.generate(4, makeHotspot);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: ReaderBottomCard(hotspots: hotspots, isAr: false),
            ),
          ),
        ),
      );

      // Pump through the 1 s establishing beat + first reveal frames.
      await pumpFrames(tester, totalMs: 1200);

      final dots = findDots();
      expect(dots, findsNWidgets(4));

      expect(dotColor(tester, dots, 0), AppColors.gold,
          reason: 'page 0 dot should be gold accent on open');
      for (int i = 1; i < 4; i++) {
        expect(dotColor(tester, dots, i), isNot(AppColors.gold),
            reason: 'non-current dot $i should be muted, not gold');
      }
    });

    testWidgets('horizontal fling advances current page (LTR forward)',
        (tester) async {
      final hotspots = List.generate(4, makeHotspot);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: ReaderBottomCard(hotspots: hotspots, isAr: false),
            ),
          ),
        ),
      );

      // Settle past the establishing beat.
      await pumpFrames(tester, totalMs: 1200);

      // Sanity — page 0 dot starts gold, page 1 dot is muted.
      final dots = findDots();
      expect(dotColor(tester, dots, 0), AppColors.gold);
      expect(dotColor(tester, dots, 1), isNot(AppColors.gold));

      // Fling forward — left in LTR. Velocity 1500 px/s.
      final scrollable = find
          .descendant(
            of: find.byType(PageView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.fling(scrollable, const Offset(-500, 0), 1500);

      // Drive the PageView slide animation (250 ms) through enough
      // frames for the controller listener to fire and the dot's
      // AnimatedContainer to swap colors. 600 ms of pumped frames is
      // a comfortable margin.
      await pumpFrames(tester, totalMs: 600);

      final dotsAfter = findDots();
      expect(dotColor(tester, dotsAfter, 0), isNot(AppColors.gold),
          reason: 'after forward fling, page 0 dot should no longer be gold');
      expect(dotColor(tester, dotsAfter, 1), AppColors.gold,
          reason: 'after forward fling, page 1 dot should be gold accent');
    });
  });
}
