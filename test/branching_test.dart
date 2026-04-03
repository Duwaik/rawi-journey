import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawi/models/journey_event.dart';
import 'package:rawi/models/branch_point.dart';
import 'package:rawi/models/scene_config.dart';
import 'package:rawi/data/m1_data.dart';
import 'package:rawi/data/scene_configs.dart';

void main() {
  group('Branching system — linear fallback safety', () {
    test('Events without branchPoint resolve to linear flow (isBranching == false)', () {
      // Events 4–36 have no branchPoint — they MUST stay linear.
      for (final event in m1Events) {
        if (event.globalOrder > 3) {
          expect(
            event.isBranching,
            isFalse,
            reason: 'Event ${event.globalOrder} (${event.id}) should be linear '
                '— branchPoint must be null for events without branching content.',
          );
          expect(event.anchorHotspotId, isNull,
              reason: 'Event ${event.id} should have no anchorHotspotId');
          expect(event.convergenceHotspotId, isNull,
              reason: 'Event ${event.id} should have no convergenceHotspotId');
        }
      }
    });

    test('JourneyEvent.isBranching is true only when branchPoint is set', () {
      final linearEvent = JourneyEvent(
        id: 'test_linear',
        era: JourneyEra.jahiliyyah,
        globalOrder: 99,
        latitude: 0, longitude: 0,
        year: 500,
        title: 'Test Linear',
        titleAr: 'اختبار خطي',
        location: 'Test',
        locationAr: 'اختبار',
        narrative: 'test',
        narrativeAr: 'اختبار',
        source: 'test',
      );
      expect(linearEvent.isBranching, isFalse);
      expect(linearEvent.branchPoint, isNull);
      expect(linearEvent.anchorHotspotId, isNull);
      expect(linearEvent.convergenceHotspotId, isNull);

      final branchingEvent = JourneyEvent(
        id: 'test_branching',
        era: JourneyEra.jahiliyyah,
        globalOrder: 100,
        latitude: 0, longitude: 0,
        year: 500,
        title: 'Test Branching',
        titleAr: 'اختبار تفرع',
        location: 'Test',
        locationAr: 'اختبار',
        narrative: 'test',
        narrativeAr: 'اختبار',
        source: 'test',
        anchorHotspotId: 'anchor',
        convergenceHotspotId: 'convergence',
        branchPoint: BranchPoint(
          id: 'bp_test',
          prompt: 'Where do you go?',
          promptAr: 'إلى أين تذهب؟',
          optionA: BranchOption(
            label: 'Left',
            labelAr: 'يسار',
            targetHotspotId: 'left',
          ),
          optionB: BranchOption(
            label: 'Right',
            labelAr: 'يمين',
            targetHotspotId: 'right',
          ),
        ),
      );
      expect(branchingEvent.isBranching, isTrue);
      expect(branchingEvent.anchorHotspotId, 'anchor');
      expect(branchingEvent.convergenceHotspotId, 'convergence');
    });

    test('SceneConfig.pathWaypointsAlt is null by default', () {
      final config = SceneConfig(
        skyGradient: const [Color(0xFF000000)],
      );
      expect(config.pathWaypointsAlt, isNull);
    });

    test('All scene configs for Events 4+ have no alt paths', () {
      for (final entry in sceneConfigs.entries) {
        // Only Events 1-3 will have alt paths after Sprint 23
        // All others must have null pathWaypointsAlt
        final eventId = entry.key;
        final config = entry.value;
        if (eventId != 'j_1_1_1' && eventId != 'j_1_1_2' && eventId != 'j_1_1_3') {
          expect(
            config.pathWaypointsAlt,
            isNull,
            reason: 'SceneConfig for $eventId should have no alt path',
          );
        }
      }
    });

    test('BranchPoint model stores all required fields', () {
      const bp = BranchPoint(
        id: 'bp_test',
        prompt: 'Where?',
        promptAr: 'أين؟',
        optionA: BranchOption(
          label: 'A', labelAr: 'أ', targetHotspotId: 'hot_a',
        ),
        optionB: BranchOption(
          label: 'B', labelAr: 'ب', targetHotspotId: 'hot_b',
        ),
      );
      expect(bp.id, 'bp_test');
      expect(bp.optionA.targetHotspotId, 'hot_a');
      expect(bp.optionB.targetHotspotId, 'hot_b');
    });
  });
}
