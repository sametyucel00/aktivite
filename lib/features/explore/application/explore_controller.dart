import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreState {
  const ExploreState({
    required this.surface,
    required this.category,
    required this.distanceFilter,
  });

  const ExploreState.initial()
      : surface = DiscoverySurface.nearby,
        category = null,
        distanceFilter = DiscoveryDistanceFilter.any;

  final DiscoverySurface surface;
  final ActivityCategory? category;
  final DiscoveryDistanceFilter distanceFilter;

  ExploreState copyWith({
    DiscoverySurface? surface,
    ActivityCategory? category,
    DiscoveryDistanceFilter? distanceFilter,
    bool clearCategory = false,
  }) {
    return ExploreState(
      surface: surface ?? this.surface,
      category: clearCategory ? null : (category ?? this.category),
      distanceFilter: distanceFilter ?? this.distanceFilter,
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
}

final exploreControllerProvider =
    NotifierProvider<ExploreController, ExploreState>(
  ExploreController.new,
);
