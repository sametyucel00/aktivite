import 'package:aktivite/core/services/in_memory_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryAnalyticsService', () {
    test('watchEvents emits initial events immediately', () async {
      final service = InMemoryAnalyticsService();

      final events = await service.watchEvents().first;

      expect(events, isEmpty);
    });

    test('logEvent prepends the newest event', () async {
      final service = InMemoryAnalyticsService();

      await service.logEvent(
        name: 'first_event',
        parameters: {'step': 1},
      );
      await service.logEvent(
        name: 'second_event',
        parameters: {'step': 2},
      );

      final events = await service.watchEvents().first;

      expect(events, hasLength(2));
      expect(events.first.name, 'second_event');
      expect(events.first.parameters['step'], 2);
      expect(events.last.name, 'first_event');
    });
  });
}
