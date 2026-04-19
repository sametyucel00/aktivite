import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';

int calculateProfileCompletion({
  required String displayName,
  required String city,
  required String bio,
  required List<ActivityCategory> favoriteActivities,
  required List<AvailabilitySlot> activeTimes,
  required GroupPreference groupPreference,
  required bool safeMeetupRemindersEnabled,
}) {
  var score = 0;

  if (displayName.trim().isNotEmpty) {
    score += 25;
  }
  if (city.trim().isNotEmpty) {
    score += 15;
  }
  if (bio.trim().isNotEmpty) {
    score += 20;
  }
  if (favoriteActivities.isNotEmpty) {
    score += 20;
  }
  if (activeTimes.isNotEmpty) {
    score += 15;
  }
  if (groupPreference == GroupPreference.flexible ||
      groupPreference == GroupPreference.oneOnOne ||
      groupPreference == GroupPreference.smallGroup) {
    score += 15;
  }
  if (safeMeetupRemindersEnabled) {
    score += 10;
  }

  return score.clamp(0, 100);
}
