import 'package:aktivite/shared/models/join_request.dart';

class JoinRequestSummary {
  const JoinRequestSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory JoinRequestSummary.fromRequests(Iterable<JoinRequest> requests) {
    var pending = 0;
    var approved = 0;
    var rejected = 0;

    for (final request in requests) {
      if (request.isPending) {
        pending += 1;
      } else if (request.isApproved) {
        approved += 1;
      } else if (request.isRejected) {
        rejected += 1;
      }
    }

    return JoinRequestSummary(
      pending: pending,
      approved: approved,
      rejected: rejected,
    );
  }

  final int pending;
  final int approved;
  final int rejected;

  int get total => pending + approved + rejected;

  bool get hasRequests => total > 0;
}
