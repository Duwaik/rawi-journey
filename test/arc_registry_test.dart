import 'package:flutter_test/flutter_test.dart';
import 'package:rawi/data/arc_registry.dart';

void main() {
  group('arc_registry — structural invariants', () {
    test('20 arcs, 4 modules', () {
      expect(arcRegistry.length, 20);
      expect(moduleRegistry.length, 4);
    });

    test('every arc has non-empty EN + AR titles', () {
      for (final a in arcRegistry) {
        expect(a.titleEn.trim().isNotEmpty, isTrue,
            reason: 'arc ${a.arcId} has empty EN title');
        expect(a.titleAr.trim().isNotEmpty, isTrue,
            reason: 'arc ${a.arcId} has empty AR title');
      }
    });

    test('arcIds are 1..20 contiguous, no duplicates', () {
      final ids = arcRegistry.map((a) => a.arcId).toList()..sort();
      expect(ids, List.generate(20, (i) => i + 1));
    });

    test('moduleIds are 1..4 contiguous', () {
      final ids = moduleRegistry.map((m) => m.moduleId).toList()..sort();
      expect(ids, [1, 2, 3, 4]);
    });

    test('arcs cover events 1..155 contiguously with no gaps or overlaps', () {
      final sorted = [...arcRegistry]
        ..sort((a, b) => a.firstEvent.compareTo(b.firstEvent));
      expect(sorted.first.firstEvent, 1);
      expect(sorted.last.lastEvent, 155);
      for (int i = 1; i < sorted.length; i++) {
        expect(sorted[i].firstEvent, sorted[i - 1].lastEvent + 1,
            reason: 'gap/overlap between arc ${sorted[i - 1].arcId} and '
                'arc ${sorted[i].arcId}');
      }
    });

    test('module event counts match sum of member arcs', () {
      for (final m in moduleRegistry) {
        final arcs = arcsInModule(m.moduleId);
        final sum = arcs.fold<int>(0, (acc, a) => acc + a.eventCount);
        expect(sum, m.eventCount,
            reason: 'module ${m.moduleId} declared ${m.eventCount} events '
                'but member arcs sum to $sum');
        expect(arcs.length, 5,
            reason: 'module ${m.moduleId} must have exactly 5 arcs');
      }
    });

    test('module event ranges line up with arc ranges', () {
      for (final m in moduleRegistry) {
        final arcs = arcsInModule(m.moduleId)
          ..sort((a, b) => a.firstEvent.compareTo(b.firstEvent));
        expect(arcs.first.firstEvent, m.firstEvent);
        expect(arcs.last.lastEvent, m.lastEvent);
      }
    });
  });

  group('arcIdForEvent — boundary cases (spec acceptance)', () {
    test('arcIdForEvent(1) == 1', () {
      expect(arcIdForEvent(1), 1);
    });
    test('arcIdForEvent(47) == 5 (last event of module 1)', () {
      expect(arcIdForEvent(47), 5);
    });
    test('arcIdForEvent(48) == 6 (first event of module 2)', () {
      expect(arcIdForEvent(48), 6);
    });
    test('arcIdForEvent(82) == 10 (last event of module 2)', () {
      expect(arcIdForEvent(82), 10);
    });
    test('arcIdForEvent(83) == 11 (first event of module 3)', () {
      expect(arcIdForEvent(83), 11);
    });
    test('arcIdForEvent(120) == 15 (last event of module 3)', () {
      expect(arcIdForEvent(120), 15);
    });
    test('arcIdForEvent(121) == 16 (first event of module 4)', () {
      expect(arcIdForEvent(121), 16);
    });
    test('arcIdForEvent(155) == 20 (last event overall)', () {
      expect(arcIdForEvent(155), 20);
    });

    test('every event 1..155 maps to an arc in 1..20', () {
      for (int go = 1; go <= 155; go++) {
        final id = arcIdForEvent(go);
        expect(id, inInclusiveRange(1, 20),
            reason: 'event $go mapped to out-of-range arcId $id');
      }
    });

    test('out-of-range globalOrder returns 0', () {
      expect(arcIdForEvent(0), 0);
      expect(arcIdForEvent(156), 0);
      expect(arcIdForEvent(-1), 0);
    });
  });
}
