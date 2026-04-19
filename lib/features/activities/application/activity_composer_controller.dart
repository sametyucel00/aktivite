import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/utils/activity_composer_validation.dart';
import 'package:aktivite/core/utils/app_time.dart';
import 'package:aktivite/features/activities/data/activity_repository.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityComposerState {
  const ActivityComposerState({
    required this.title,
    required this.description,
    required this.city,
    required this.approximateLocation,
    required this.category,
    required this.timeOption,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.isIndoor,
  });

  ActivityComposerState.initial()
      : title = '',
        description = '',
        city = 'Istanbul',
        approximateLocation = '',
        category = ActivityCategory.coffee,
        timeOption = PlanTimeOption.tonight,
        scheduledAt = _initialScheduledAt,
        durationMinutes = 60,
        isIndoor = true;

  final String title;
  final String description;
  final String city;
  final String approximateLocation;
  final ActivityCategory category;
  final PlanTimeOption timeOption;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool isIndoor;

  ActivityComposerValidationIssue? get validationIssue {
    return validateActivityComposer(
      title: title,
      description: description,
      city: city,
      approximateLocation: approximateLocation,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
    );
  }

  bool get canSubmit => validationIssue == null;

  ActivityComposerState copyWith({
    String? title,
    String? description,
    String? city,
    String? approximateLocation,
    ActivityCategory? category,
    PlanTimeOption? timeOption,
    DateTime? scheduledAt,
    int? durationMinutes,
    bool? isIndoor,
  }) {
    return ActivityComposerState(
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      approximateLocation: approximateLocation ?? this.approximateLocation,
      category: category ?? this.category,
      timeOption: timeOption ?? this.timeOption,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isIndoor: isIndoor ?? this.isIndoor,
    );
  }
}

DateTime get _initialScheduledAt =>
    DateTime.now().add(const Duration(hours: 3));

class ActivityComposerController extends Notifier<ActivityComposerState> {
  @override
  ActivityComposerState build() {
    return ActivityComposerState.initial();
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setCity(String value) {
    state = state.copyWith(city: value);
  }

  void setApproximateLocation(String value) {
    state = state.copyWith(approximateLocation: value);
  }

  void setCategory(ActivityCategory value) {
    state = state.copyWith(category: value);
  }

  void setTimeOption(PlanTimeOption value) {
    state = state.copyWith(timeOption: value);
  }

  void setScheduledAt(DateTime value) {
    state = state.copyWith(scheduledAt: value);
  }

  void setDurationMinutes(int value) {
    state = state.copyWith(durationMinutes: value);
  }

  void setIsIndoor(bool value) {
    state = state.copyWith(isIndoor: value);
  }

  Future<void> submit(
    ActivityRepository repository, {
    required String timeLabel,
  }) async {
    if (!state.canSubmit) {
      return;
    }

    final title = state.title.trim();
    final plan = ActivityPlan(
      id: AppIdFactory.timestampValue(),
      ownerUserId: SampleIds.currentUser,
      title: title,
      category: state.category,
      description: state.description.trim(),
      city: state.city.trim(),
      approximateLocation: state.approximateLocation.trim(),
      timeLabel: timeLabel,
      timeOption: state.timeOption,
      scheduledAt: state.scheduledAt,
      durationMinutes: state.durationMinutes,
      participantCount: 1,
      maxParticipants: 4,
      isIndoor: state.isIndoor,
      status: ActivityStatus.open,
      surfaces: _buildSurfaces(),
    );
    await repository.createPlan(plan);
    state = ActivityComposerState.initial();
  }

  List<DiscoverySurface> _buildSurfaces() {
    final surfaces = <DiscoverySurface>[DiscoverySurface.nearby];
    switch (state.timeOption) {
      case PlanTimeOption.now:
        surfaces.add(DiscoverySurface.now);
        break;
      case PlanTimeOption.tonight:
        surfaces.add(DiscoverySurface.tonight);
        break;
      case PlanTimeOption.weekend:
        surfaces.add(DiscoverySurface.weekend);
        break;
    }

    if (state.category == ActivityCategory.games ||
        state.category == ActivityCategory.event ||
        state.category == ActivityCategory.sports) {
      surfaces.add(DiscoverySurface.groups);
    }

    return surfaces.toSet().toList(growable: false);
  }
}

List<int> activityDurationOptions() => defaultActivityDurationOptions;

final activityComposerControllerProvider =
    NotifierProvider<ActivityComposerController, ActivityComposerState>(
  ActivityComposerController.new,
);
