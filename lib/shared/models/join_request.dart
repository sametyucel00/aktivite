import 'package:aktivite/core/enums/join_request_status.dart';

class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.activityId,
    required this.requesterId,
    required this.message,
    required this.status,
  });

  final String id;
  final String activityId;
  final String requesterId;
  final String message;
  final JoinRequestStatus status;

  bool get isPending => status == JoinRequestStatus.pending;

  bool get isApproved => status == JoinRequestStatus.approved;

  bool get isCancelled => status == JoinRequestStatus.cancelled;

  bool get needsOwnerReview => status == JoinRequestStatus.pending;

  bool get isClosed =>
      status == JoinRequestStatus.rejected ||
      status == JoinRequestStatus.cancelled;

  bool get isRejected =>
      status == JoinRequestStatus.rejected ||
      status == JoinRequestStatus.cancelled;

  int get ownerListSortPriority {
    switch (status) {
      case JoinRequestStatus.pending:
        return 0;
      case JoinRequestStatus.approved:
        return 1;
      case JoinRequestStatus.rejected:
        return 2;
      case JoinRequestStatus.cancelled:
        return 3;
    }
  }

  JoinRequest copyWith({
    String? id,
    String? activityId,
    String? requesterId,
    String? message,
    JoinRequestStatus? status,
  }) {
    return JoinRequest(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      requesterId: requesterId ?? this.requesterId,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }
}
