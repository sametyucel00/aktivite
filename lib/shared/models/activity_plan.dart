import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';

const _unset = Object();

class ActivityPlan {
  const ActivityPlan({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.category,
    required this.description,
    required this.city,
    required this.approximateLocation,
    required this.timeLabel,
    this.timeOption,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.participantCount,
    required this.maxParticipants,
    required this.isIndoor,
    required this.status,
    required this.surfaces,
  });

  final String id;
  final String ownerUserId;
  final String title;
  final ActivityCategory category;
  final String description;
  final String city;
  final String approximateLocation;
  final String timeLabel;
  final PlanTimeOption? timeOption;
  final DateTime scheduledAt;
  final int durationMinutes;
  final int participantCount;
  final int maxParticipants;
  final bool isIndoor;
  final ActivityStatus status;
  final List<DiscoverySurface> surfaces;

  bool get isFull =>
      status == ActivityStatus.full || participantCount >= maxParticipants;

  bool get hasCapacity => !isFull;

  bool get isDiscoverable =>
      status == ActivityStatus.open || status == ActivityStatus.full;

  ActivityPlan copyWith({
    String? id,
    String? ownerUserId,
    String? title,
    ActivityCategory? category,
    String? description,
    String? city,
    String? approximateLocation,
    String? timeLabel,
    Object? timeOption = _unset,
    DateTime? scheduledAt,
    int? durationMinutes,
    int? participantCount,
    int? maxParticipants,
    bool? isIndoor,
    ActivityStatus? status,
    List<DiscoverySurface>? surfaces,
  }) {
    return ActivityPlan(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      city: city ?? this.city,
      approximateLocation: approximateLocation ?? this.approximateLocation,
      timeLabel: timeLabel ?? this.timeLabel,
      timeOption: identical(timeOption, _unset)
          ? this.timeOption
          : timeOption as PlanTimeOption?,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isIndoor: isIndoor ?? this.isIndoor,
      status: status ?? this.status,
      surfaces: surfaces ?? this.surfaces,
    );
  }
}
