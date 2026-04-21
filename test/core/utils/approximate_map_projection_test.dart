import 'package:aktivite/core/utils/approximate_map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('projectApproximateCoordinate', () {
    test('returns deterministic coordinate for the same seed', () {
      const origin = ApproximateCoordinate(
        latitude: 41.0082,
        longitude: 28.9784,
      );

      final first = projectApproximateCoordinate(
        origin: origin,
        seed: 'plan-1-kadikoy',
        distanceKm: 1.2,
      );
      final second = projectApproximateCoordinate(
        origin: origin,
        seed: 'plan-1-kadikoy',
        distanceKm: 1.2,
      );

      expect(first.latitude, second.latitude);
      expect(first.longitude, second.longitude);
    });

    test('keeps projected coordinates within privacy-safe nearby bounds', () {
      const origin = ApproximateCoordinate(
        latitude: 41.0082,
        longitude: 28.9784,
      );

      final projected = projectApproximateCoordinate(
        origin: origin,
        seed: 'plan-2-moda',
        distanceKm: 4.7,
      );

      expect((projected.latitude - origin.latitude).abs(), lessThan(0.04));
      expect((projected.longitude - origin.longitude).abs(), lessThan(0.04));
    });
  });
}
