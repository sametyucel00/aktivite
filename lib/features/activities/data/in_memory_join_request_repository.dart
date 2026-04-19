import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/utils/app_time.dart';
import 'package:aktivite/features/activities/data/join_request_repository.dart';
import 'package:aktivite/shared/models/join_request.dart';

class InMemoryJoinRequestRepository implements JoinRequestRepository {
  InMemoryJoinRequestRepository() {
    _controller.add(_snapshot());
  }

  final List<JoinRequest> _requests = [
    const JoinRequest(
      id: 'join-1',
      activityId: SampleIds.coffeeActivity,
      requesterId: SampleIds.guestOne,
      message: 'I can arrive in 20 minutes.',
      status: JoinRequestStatus.pending,
    ),
  ];
  final StreamController<List<JoinRequest>> _controller =
      StreamController<List<JoinRequest>>.broadcast();

  @override
  Future<void> submitJoinRequest({
    required String activityId,
    required String message,
  }) async {
    final normalizedActivityId = activityId.trim();
    final normalizedMessage = message.trim();
    if (normalizedActivityId.isEmpty || normalizedMessage.isEmpty) {
      return;
    }

    final hasActiveRequest = _requests.any(
      (request) =>
          request.activityId == normalizedActivityId &&
          request.requesterId == SampleIds.currentUser &&
          (request.isPending || request.isApproved),
    );
    if (hasActiveRequest) {
      return;
    }

    _requests.add(
      JoinRequest(
        id: AppIdFactory.sequenceId(
          prefix: 'join',
          nextNumber: _requests.length + 1,
        ),
        activityId: normalizedActivityId,
        requesterId: SampleIds.currentUser,
        message: normalizedMessage,
        status: JoinRequestStatus.pending,
      ),
    );
    _controller.add(_snapshot());
  }

  @override
  Future<void> updateRequestStatus({
    required String requestId,
    required JoinRequestStatus status,
  }) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      return;
    }
    final current = _requests[index];
    _requests[index] = current.copyWith(status: status);
    _controller.add(_snapshot());
  }

  @override
  Future<void> cancelJoinRequest({
    required String requestId,
  }) {
    return updateRequestStatus(
      requestId: requestId,
      status: JoinRequestStatus.cancelled,
    );
  }

  @override
  Stream<List<JoinRequest>> watchRequestsForActivity(String activityId) {
    return Stream<List<JoinRequest>>.multi((multi) {
      multi.add(_requestsForActivity(activityId));
      final subscription = _controller.stream
          .map((requests) =>
              _requestsForActivity(activityId, requests: requests))
          .listen(
            multi.add,
            onError: multi.addError,
            onDone: multi.close,
          );
      multi.onCancel = subscription.cancel;
    });
  }

  List<JoinRequest> _requestsForActivity(
    String activityId, {
    List<JoinRequest>? requests,
  }) {
    return (requests ?? _requests)
        .where((request) => request.activityId == activityId)
        .toList(growable: false);
  }

  List<JoinRequest> _snapshot() => List<JoinRequest>.unmodifiable(_requests);
}
