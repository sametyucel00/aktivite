import 'dart:math' as math;

class ApproximateCoordinate {
  const ApproximateCoordinate({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

ApproximateCoordinate projectApproximateCoordinate({
  required ApproximateCoordinate origin,
  required String seed,
  double? distanceKm,
}) {
  final normalizedSeed = seed.trim();
  final hash = normalizedSeed.codeUnits.fold<int>(
    17,
    (value, codeUnit) => value * 37 + codeUnit,
  );
  final angleRadians = ((hash % 360) * math.pi) / 180.0;
  final projectedDistanceKm = distanceKm == null
      ? 0.35 + ((hash % 18) / 10.0)
      : distanceKm.clamp(0.35, 3.2);
  final distanceMeters = projectedDistanceKm * 1000;

  final latitudeOffset = (distanceMeters * math.cos(angleRadians)) / 111320.0;
  final longitudeScale =
      math.cos(origin.latitude * math.pi / 180.0).abs().clamp(0.2, 1.0);
  final longitudeOffset =
      (distanceMeters * math.sin(angleRadians)) / (111320.0 * longitudeScale);

  return ApproximateCoordinate(
    latitude: origin.latitude + latitudeOffset,
    longitude: origin.longitude + longitudeOffset,
  );
}
