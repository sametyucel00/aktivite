class AnalyticsEventRecord {
  const AnalyticsEventRecord({
    required this.name,
    required this.parameters,
    required this.loggedAt,
  });

  final String name;
  final Map<String, Object?> parameters;
  final DateTime loggedAt;
}
