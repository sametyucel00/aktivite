import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreState {
  const ExploreState({
    required this.surface,
    required this.category,
    required this.distanceFilter,
    required this.indoorOnly,
    required this.openSpotsOnly,
  });

  const ExploreState.initial()
      : surface = DiscoverySurface.nearby,
        category = null,
        distanceFilter = DiscoveryDistanceFilter.five,
        indoorOnly = false,
        openSpotsOnly = false;

  final DiscoverySurface surface;
  final ActivityCategory? category;
  final DiscoveryDistanceFilter distanceFilter;
  final bool indoorOnly;
  final bool openSpotsOnly;

  ExploreState copyWith({
    DiscoverySurface? surface,
    ActivityCategory? category,
    DiscoveryDistanceFilter? distanceFilter,
    bool? indoorOnly,
    bool? openSpotsOnly,
    bool clearCategory = false,
  }) {
    return ExploreState(
      surface: surface ?? this.surface,
      category: clearCategory ? null : (category ?? this.category),
      distanceFilter: distanceFilter ?? this.distanceFilter,
      indoorOnly: indoorOnly ?? this.indoorOnly,
      openSpotsOnly: openSpotsOnly ?? this.openSpotsOnly,
    );
  }
}

class ExploreController extends Notifier<ExploreState> {
  @override
  ExploreState build() {
    return const ExploreState.initial();
  }

  void setSurface(DiscoverySurface surface) {
    state = state.copyWith(surface: surface);
  }

  void setCategory(ActivityCategory? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
    );
  }

  void setDistanceFilter(DiscoveryDistanceFilter distanceFilter) {
    state = state.copyWith(distanceFilter: distanceFilter);
  }

  void resetFilters() {
    state = const ExploreState.initial();
  }

  void setIndoorOnly(bool value) {
    state = state.copyWith(indoorOnly: value);
  }

  void setOpenSpotsOnly(bool value) {
    state = state.copyWith(openSpotsOnly: value);
  }
}

final exploreControllerProvider =
    NotifierProvider<ExploreController, ExploreState>(
  ExploreController.new,
);
