class UserPreferences {
  const UserPreferences({
    required this.notificationsEnabled,
    required this.approximateLocationEnabled,
    required this.safeMeetupRemindersEnabled,
  });

  const UserPreferences.initial()
      : notificationsEnabled = true,
        approximateLocationEnabled = true,
        safeMeetupRemindersEnabled = true;

  final bool notificationsEnabled;
  final bool approximateLocationEnabled;
  final bool safeMeetupRemindersEnabled;

  bool get notificationsAllowed => notificationsEnabled;

  bool get sharesApproximateLocation => approximateLocationEnabled;

  bool get safeMeetupRemindersActive => safeMeetupRemindersEnabled;

  bool get hidesMapLocation => !sharesApproximateLocation;

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? approximateLocationEnabled,
    bool? safeMeetupRemindersEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      approximateLocationEnabled:
          approximateLocationEnabled ?? this.approximateLocationEnabled,
      safeMeetupRemindersEnabled:
          safeMeetupRemindersEnabled ?? this.safeMeetupRemindersEnabled,
    );
  }
}
