enum DiscoveryDistanceFilter {
  any(null),
  one(1),
  three(3),
  five(5),
  ten(10),
  twentyFive(25);

  const DiscoveryDistanceFilter(this.maxKm);

  final int? maxKm;

  bool includes(double? distanceKm) {
    final limit = maxKm;
    if (limit == null || distanceKm == null) {
      return true;
    }
    return distanceKm <= limit;
  }
}
