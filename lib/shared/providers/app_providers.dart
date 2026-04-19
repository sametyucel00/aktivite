import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/services/app_bootstrap_service.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/plan_matching.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/explore/application/explore_controller.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/analytics_event_record.dart';
import 'package:aktivite/shared/models/analytics_signal_summary.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/join_request_summary.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:aktivite/shared/models/safety_action_summary.dart';
import 'package:aktivite/shared/models/trust_signal.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appBootstrapProvider = Provider((ref) => const AppBootstrapService());

final currentUserProfileProvider = StreamProvider<AppUserProfile>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchCurrentProfile();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionControllerProvider).userId;
});

final profileCompletionProvider = Provider<AsyncValue<int>>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.whenData((profile) => profile.profileCompletion);
});

final canCreatePlansProvider = Provider<AsyncValue<bool>>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.whenData((profile) => profile.canCreatePlans);
});

final currentUserModerationEventsProvider =
    StreamProvider<List<ModerationEvent>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(const <ModerationEvent>[]);
  }
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.watchTrustEvents(userId);
});

final blockedUserIdsProvider = Provider<AsyncValue<Set<String>>>((ref) {
  final eventsAsync = ref.watch(currentUserModerationEventsProvider);
  return eventsAsync.whenData((events) {
    return events
        .where(isUserBlockedTrustEvent)
        .map((event) => TrustEventReasonCodes.targetUserId(event.reasonCode))
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
  });
});

final safetyActionSummaryProvider =
    Provider<AsyncValue<SafetyActionSummary>>((ref) {
  final eventsAsync = ref.watch(currentUserModerationEventsProvider);
  return eventsAsync.whenData((events) {
    final blockedEvents =
        events.where(isUserBlockedTrustEvent).toList(growable: false);
    final reportEvents =
        events.where(isReportSubmittedTrustEvent).toList(growable: false);

    return SafetyActionSummary(
      blockedCount: blockedEvents.length,
      reportCount: reportEvents.length,
      hasBlockedGuestUser: blockedEvents.any(
        (event) =>
            event.reasonCode ==
            TrustEventReasonCodes.userBlockedFor(
              TrustEventReasonCodes.guestUserId,
            ),
      ),
      hasReportedGuestUser: reportEvents.any(
        (event) =>
            event.reasonCode ==
            TrustEventReasonCodes.reportSubmittedFor(
              TrustEventReasonCodes.guestUserId,
            ),
      ),
    );
  });
});

final featuredPlansProvider = StreamProvider<List<ActivityPlan>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  final blockedUserIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
  return repository.watchNearbyPlans().map(
        (plans) => plans
            .where((plan) => plan.isDiscoverable)
            .where((plan) => !blockedUserIds.contains(plan.ownerUserId))
            .toList(growable: false)
          ..sort((left, right) {
            if (left.status == right.status) {
              return 0;
            }
            if (left.status == ActivityStatus.open) {
              return -1;
            }
            if (right.status == ActivityStatus.open) {
              return 1;
            }
            return 0;
          }),
      );
});

final ownedPlansProvider = StreamProvider<List<ActivityPlan>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value(const <ActivityPlan>[]);
  }
  return repository.watchNearbyPlans().map(
        (plans) => plans
            .where((plan) => plan.ownerUserId == currentUserId)
            .where((plan) => plan.isDiscoverable)
            .toList(growable: false),
      );
});

final filteredPlansProvider = Provider<AsyncValue<List<ActivityPlan>>>((ref) {
  final exploreState = ref.watch(exploreControllerProvider);
  final plansAsync = ref.watch(featuredPlansProvider);
  final profileAsync = ref.watch(currentUserProfileProvider);

  return plansAsync.whenData((plans) {
    final filtered = plans
        .where((plan) => plan.surfaces.contains(exploreState.surface))
        .where(
          (plan) =>
              exploreState.category == null ||
              plan.category == exploreState.category,
        )
        .toList(growable: true);

    final profile = profileAsync.valueOrNull;
    if (profile == null) {
      return List<ActivityPlan>.unmodifiable(filtered);
    }

    filtered.sort(
      (left, right) => planMatchScore(profile, right)
          .compareTo(planMatchScore(profile, left)),
    );
    return List<ActivityPlan>.unmodifiable(filtered);
  });
});

final recommendedPlansProvider =
    Provider<AsyncValue<List<ActivityPlan>>>((ref) {
  final plansAsync = ref.watch(featuredPlansProvider);
  final profileAsync = ref.watch(currentUserProfileProvider);

  return plansAsync.whenData((plans) {
    final ranked = [...plans];
    final profile = profileAsync.valueOrNull;
    if (profile == null) {
      return List<ActivityPlan>.unmodifiable(ranked);
    }

    ranked.sort(
      (left, right) => planMatchScore(profile, right)
          .compareTo(planMatchScore(profile, left)),
    );
    return List<ActivityPlan>.unmodifiable(ranked);
  });
});

final analyticsEventsProvider =
    StreamProvider<List<AnalyticsEventRecord>>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  return analytics.watchEvents();
});

final analyticsSignalSummaryProvider =
    Provider<AsyncValue<AnalyticsSignalSummary>>((ref) {
  final eventsAsync = ref.watch(analyticsEventsProvider);
  return eventsAsync.whenData((events) {
    final recentEvents = events.take(12).toList(growable: false);
    return AnalyticsSignalSummary(
      authActions: recentEvents
          .where((event) => AnalyticsEvents.isAuthAction(event.name))
          .length,
      safetyActions: recentEvents
          .where((event) => AnalyticsEvents.isSafetyAction(event.name))
          .length,
      coordinationActions: recentEvents
          .where((event) => AnalyticsEvents.isCoordinationAction(event.name))
          .length,
    );
  });
});

final chatThreadsProvider = StreamProvider<List<ChatThread>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final blockedUserIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
  final currentUserId = ref.watch(currentUserIdProvider);
  return repository.watchApprovedThreads().map(
        (threads) => threads
            .where(
              (thread) => !thread.participantIds.any(
                (participantId) =>
                    participantId != currentUserId &&
                    blockedUserIds.contains(participantId),
              ),
            )
            .toList(growable: false),
      );
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, threadId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(threadId);
});

final joinRequestsProvider =
    StreamProvider.family<List<JoinRequest>, String>((ref, activityId) {
  final repository = ref.watch(joinRequestRepositoryProvider);
  return repository.watchRequestsForActivity(activityId);
});

final ownedJoinRequestsProvider =
    Provider<AsyncValue<List<JoinRequest>>>((ref) {
  final ownedPlansAsync = ref.watch(ownedPlansProvider);
  return ownedPlansAsync.whenData((plans) {
    final requests = <JoinRequest>[];
    for (final plan in plans) {
      final currentRequests =
          ref.watch(joinRequestsProvider(plan.id)).valueOrNull;
      if (currentRequests == null) {
        continue;
      }
      requests.addAll(currentRequests);
    }
    return List<JoinRequest>.unmodifiable(requests);
  });
});

final pendingJoinRequestsCountProvider = Provider<AsyncValue<int>>((ref) {
  final requestsAsync = ref.watch(ownedJoinRequestsProvider);
  return requestsAsync.whenData((requests) {
    return JoinRequestSummary.fromRequests(requests).pending;
  });
});

final joinRequestSummaryProvider =
    Provider<AsyncValue<JoinRequestSummary>>((ref) {
  final requestsAsync = ref.watch(ownedJoinRequestsProvider);
  return requestsAsync.whenData((requests) {
    return JoinRequestSummary.fromRequests(requests);
  });
});

final moderationEventsProvider =
    StreamProvider.family<List<ModerationEvent>, String>((ref, userId) {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.watchTrustEvents(userId);
});

final mapPrivacyModeProvider = Provider<MapPrivacyMode>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return mapPrivacyMode(remoteConfig);
});

final effectiveMapPrivacyProvider = Provider<MapPrivacyMode>((ref) {
  final preferences = ref.watch(settingsControllerProvider);
  if (preferences.hidesMapLocation) {
    return MapPrivacyMode.hidden;
  }
  return ref.watch(mapPrivacyModeProvider);
});

final activePlansLimitProvider = Provider<int>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return activePlansLimit(remoteConfig);
});

final safetyBannerEnabledProvider = Provider<bool>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return safetyBannerEnabled(remoteConfig);
});

final primaryActivityIdProvider = Provider<String?>((ref) {
  final plans = ref.watch(ownedPlansProvider).valueOrNull;
  if (plans == null || plans.isEmpty) {
    return null;
  }
  return plans.first.id;
});

final primaryOwnedPlanProvider = Provider<ActivityPlan?>((ref) {
  final plans = ref.watch(ownedPlansProvider).valueOrNull;
  if (plans == null || plans.isEmpty) {
    return null;
  }
  return plans.first;
});

final primaryChatThreadIdProvider = Provider<String?>((ref) {
  final threads = ref.watch(chatThreadsProvider).valueOrNull;
  if (threads == null || threads.isEmpty) {
    return null;
  }
  return threads.first.id;
});

final primaryChatThreadProvider = Provider<ChatThread?>((ref) {
  final threads = ref.watch(chatThreadsProvider).valueOrNull;
  if (threads == null || threads.isEmpty) {
    return null;
  }
  return threads.first;
});

final chatThreadsCountProvider = Provider<int>((ref) {
  final threads = ref.watch(chatThreadsProvider).valueOrNull;
  return threads?.length ?? 0;
});

final trustSignalsProvider = Provider<List<TrustSignal>>((ref) {
  return const [
    TrustSignal(
      id: 'approximateLocation',
    ),
    TrustSignal(
      id: 'approvalBeforeChat',
    ),
    TrustSignal(
      id: 'safetyTools',
    ),
  ];
});
