import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreState {
  const ExploreState({
    required this.surface,
    required this.category,
  });

  const ExploreState.initial()
      : surface = DiscoverySurface.nearby,
        category = null;

  final DiscoverySurface surface;
  final ActivityCategory? category;

  ExploreState copyWith({
    DiscoverySurface? surface,
    ActivityCategory? category,
    bool clearCategory = false,
  }) {
    return ExploreState(
      surface: surface ?? this.surface,
      category: clearCategory ? null : (category ?? this.category),
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
}

final exploreControllerProvider =
    NotifierProvider<ExploreController, ExploreState>(
  ExploreController.new,
);
