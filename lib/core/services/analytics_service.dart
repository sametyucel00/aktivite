import 'package:aktivite/shared/models/analytics_event_record.dart';

abstract class AnalyticsService {
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  });

  Stream<List<AnalyticsEventRecord>> watchEvents();
}
