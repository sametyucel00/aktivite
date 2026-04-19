import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldCreateSafeMeetupReminderTrustEvent', () {
    test('returns false when disabled or signed out', () {
      expect(
        shouldCreateSafeMeetupReminderTrustEvent(
          userId: null,
          enabled: true,
          existingEvents: const <ModerationEvent>[],
        ),
        isFalse,
      );
      expect(
        shouldCreateSafeMeetupReminderTrustEvent(
          userId: 'user-1',
          enabled: false,
          existingEvents: const <ModerationEvent>[],
        ),
        isFalse,
      );
    });

    test('returns false when reminder trust event already exists', () {
      final existing = [
        createSafeMeetupReminderTrustEvent(subjectUserId: 'user-1'),
      ];

      expect(
        shouldCreateSafeMeetupReminderTrustEvent(
          userId: 'user-1',
          enabled: true,
          existingEvents: existing,
        ),
        isFalse,
      );
    });

    test('returns true when enabled user has no reminder event', () {
      expect(
        shouldCreateSafeMeetupReminderTrustEvent(
          userId: 'user-1',
          enabled: true,
          existingEvents: const <ModerationEvent>[],
        ),
        isTrue,
      );
    });
  });
}
