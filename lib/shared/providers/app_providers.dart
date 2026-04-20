import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/services/app_bootstrap_service.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/plan_matching.dart';
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

final onboardingCompletedProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionControllerProvider);
  if (!session.isAuthenticated) {
    return false;
  }

  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.maybeWhen(
    data: (profile) => profile.profileCompletion > 0,
    orElse: () => session.isOnboardingComplete,
  );
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
  final blockedUserIdsAsync = ref.watch(_blockedUserIdsStreamProvider);
  return blockedUserIdsAsync.whenData((blockedUserIds) => blockedUserIds);
});

final safetyActionSummaryProvider =
    Provider<AsyncValue<SafetyActionSummary>>((ref) {
  final blockedUserIdsAsync = ref.watch(_blockedUserIdsStreamProvider);
  final reportedReasonsAsync = ref.watch(_reportedReasonsByUserStreamProvider);

  return switch ((blockedUserIdsAsync, reportedReasonsAsync)) {
    (
      AsyncData(value: final blockedUserIds),
      AsyncData(value: final reportedReasonsByUser)
    ) =>
      AsyncValue.data(
        SafetyActionSummary(
          blockedCount: blockedUserIds.length,
          reportCount: reportedReasonsByUser.values
              .fold<int>(0, (total, reasons) => total + reasons.length),
        ),
      ),
    (AsyncError(:final error, :final stackTrace), _) =>
      AsyncValue.error(error, stackTrace),
    (_, AsyncError(:final error, :final stackTrace)) =>
      AsyncValue.error(error, stackTrace),
    _ => const AsyncValue.loading(),
  };
});

final _blockedUserIdsStreamProvider = StreamProvider<Set<String>>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return repository.watchBlockedUserIds();
});

final _reportedReasonsByUserStreamProvider =
    StreamProvider<Map<String, List<String>>>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return repository.watchReportedReasonsByUser();
});

final reportedReasonsByUserProvider =
    Provider<AsyncValue<Map<String, List<String>>>>((ref) {
  final reportedReasonsAsync = ref.watch(_reportedReasonsByUserStreamProvider);
  return reportedReasonsAsync.whenData(
    (reportedReasonsByUser) => reportedReasonsByUser,
  );
});

final allPlansProvider = StreamProvider<List<ActivityPlan>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchNearbyPlans();
});

final featuredPlansProvider = Provider<AsyncValue<List<ActivityPlan>>>((ref) {
  final plansAsync = ref.watch(allPlansProvider);
  final blockedUserIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
  return plansAsync.whenData(
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

final ownedPlansProvider = Provider<AsyncValue<List<ActivityPlan>>>((ref) {
  final plansAsync = ref.watch(allPlansProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const AsyncValue.data(<ActivityPlan>[]);
  }
  return plansAsync.whenData(
    (plans) => plans
        .where((plan) => plan.ownerUserId == currentUserId)
        .where((plan) => plan.isDiscoverable)
        .toList(growable: false),
  );
});

final ownedJoinRequestsByActivityProvider =
    Provider<AsyncValue<Map<String, List<JoinRequest>>>>((ref) {
  final ownedPlansAsync = ref.watch(ownedPlansProvider);
  return ownedPlansAsync.whenData((plans) {
    final requestsByActivity = <String, List<JoinRequest>>{};
    for (final plan in plans) {
      final currentRequests =
          ref.watch(joinRequestsProvider(plan.id)).valueOrNull;
      if (currentRequests == null) {
        continue;
      }
      requestsByActivity[plan.id] = List<JoinRequest>.unmodifiable(
        currentRequests,
      );
    }
    return Map<String, List<JoinRequest>>.unmodifiable(requestsByActivity);
  });
});

final safetyTargetUserIdsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final threadsAsync = ref.watch(chatThreadsProvider);
  final requestsByActivityAsync =
      ref.watch(ownedJoinRequestsByActivityProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  return switch ((threadsAsync, requestsByActivityAsync)) {
    (
      AsyncData(value: final threads),
      AsyncData(value: final requestsByActivity)
    ) =>
      AsyncValue.data(
        {
          for (final thread in threads)
            ...thread.participantIds.where(
              (participantId) =>
                  currentUserId != null && participantId != currentUserId,
            ),
          for (final requests in requestsByActivity.values)
            ...requests.map((request) => request.requesterId),
        }.where((userId) => userId.trim().isNotEmpty).toList(growable: false)
          ..sort(),
      ),
    (AsyncError(:final error, :final stackTrace), _) =>
      AsyncValue.error(error, stackTrace),
    (_, AsyncError(:final error, :final stackTrace)) =>
      AsyncValue.error(error, stackTrace),
    _ => const AsyncValue.loading(),
  };
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

final rawChatThreadsProvider = StreamProvider<List<ChatThread>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchApprovedThreads();
});

final chatThreadsProvider = Provider<AsyncValue<List<ChatThread>>>((ref) {
  final threadsAsync = ref.watch(rawChatThreadsProvider);
  final blockedUserIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
  final currentUserId = ref.watch(currentUserIdProvider);
  return threadsAsync.whenData(
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

final blockedChatThreadsCountProvider = Provider<AsyncValue<int>>((ref) {
  final rawThreadsAsync = ref.watch(rawChatThreadsProvider);
  final visibleThreadsAsync = ref.watch(chatThreadsProvider);

  return switch ((rawThreadsAsync, visibleThreadsAsync)) {
    (
      AsyncData(value: final rawThreads),
      AsyncData(value: final visibleThreads)
    ) =>
      AsyncValue.data(rawThreads.length - visibleThreads.length),
    (AsyncError(:final error, :final stackTrace), _) =>
      AsyncValue.error(error, stackTrace),
    (_, AsyncError(:final error, :final stackTrace)) =>
      AsyncValue.error(error, stackTrace),
    _ => const AsyncValue.loading(),
  };
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
  final requestsByActivityAsync =
      ref.watch(ownedJoinRequestsByActivityProvider);
  return requestsByActivityAsync.whenData((requestsByActivity) {
    final requests = <JoinRequest>[];
    for (final currentRequests in requestsByActivity.values) {
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
