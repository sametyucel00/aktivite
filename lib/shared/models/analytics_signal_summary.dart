class AnalyticsSignalSummary {
  const AnalyticsSignalSummary({
    required this.authActions,
    required this.safetyActions,
    required this.coordinationActions,
  });

  final int authActions;
  final int safetyActions;
  final int coordinationActions;
}
