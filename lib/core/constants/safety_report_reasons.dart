abstract final class SafetyReportReasons {
  static const spam = 'spam';
  static const harassment = 'harassment';
  static const unsafeMeetup = 'unsafe_meetup';
  static const fakeProfile = 'fake_profile';
  static const inappropriateContent = 'inappropriate_content';

  static const values = <String>[
    spam,
    harassment,
    unsafeMeetup,
    fakeProfile,
    inappropriateContent,
  ];

  static String? normalize(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'spam':
        return spam;
      case 'harassment':
        return harassment;
      case 'unsafe meetup':
      case 'unsafe meetup behavior':
      case 'unsafe_meetup':
        return unsafeMeetup;
      case 'fake profile':
      case 'fake_profile':
        return fakeProfile;
      case 'inappropriate content':
      case 'inappropriate_content':
        return inappropriateContent;
      default:
        return values.contains(normalized) ? normalized : null;
    }
  }
}
