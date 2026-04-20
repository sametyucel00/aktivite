import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String activityLabel(AppLocalizations l10n, ActivityCategory category) {
  switch (category) {
    case ActivityCategory.coffee:
      return l10n.activityCoffee;
    case ActivityCategory.walk:
      return l10n.activityWalk;
    case ActivityCategory.chat:
      return l10n.activityChat;
    case ActivityCategory.cowork:
      return l10n.activityCowork;
    case ActivityCategory.event:
      return l10n.activityEvent;
    case ActivityCategory.movie:
      return l10n.activityMovie;
    case ActivityCategory.games:
      return l10n.activityGames;
    case ActivityCategory.sports:
      return l10n.activitySports;
  }
}

IconData activityIcon(ActivityCategory category) {
  switch (category) {
    case ActivityCategory.coffee:
      return Icons.local_cafe_outlined;
    case ActivityCategory.walk:
      return Icons.directions_walk_outlined;
    case ActivityCategory.chat:
      return Icons.forum_outlined;
    case ActivityCategory.cowork:
      return Icons.laptop_mac_outlined;
    case ActivityCategory.event:
      return Icons.event_outlined;
    case ActivityCategory.movie:
      return Icons.movie_outlined;
    case ActivityCategory.games:
      return Icons.casino_outlined;
    case ActivityCategory.sports:
      return Icons.sports_tennis_outlined;
  }
}

IconData availabilityIcon(AvailabilitySlot slot) {
  switch (slot) {
    case AvailabilitySlot.mornings:
      return Icons.wb_sunny_outlined;
    case AvailabilitySlot.afternoons:
      return Icons.light_mode_outlined;
    case AvailabilitySlot.evenings:
      return Icons.nights_stay_outlined;
    case AvailabilitySlot.weekends:
      return Icons.weekend_outlined;
  }
}

IconData socialMoodIcon(SocialMood mood) {
  switch (mood) {
    case SocialMood.calm:
      return Icons.spa_outlined;
    case SocialMood.casual:
      return Icons.sentiment_satisfied_outlined;
    case SocialMood.energetic:
      return Icons.bolt_outlined;
    case SocialMood.focused:
      return Icons.center_focus_strong_outlined;
    case SocialMood.groupFriendly:
      return Icons.groups_outlined;
  }
}

IconData groupPreferenceIcon(GroupPreference preference) {
  switch (preference) {
    case GroupPreference.oneOnOne:
      return Icons.person_outline;
    case GroupPreference.smallGroup:
      return Icons.group_outlined;
    case GroupPreference.flexible:
      return Icons.tune_outlined;
  }
}

String moodLabel(AppLocalizations l10n, SocialMood mood) {
  switch (mood) {
    case SocialMood.calm:
      return l10n.moodCalm;
    case SocialMood.casual:
      return l10n.moodCasual;
    case SocialMood.energetic:
      return l10n.moodEnergetic;
    case SocialMood.focused:
      return l10n.moodFocused;
    case SocialMood.groupFriendly:
      return l10n.moodGroupFriendly;
  }
}

String groupPreferenceLabel(
  AppLocalizations l10n,
  GroupPreference preference,
) {
  switch (preference) {
    case GroupPreference.oneOnOne:
      return l10n.groupPreferenceOneOnOne;
    case GroupPreference.smallGroup:
      return l10n.groupPreferenceSmallGroup;
    case GroupPreference.flexible:
      return l10n.groupPreferenceFlexible;
  }
}

String availabilityLabel(
  AppLocalizations l10n,
  AvailabilitySlot slot,
) {
  switch (slot) {
    case AvailabilitySlot.mornings:
      return l10n.availabilityMornings;
    case AvailabilitySlot.afternoons:
      return l10n.availabilityAfternoons;
    case AvailabilitySlot.evenings:
      return l10n.availabilityEvenings;
    case AvailabilitySlot.weekends:
      return l10n.availabilityWeekends;
  }
}

String verificationLabel(
  AppLocalizations l10n,
  String verification,
) {
  switch (verification) {
    case 'phone':
      return l10n.verificationPhone;
    default:
      return verification;
  }
}

String planTimeOptionLabel(AppLocalizations l10n, PlanTimeOption option) {
  switch (option) {
    case PlanTimeOption.now:
      return l10n.surfaceNow;
    case PlanTimeOption.tonight:
      return l10n.surfaceTonight;
    case PlanTimeOption.weekend:
      return l10n.surfaceWeekend;
  }
}

String discoveryDistanceFilterLabel(
  AppLocalizations l10n,
  DiscoveryDistanceFilter filter,
) {
  final maxKm = filter.maxKm;
  if (maxKm == null) {
    return l10n.distanceFilterAny;
  }
  return l10n.distanceFilterKm(maxKm);
}

String mapPrivacyModeLabel(AppLocalizations l10n, MapPrivacyMode mode) {
  switch (mode) {
    case MapPrivacyMode.approximate:
      return l10n.mapPrivacyApproximate;
    case MapPrivacyMode.hidden:
      return l10n.mapPrivacyHidden;
  }
}
