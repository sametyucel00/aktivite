import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/enums/plan_match_reason.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';

T enumFromName<T extends Enum>(
  Iterable<T> values,
  Object? value, {
  required T fallback,
}) {
  return enumFromNameOrNull(values, value) ?? fallback;
}

T? enumFromNameOrNull<T extends Enum>(
  Iterable<T> values,
  Object? value,
) {
  if (value is! String) {
    return null;
  }

  for (final item in values) {
    if (item.name == value) {
      return item;
    }
  }
  return null;
}

List<T> enumListFromNames<T extends Enum>(
  Iterable<T> values,
  Object? value,
) {
  if (value is! Iterable) {
    return const [];
  }

  return value
      .map((item) => enumFromNameOrNull(values, item))
      .whereType<T>()
      .toList(growable: false);
}

String enumName(Enum value) => value.name;

List<String> enumNames(Iterable<Enum> values) {
  return values.map((value) => value.name).toList(growable: false);
}

ActivityCategory activityCategoryFromName(Object? value) {
  return enumFromName(
    ActivityCategory.values,
    value,
    fallback: ActivityCategory.coffee,
  );
}

ActivityStatus activityStatusFromName(Object? value) {
  return enumFromName(
    ActivityStatus.values,
    value,
    fallback: ActivityStatus.draft,
  );
}

AvailabilitySlot availabilitySlotFromName(Object? value) {
  return enumFromName(
    AvailabilitySlot.values,
    value,
    fallback: AvailabilitySlot.afternoons,
  );
}

DiscoverySurface discoverySurfaceFromName(Object? value) {
  return enumFromName(
    DiscoverySurface.values,
    value,
    fallback: DiscoverySurface.nearby,
  );
}

GroupPreference groupPreferenceFromName(Object? value) {
  return enumFromName(
    GroupPreference.values,
    value,
    fallback: GroupPreference.flexible,
  );
}

JoinRequestStatus joinRequestStatusFromName(Object? value) {
  return enumFromName(
    JoinRequestStatus.values,
    value,
    fallback: JoinRequestStatus.pending,
  );
}

PlanMatchReason planMatchReasonFromName(Object? value) {
  return enumFromName(
    PlanMatchReason.values,
    value,
    fallback: PlanMatchReason.openNow,
  );
}

PlanTimeOption planTimeOptionFromName(Object? value) {
  return enumFromName(
    PlanTimeOption.values,
    value,
    fallback: PlanTimeOption.tonight,
  );
}

SocialMood socialMoodFromName(Object? value) {
  return enumFromName(
    SocialMood.values,
    value,
    fallback: SocialMood.casual,
  );
}

VerificationLevel verificationLevelFromName(Object? value) {
  return enumFromName(
    VerificationLevel.values,
    value,
    fallback: VerificationLevel.none,
  );
}
