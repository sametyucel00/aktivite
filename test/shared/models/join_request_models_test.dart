import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/join_request_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoinRequest', () {
    test('status helper getters map statuses consistently', () {
      const pending = JoinRequest(
        id: 'join-1',
        activityId: 'activity-1',
        requesterId: 'user-1',
        message: 'Available now',
        status: JoinRequestStatus.pending,
      );
      const approved = JoinRequest(
        id: 'join-2',
        activityId: 'activity-1',
        requesterId: 'user-2',
        message: 'Approved',
        status: JoinRequestStatus.approved,
      );
      const rejected = JoinRequest(
        id: 'join-3',
        activityId: 'activity-1',
        requesterId: 'user-3',
        message: 'Rejected',
        status: JoinRequestStatus.rejected,
      );
      const cancelled = JoinRequest(
        id: 'join-4',
        activityId: 'activity-1',
        requesterId: 'user-4',
        message: 'Cancelled',
        status: JoinRequestStatus.cancelled,
      );

      expect(pending.isPending, isTrue);
      expect(pending.isApproved, isFalse);
      expect(pending.isRejected, isFalse);

      expect(approved.isPending, isFalse);
      expect(approved.isApproved, isTrue);
      expect(approved.isRejected, isFalse);

      expect(rejected.isRejected, isTrue);
      expect(cancelled.isRejected, isTrue);
      expect(pending.needsOwnerReview, isTrue);
      expect(cancelled.isClosed, isTrue);
      expect(approved.isTerminal, isFalse);
    });

    test('copyWith preserves unspecified values and updates status', () {
      const request = JoinRequest(
        id: 'join-1',
        activityId: 'activity-1',
        requesterId: 'user-1',
        message: 'Can join in 10 minutes',
        status: JoinRequestStatus.pending,
      );

      final updated = request.copyWith(status: JoinRequestStatus.approved);

      expect(updated.id, request.id);
      expect(updated.activityId, request.activityId);
      expect(updated.requesterId, request.requesterId);
      expect(updated.message, request.message);
      expect(updated.status, JoinRequestStatus.approved);
    });

    test('canTransitionTo blocks terminal-state changes', () {
      const pending = JoinRequest(
        id: 'join-1',
        activityId: 'activity-1',
        requesterId: 'user-1',
        message: 'Pending',
        status: JoinRequestStatus.pending,
      );
      const approved = JoinRequest(
        id: 'join-2',
        activityId: 'activity-1',
        requesterId: 'user-2',
        message: 'Approved',
        status: JoinRequestStatus.approved,
      );

      expect(pending.canTransitionTo(JoinRequestStatus.approved), isTrue);
      expect(pending.canTransitionTo(JoinRequestStatus.cancelled), isTrue);
      expect(approved.canTransitionTo(JoinRequestStatus.rejected), isFalse);
    });
  });

  group('JoinRequestSummary', () {
    test('fromRequests aggregates counts and derived flags', () {
      const requests = [
        JoinRequest(
          id: 'join-1',
          activityId: 'activity-1',
          requesterId: 'user-1',
          message: 'Pending',
          status: JoinRequestStatus.pending,
        ),
        JoinRequest(
          id: 'join-2',
          activityId: 'activity-1',
          requesterId: 'user-2',
          message: 'Approved',
          status: JoinRequestStatus.approved,
        ),
        JoinRequest(
          id: 'join-3',
          activityId: 'activity-1',
          requesterId: 'user-3',
          message: 'Cancelled',
          status: JoinRequestStatus.cancelled,
        ),
      ];

      final summary = JoinRequestSummary.fromRequests(requests);

      expect(summary.pending, 1);
      expect(summary.approved, 1);
      expect(summary.rejected, 1);
      expect(summary.total, 3);
      expect(summary.hasRequests, isTrue);
    });
  });
}
