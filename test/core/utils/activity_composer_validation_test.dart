import 'package:aktivite/core/utils/activity_composer_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('activity composer validation', () {
    test('returns null for a complete privacy-first activity plan draft', () {
      final result = validateActivityComposer(
        title: 'Coffee after work',
        description: 'Low-pressure coffee and chat.',
        city: 'Istanbul',
        approximateLocation: 'Kadikoy center',
        scheduledAt: DateTime(2026, 4, 19, 20),
        durationMinutes: 60,
        now: DateTime(2026, 4, 19, 18),
      );

      expect(result, isNull);
    });

    test('requires approximate location and supported duration values', () {
      expect(
        validateActivityComposer(
          title: 'Walk',
          description: 'Short walk.',
          city: 'Istanbul',
          approximateLocation: '',
          scheduledAt: DateTime(2026, 4, 19, 20),
          durationMinutes: 60,
          now: DateTime(2026, 4, 19, 18),
        ),
        ActivityComposerValidationIssue.missingApproximateLocation,
      );
      expect(
        validateActivityComposer(
          title: 'Walk',
          description: 'Short walk.',
          city: 'Istanbul',
          approximateLocation: 'Moda coast',
          scheduledAt: DateTime(2026, 4, 19, 20),
          durationMinutes: 15,
          now: DateTime(2026, 4, 19, 18),
        ),
        ActivityComposerValidationIssue.invalidDuration,
      );
    });

    test('rejects clearly past schedule times', () {
      expect(
        validateActivityComposer(
          title: 'Walk',
          description: 'Short walk.',
          city: 'Istanbul',
          approximateLocation: 'Moda coast',
          scheduledAt: DateTime(2026, 4, 19, 17),
          durationMinutes: 60,
          now: DateTime(2026, 4, 19, 18),
        ),
        ActivityComposerValidationIssue.scheduledInPast,
      );
    });
  });
}
