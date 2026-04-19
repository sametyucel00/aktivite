import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/features/activities/data/in_memory_join_request_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryJoinRequestRepository', () {
    test('watchRequestsForActivity emits initial requests immediately',
        () async {
      final repository = InMemoryJoinRequestRepository();

      final requests = await repository
          .watchRequestsForActivity(SampleIds.coffeeActivity)
          .first;

      expect(requests, isNotEmpty);
      expect(requests.first.activityId, SampleIds.coffeeActivity);
      expect(requests.first.status, JoinRequestStatus.pending);
    });

    test('submitJoinRequest adds a pending request for the selected activity',
        () async {
      final repository = InMemoryJoinRequestRepository();

      await repository.submitJoinRequest(
        activityId: 'activity-2',
        message: 'I can join after work.',
      );

      final requests =
          await repository.watchRequestsForActivity('activity-2').first;

      expect(requests, hasLength(1));
      expect(requests.first.requesterId, SampleIds.currentUser);
      expect(requests.first.message, 'I can join after work.');
      expect(requests.first.status, JoinRequestStatus.pending);
    });

    test('updateRequestStatus updates the matching request only', () async {
      final repository = InMemoryJoinRequestRepository();

      await repository.updateRequestStatus(
        requestId: 'join-1',
        status: JoinRequestStatus.approved,
      );

      final requests = await repository
          .watchRequestsForActivity(SampleIds.coffeeActivity)
          .first;

      expect(requests.single.status, JoinRequestStatus.approved);
    });

    test('updateRequestStatus ignores unknown request ids', () async {
      final repository = InMemoryJoinRequestRepository();

      await repository.updateRequestStatus(
        requestId: 'missing-request',
        status: JoinRequestStatus.rejected,
      );

      final requests = await repository
          .watchRequestsForActivity(SampleIds.coffeeActivity)
          .first;

      expect(requests.single.status, JoinRequestStatus.pending);
    });
  });
}
