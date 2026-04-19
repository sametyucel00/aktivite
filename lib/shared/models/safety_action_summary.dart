class SafetyActionSummary {
  const SafetyActionSummary({
    required this.blockedCount,
    required this.reportCount,
    required this.hasBlockedGuestUser,
    required this.hasReportedGuestUser,
  });

  final int blockedCount;
  final int reportCount;
  final bool hasBlockedGuestUser;
  final bool hasReportedGuestUser;
}
