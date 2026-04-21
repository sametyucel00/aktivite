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
    this.distanceKm,
    this.boostLevel = 0,
    this.boostExpiresAt,
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
  final double? distanceKm;
  final int boostLevel;
  final DateTime? boostExpiresAt;
  final bool isIndoor;
  final ActivityStatus status;
  final List<DiscoverySurface> surfaces;

  String get normalizedTitle => title.trim();

  String get normalizedDescription => description.trim();

  String get normalizedCity => city.trim();

  String get normalizedApproximateLocation => approximateLocation.trim();

  bool get isFull =>
      status == ActivityStatus.full || participantCount >= maxParticipants;

  bool get hasCapacity => !isFull;

  bool get isDiscoverable =>
      status == ActivityStatus.open || status == ActivityStatus.full;

  bool get hasValidIdentity =>
      id.trim().isNotEmpty && ownerUserId.trim().isNotEmpty;

  bool get hasValidCreateDetails =>
      normalizedTitle.isNotEmpty &&
      normalizedDescription.isNotEmpty &&
      normalizedCity.isNotEmpty &&
      normalizedApproximateLocation.isNotEmpty;

  bool get hasValidParticipantConfiguration =>
      participantCount >= 0 &&
      maxParticipants > 0 &&
      participantCount <= maxParticipants;

  bool get hasApproximateDistance => distanceKm != null && distanceKm! >= 0;

  bool hasActiveBoostAt(DateTime value) =>
      boostLevel > 0 &&
      boostExpiresAt != null &&
      boostExpiresAt!.isAfter(value);

  bool get canPublish =>
      hasValidIdentity &&
      hasValidCreateDetails &&
      hasValidParticipantConfiguration;

  bool get canAcceptJoinRequests =>
      status == ActivityStatus.open && participantCount < maxParticipants;

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
    Object? distanceKm = _unset,
    int? boostLevel,
    Object? boostExpiresAt = _unset,
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
      distanceKm: identical(distanceKm, _unset)
          ? this.distanceKm
          : distanceKm as double?,
      boostLevel: boostLevel ?? this.boostLevel,
      boostExpiresAt: identical(boostExpiresAt, _unset)
          ? this.boostExpiresAt
          : boostExpiresAt as DateTime?,
      isIndoor: isIndoor ?? this.isIndoor,
      status: status ?? this.status,
      surfaces: surfaces ?? this.surfaces,
    );
  }
}
