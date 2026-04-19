import 'dart:async';

import 'package:aktivite/core/services/analytics_service.dart';
import 'package:aktivite/core/utils/app_time.dart';
import 'package:aktivite/shared/models/analytics_event_record.dart';

class InMemoryAnalyticsService implements AnalyticsService {
  InMemoryAnalyticsService() {
    _controller.add(_snapshot());
  }

  final List<AnalyticsEventRecord> _events = [];
  final StreamController<List<AnalyticsEventRecord>> _controller =
      StreamController<List<AnalyticsEventRecord>>.broadcast();

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  }) async {
    _events.insert(
      0,
      AnalyticsEventRecord(
        name: name,
        parameters: parameters,
        loggedAt: AppClock.now(),
      ),
    );
    _controller.add(_snapshot());
  }

  @override
  Stream<List<AnalyticsEventRecord>> watchEvents() {
    return Stream<List<AnalyticsEventRecord>>.multi((multi) {
      multi.add(_snapshot());
      final subscription = _controller.stream.listen(
        multi.add,
        onError: multi.addError,
        onDone: multi.close,
      );
      multi.onCancel = subscription.cancel;
    });
  }

  List<AnalyticsEventRecord> _snapshot() =>
      List<AnalyticsEventRecord>.unmodifiable(_events);
}
