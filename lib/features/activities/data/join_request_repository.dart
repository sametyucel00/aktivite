import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/shared/models/join_request.dart';

abstract class JoinRequestRepository {
  Stream<List<JoinRequest>> watchRequestsForActivity(String activityId);

  Future<void> submitJoinRequest({
    required String activityId,
    required String message,
  });

  Future<void> updateRequestStatus({
    required String requestId,
    required JoinRequestStatus status,
  });
}
