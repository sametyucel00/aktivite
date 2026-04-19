import 'dart:async';

import 'package:aktivite/core/services/analytics_service.dart';
import 'package:aktivite/core/utils/app_time.dart';
import 'package:aktivite/shared/models/analytics_event_record.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({
    FirebaseAnalytics Function()? analytics,
  }) : _analytics = analytics ?? (() => FirebaseAnalytics.instance);

  final FirebaseAnalytics Function() _analytics;
  final List<AnalyticsEventRecord> _events = <AnalyticsEventRecord>[];
  final StreamController<List<AnalyticsEventRecord>> _controller =
      StreamController<List<AnalyticsEventRecord>>.broadcast();

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  }) async {
    await _analytics().logEvent(
      name: name,
      parameters: _sanitizeParameters(parameters),
    );

    _events.insert(
      0,
      AnalyticsEventRecord(
        name: name,
        parameters: Map<String, Object?>.unmodifiable(parameters),
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

  Map<String, Object> _sanitizeParameters(Map<String, Object?> parameters) {
    return <String, Object>{
      for (final entry in parameters.entries)
        entry.key: _sanitizeValue(entry.value),
    };
  }

  Object _sanitizeValue(Object? value) {
    if (value is String) {
      return value;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return value?.toString() ?? '';
  }
}
