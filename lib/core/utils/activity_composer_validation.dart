enum ActivityComposerValidationIssue {
  missingTitle,
  missingDescription,
  missingCity,
  missingApproximateLocation,
  invalidDuration,
  scheduledInPast,
}

const List<int> defaultActivityDurationOptions = <int>[
  30,
  45,
  60,
  90,
  120,
  180,
];

ActivityComposerValidationIssue? validateActivityComposer({
  required String title,
  required String description,
  required String city,
  required String approximateLocation,
  required DateTime scheduledAt,
  required int durationMinutes,
  DateTime? now,
}) {
  if (title.trim().isEmpty) {
    return ActivityComposerValidationIssue.missingTitle;
  }
  if (description.trim().isEmpty) {
    return ActivityComposerValidationIssue.missingDescription;
  }
  if (city.trim().isEmpty) {
    return ActivityComposerValidationIssue.missingCity;
  }
  if (approximateLocation.trim().isEmpty) {
    return ActivityComposerValidationIssue.missingApproximateLocation;
  }
  if (!defaultActivityDurationOptions.contains(durationMinutes)) {
    return ActivityComposerValidationIssue.invalidDuration;
  }

  final referenceTime = now ?? DateTime.now();
  if (scheduledAt
      .isBefore(referenceTime.subtract(const Duration(minutes: 5)))) {
    return ActivityComposerValidationIssue.scheduledInPast;
  }

  return null;
}
