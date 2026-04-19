import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/safety/data/in_memory_moderation_repository.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryModerationRepository', () {
    test('watchTrustEvents emits initial events immediately', () async {
      final repository = InMemoryModerationRepository();

      final events =
          await repository.watchTrustEvents(SampleIds.currentUser).first;

      expect(events, hasLength(2));
      expect(
          events.every((event) => event.subjectUserId == SampleIds.currentUser),
          isTrue);
    });

    test('createTrustEvent appends an event for the matching user', () async {
      final repository = InMemoryModerationRepository();

      await repository.createTrustEvent(
        ModerationEvent(
          id: 'trust-3',
          subjectUserId: SampleIds.currentUser,
          reasonCode: 'report_submitted:guest-2',
          isUserVisible: true,
          createdAt: DateTime(2026, 4, 18, 21, 0),
        ),
      );

      final events =
          await repository.watchTrustEvents(SampleIds.currentUser).first;

      expect(events, hasLength(3));
      expect(events.last.id, 'trust-3');
    });

    test('watchTrustEvents filters events by subject user id', () async {
      final repository = InMemoryModerationRepository();

      await repository.createTrustEvent(
        ModerationEvent(
          id: 'trust-foreign',
          subjectUserId: 'another-user',
          reasonCode: 'blocked_user:guest-3',
          isUserVisible: false,
          createdAt: DateTime(2026, 4, 18, 22, 0),
        ),
      );

      final currentUserEvents =
          await repository.watchTrustEvents(SampleIds.currentUser).first;
      final anotherUserEvents =
          await repository.watchTrustEvents('another-user').first;

      expect(currentUserEvents.any((event) => event.id == 'trust-foreign'),
          isFalse);
      expect(anotherUserEvents.single.id, 'trust-foreign');
    });
  });
}
