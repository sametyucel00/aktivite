import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/join_request.dart';

JoinRequest? currentUserJoinRequest(
    List<JoinRequest> requests, String? userId) {
  if (userId == null) {
    return null;
  }
  for (final request in requests) {
    if (request.requesterId == userId && !request.isCancelled) {
      return request;
    }
  }
  return null;
}

String joinRequestNotice(
  AppLocalizations l10n,
  JoinRequest request,
) {
  if (request.isPending) {
    return l10n.joinRequestAwaitingApproval;
  }
  if (request.isApproved) {
    return l10n.joinRequestApprovedNotice;
  }
  return l10n.joinRequestRejectedNotice;
}

String joinPlanStatusLabel({
  required AppLocalizations l10n,
  required List<JoinRequest> requests,
  required String? userId,
  required ActivityPlan plan,
}) {
  final currentRequest = currentUserJoinRequest(requests, userId);
  if (currentRequest != null) {
    return joinRequestNotice(l10n, currentRequest);
  }

  if (userId != null && plan.ownerUserId == userId) {
    return l10n.joinOwnPlanNotice;
  }

  if (!plan.hasCapacity) {
    return l10n.joinPlanFullNotice;
  }

  return '';
}

bool canSubmitJoinRequest({
  required ActivityPlan plan,
  required List<JoinRequest> requests,
  required String? userId,
  required bool canCreatePlans,
}) {
  if (!canCreatePlans || userId == null) {
    return false;
  }

  if (currentUserJoinRequest(requests, userId) != null) {
    return false;
  }

  if (plan.ownerUserId == userId) {
    return false;
  }

  return plan.hasCapacity;
}

bool canCancelJoinRequest({
  required JoinRequest request,
  required String? userId,
}) {
  return userId != null && request.requesterId == userId && request.isPending;
}
