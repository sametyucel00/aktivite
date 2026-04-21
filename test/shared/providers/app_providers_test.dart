import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/features/monetization/data/monetization_repository.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:aktivite/features/activities/data/activity_repository.dart';
import 'package:aktivite/features/chat/data/chat_repository.dart';
import 'package:aktivite/features/explore/application/explore_controller.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canCreatePlansProvider derives from profile helper', () async {
    const profile = AppUserProfile(
      id: 'user-1',
      displayName: 'Samet',
      profilePhotoUrl: '',
      city: 'Istanbul',
      bio: 'Coffee and walks',
      profileCompletion: 75,
      favoriteActivities: [ActivityCategory.coffee],
      activeTimes: [AvailabilitySlot.evenings],
      groupPreference: GroupPreference.flexible,
      socialMood: SocialMood.casual,
      verificationLabel: 'phone',
      verificationLevel: VerificationLevel.phone,
    );

    final container = ProviderContainer(
      overrides: [
        currentUserProfileProvider.overrideWith((ref) => Stream.value(profile)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(currentUserProfileProvider.future);

    expect(container.read(canCreatePlansProvider).valueOrNull, isTrue);
    expect(container.read(profileCompletionProvider).valueOrNull, 75);
  });

  test('featuredPlansProvider hides plans from blocked owners', () async {
    final container = ProviderContainer(
      overrides: [
        activityRepositoryProvider.overrideWithValue(
          _StaticActivityRepository([
            ActivityPlan(
              id: 'plan-open',
              ownerUserId: 'guest-open',
              title: 'Visible',
              category: ActivityCategory.coffee,
              description: 'Visible plan',
              city: 'Istanbul',
              approximateLocation: 'Kadikoy',
              timeLabel: 'Tonight',
              scheduledAt: DateTime(2026, 4, 19, 20),
              durationMinutes: 60,
              participantCount: 1,
              maxParticipants: 4,
              isIndoor: true,
              status: ActivityStatus.open,
              surfaces: const [DiscoverySurface.tonight],
            ),
            ActivityPlan(
              id: 'plan-blocked',
              ownerUserId: 'guest-blocked',
              title: 'Hidden',
              category: ActivityCategory.walk,
              description: 'Blocked owner plan',
              city: 'Istanbul',
              approximateLocation: 'Moda',
              timeLabel: 'Now',
              scheduledAt: DateTime(2026, 4, 19, 18),
              durationMinutes: 45,
              participantCount: 1,
              maxParticipants: 4,
              isIndoor: false,
              status: ActivityStatus.open,
              surfaces: const [DiscoverySurface.now],
            ),
          ]),
        ),
        blockedUserIdsProvider.overrideWith(
          (ref) => const AsyncValue.data({'guest-blocked'}),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(allPlansProvider.future);
    final plans = container.read(featuredPlansProvider).valueOrNull;

    expect(
        plans?.map((plan) => plan.id).toList(growable: false), ['plan-open']);
  });

  test('chatThreadsProvider hides threads tied to blocked users', () async {
    final container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(
          _StaticChatRepository(
            const [
              ChatThread(
                id: 'thread-visible',
                activityId: 'plan-1',
                participantIds: ['demo-user', 'guest-open'],
                lastMessagePreview: 'Visible thread',
                safetyBannerVisible: true,
              ),
              ChatThread(
                id: 'thread-hidden',
                activityId: 'plan-2',
                participantIds: ['demo-user', 'guest-blocked'],
                lastMessagePreview: 'Hidden thread',
                safetyBannerVisible: true,
              ),
            ],
          ),
        ),
        blockedUserIdsProvider.overrideWith(
          (ref) => const AsyncValue.data({'guest-blocked'}),
        ),
        currentUserIdProvider.overrideWith((ref) => 'demo-user'),
      ],
    );
    addTearDown(container.dispose);

    await container.read(rawChatThreadsProvider.future);
    expect(
      container.read(chatThreadsProvider).valueOrNull?.single.id,
      'thread-visible',
    );
  });

  test('filteredPlansProvider applies surface category and distance filters',
      () async {
    final container = ProviderContainer(
      overrides: [
        activityRepositoryProvider.overrideWithValue(
          _StaticActivityRepository([
            ActivityPlan(
              id: 'near-coffee',
              ownerUserId: 'guest-near',
              title: 'Near coffee',
              category: ActivityCategory.coffee,
              description: 'Close enough',
              city: 'Istanbul',
              approximateLocation: 'Kadikoy',
              timeLabel: 'Tonight',
              scheduledAt: DateTime(2026, 4, 19, 20),
              durationMinutes: 60,
              participantCount: 1,
              maxParticipants: 4,
              distanceKm: 2,
              isIndoor: true,
              status: ActivityStatus.open,
              surfaces: const [DiscoverySurface.tonight],
            ),
            ActivityPlan(
              id: 'far-coffee',
              ownerUserId: 'guest-far',
              title: 'Far coffee',
              category: ActivityCategory.coffee,
              description: 'Too far for this filter',
              city: 'Istanbul',
              approximateLocation: 'Besiktas',
              timeLabel: 'Tonight',
              scheduledAt: DateTime(2026, 4, 19, 21),
              durationMinutes: 60,
              participantCount: 1,
              maxParticipants: 4,
              distanceKm: 8,
              isIndoor: true,
              status: ActivityStatus.open,
              surfaces: const [DiscoverySurface.tonight],
            ),
          ]),
        ),
        currentUserProfileProvider.overrideWith(
          (ref) => const Stream<AppUserProfile>.empty(),
        ),
        monetizationRepositoryProvider.overrideWithValue(
          _StaticMonetizationRepository(
            const UserEntitlement(
              userId: 'demo-user',
              tier: PremiumTier.free,
              boostCredits: 0,
              rewardedExtraSlots: 0,
            ),
          ),
        ),
        currentUserIdProvider.overrideWith((ref) => 'demo-user'),
      ],
    );
    addTearDown(container.dispose);

    await container.read(allPlansProvider.future);
    container
        .read(exploreControllerProvider.notifier)
        .setSurface(DiscoverySurface.tonight);
    container
        .read(exploreControllerProvider.notifier)
        .setCategory(ActivityCategory.coffee);
    container
        .read(exploreControllerProvider.notifier)
        .setDistanceFilter(DiscoveryDistanceFilter.three);

    expect(
      container
          .read(filteredPlansProvider)
          .valueOrNull
          ?.map((plan) => plan.id)
          .toList(growable: false),
      ['near-coffee'],
    );
  });

  test('filteredPlansProvider ranks active boosted plans above regular ones',
      () async {
    final container = ProviderContainer(
      overrides: [
        activityRepositoryProvider.overrideWithValue(
          _StaticActivityRepository([
            ActivityPlan(
              id: 'regular',
              ownerUserId: 'guest-1',
              title: 'Regular plan',
              category: ActivityCategory.coffee,
              description: 'Standard visibility',
              city: 'Istanbul',
              approximateLocation: 'Kadikoy',
              timeLabel: 'Tonight',
              scheduledAt: DateTime(2026, 4, 19, 20),
              durationMinutes: 60,
              participantCount: 1,
              maxParticipants: 4,
              isIndoor: true,
              status: ActivityStatus.open,
              surfaces: const [DiscoverySurface.nearby],
            ),
            ActivityPlan(
              id: 'boosted',
              ownerUserId: 'guest-2',
              title: 'Boosted plan',
              category: ActivityCategory.coffee,
              description: 'Boosted visibility',
              city: 'Istanbul',
              approximateLocation: 'Moda',
              timeLabel: 'Tonight',
              scheduledAt: DateTime(2026, 4, 19, 20),
              durationMinutes: 60,
              participantCount: 1,
              maxParticipants: 4,
              boostLevel: 1,
              boostExpiresAt: DateTime.now().add(const Duration(hours: 2)),
              isIndoor: true,
              status: ActivityStatus.open,
              surfaces: const [DiscoverySurface.nearby],
            ),
          ]),
        ),
        currentUserProfileProvider.overrideWith(
          (ref) => const Stream<AppUserProfile>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(allPlansProvider.future);

    expect(
      container
          .read(filteredPlansProvider)
          .valueOrNull
          ?.map((plan) => plan.id)
          .toList(growable: false),
      ['boosted', 'regular'],
    );
  });
}

class _StaticActivityRepository implements ActivityRepository {
  _StaticActivityRepository(this._plans);

  final List<ActivityPlan> _plans;

  @override
  Future<void> createPlan(ActivityPlan plan) async {}

  @override
  Future<void> incrementParticipantCount(String activityId) async {}

  @override
  Future<void> applyBoost({
    required String activityId,
    required DateTime expiresAt,
    int boostLevel = 1,
  }) async {}

  @override
  Stream<List<ActivityPlan>> watchNearbyPlans() => Stream.value(_plans);
}

class _StaticChatRepository implements ChatRepository {
  _StaticChatRepository(this._threads);

  final List<ChatThread> _threads;

  @override
  Future<void> ensureThreadForActivity({
    required String activityId,
    required List<String> participantIds,
    required String initialMessagePreview,
  }) async {}

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String message,
  }) async {}

  @override
  Stream<List<ChatThread>> watchApprovedThreads() => Stream.value(_threads);

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) =>
      const Stream<List<ChatMessage>>.empty();
}

class _StaticMonetizationRepository implements MonetizationRepository {
  _StaticMonetizationRepository(this._entitlement);

  final UserEntitlement _entitlement;

  @override
  Stream<UserEntitlement> watchCurrentEntitlement(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    if (normalizedUserId.isEmpty) {
      return Stream.value(const UserEntitlement.free(userId: 'signed-out'));
    }
    return Stream.value(_entitlement.copyWith(userId: normalizedUserId));
  }
}
