import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/plan_match_reason.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';

int planMatchScore(AppUserProfile profile, ActivityPlan plan) {
  var score = 0;

  if (profile.favoriteActivities.contains(plan.category)) {
    score += 4;
  }

  if (matchesPlanAvailability(profile.activeTimes, plan)) {
    score += 3;
  }

  if (matchesGroupPreference(profile.groupPreference, plan.maxParticipants)) {
    score += 2;
  }

  if (plan.status == ActivityStatus.open) {
    score += 1;
  }

  return score;
}

List<PlanMatchReason> planMatchReasons(
  AppUserProfile profile,
  ActivityPlan plan,
) {
  final reasons = <PlanMatchReason>[];

  if (profile.favoriteActivities.contains(plan.category)) {
    reasons.add(PlanMatchReason.favoriteActivity);
  }
  if (matchesPlanAvailability(profile.activeTimes, plan)) {
    reasons.add(PlanMatchReason.activeTime);
  }
  if (matchesGroupPreference(profile.groupPreference, plan.maxParticipants)) {
    reasons.add(PlanMatchReason.groupPreference);
  }
  if (plan.status == ActivityStatus.open) {
    reasons.add(PlanMatchReason.openNow);
  }

  return reasons;
}

bool matchesPlanAvailability(
  List<AvailabilitySlot> activeTimes,
  ActivityPlan plan,
) {
  final timeOption = plan.timeOption;
  if (timeOption != null) {
    return matchesTimeOptionAvailability(activeTimes, timeOption);
  }

  return matchesAvailability(activeTimes, plan.timeLabel);
}

bool matchesTimeOptionAvailability(
  List<AvailabilitySlot> activeTimes,
  PlanTimeOption timeOption,
) {
  switch (timeOption) {
    case PlanTimeOption.now:
      return activeTimes.contains(AvailabilitySlot.afternoons);
    case PlanTimeOption.tonight:
      return activeTimes.contains(AvailabilitySlot.evenings);
    case PlanTimeOption.weekend:
      return activeTimes.contains(AvailabilitySlot.weekends);
  }
}

bool matchesAvailability(
  List<AvailabilitySlot> activeTimes,
  String timeLabel,
) {
  final normalized = timeLabel.toLowerCase();
  if (normalized.contains('now') ||
      normalized.contains('simdi') ||
      normalized.contains('afternoon') ||
      normalized.contains('ogleden')) {
    return activeTimes.contains(AvailabilitySlot.afternoons);
  }
  if (normalized.contains('tonight') ||
      normalized.contains('aksam') ||
      normalized.contains('evening')) {
    return activeTimes.contains(AvailabilitySlot.evenings);
  }
  if (normalized.contains('weekend') || normalized.contains('hafta sonu')) {
    return activeTimes.contains(AvailabilitySlot.weekends);
  }
  if (normalized.contains('morning') || normalized.contains('sabah')) {
    return activeTimes.contains(AvailabilitySlot.mornings);
  }
  return false;
}

bool matchesGroupPreference(
  GroupPreference preference,
  int maxParticipants,
) {
  switch (preference) {
    case GroupPreference.oneOnOne:
      return maxParticipants <= 2;
    case GroupPreference.smallGroup:
      return maxParticipants >= 3 && maxParticipants <= 5;
    case GroupPreference.flexible:
      return true;
  }
}
