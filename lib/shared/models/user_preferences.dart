class UserPreferences {
  const UserPreferences({
    required this.notificationsEnabled,
    required this.approximateLocationEnabled,
    required this.safeMeetupRemindersEnabled,
    this.localeCode = 'tr',
  });

  const UserPreferences.initial()
      : notificationsEnabled = true,
        approximateLocationEnabled = true,
        safeMeetupRemindersEnabled = true,
        localeCode = 'tr';

  final bool notificationsEnabled;
  final bool approximateLocationEnabled;
  final bool safeMeetupRemindersEnabled;
  final String localeCode;

  bool get notificationsAllowed => notificationsEnabled;

  bool get sharesApproximateLocation => approximateLocationEnabled;

  bool get safeMeetupRemindersActive => safeMeetupRemindersEnabled;

  bool get hidesMapLocation => !sharesApproximateLocation;

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? approximateLocationEnabled,
    bool? safeMeetupRemindersEnabled,
    String? localeCode,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      approximateLocationEnabled:
          approximateLocationEnabled ?? this.approximateLocationEnabled,
      safeMeetupRemindersEnabled:
          safeMeetupRemindersEnabled ?? this.safeMeetupRemindersEnabled,
      localeCode: localeCode ?? this.localeCode,
    );
  }
}
