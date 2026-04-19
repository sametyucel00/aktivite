import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/utils/enum_codecs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('enum codecs', () {
    test('enumFromName returns matching enum', () {
      final value = enumFromName(
        ActivityCategory.values,
        'walk',
        fallback: ActivityCategory.coffee,
      );

      expect(value, ActivityCategory.walk);
    });

    test('enumFromName falls back for missing value', () {
      final value = enumFromName(
        ActivityStatus.values,
        'missing',
        fallback: ActivityStatus.open,
      );

      expect(value, ActivityStatus.open);
    });

    test('enumFromNameOrNull returns null for unknown value', () {
      final value = enumFromNameOrNull(
        DiscoverySurface.values,
        'invalid-surface',
      );

      expect(value, isNull);
    });

    test('enumListFromNames keeps valid items and drops invalid ones', () {
      final values = enumListFromNames(
        AvailabilitySlot.values,
        ['mornings', 'weekends', 'unknown', 42],
      );

      expect(values, [
        AvailabilitySlot.mornings,
        AvailabilitySlot.weekends,
      ]);
    });

    test('enumNames returns stable Dart enum names', () {
      final values = enumNames([
        ActivityCategory.coffee,
        ActivityCategory.games,
      ]);

      expect(values, ['coffee', 'games']);
    });
  });
}
