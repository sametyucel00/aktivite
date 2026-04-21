import 'package:aktivite/app/config/app_config.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/core/services/analytics_service.dart';
import 'package:aktivite/core/services/location_service.dart';
import 'package:aktivite/core/services/remote_config_service.dart';
import 'package:aktivite/core/services/notification_sync_service.dart';
import 'package:aktivite/features/activities/data/activity_repository.dart';
import 'package:aktivite/features/activities/data/join_request_repository.dart';
import 'package:aktivite/features/auth/data/auth_repository.dart';
import 'package:aktivite/features/chat/data/chat_repository.dart';
import 'package:aktivite/features/monetization/data/monetization_repository.dart';
import 'package:aktivite/features/monetization/services/purchase_service.dart';
import 'package:aktivite/features/monetization/services/rewarded_ads_service.dart';
import 'package:aktivite/features/profile/data/profile_repository.dart';
import 'package:aktivite/features/safety/data/moderation_repository.dart';
import 'package:aktivite/features/safety/data/safety_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aktivite/shared/providers/repository_factories.dart';

final repositorySourceProvider = Provider<RepositorySource>(
  (ref) => AppConfig.repositorySource,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => buildAuthRepository(ref.watch(repositorySourceProvider)),
);
final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => buildActivityRepository(ref.watch(repositorySourceProvider)),
);
final joinRequestRepositoryProvider = Provider<JoinRequestRepository>(
  (ref) => buildJoinRequestRepository(ref.watch(repositorySourceProvider)),
);
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => buildChatRepository(ref.watch(repositorySourceProvider)),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => buildProfileRepository(ref.watch(repositorySourceProvider)),
);
final monetizationRepositoryProvider = Provider<MonetizationRepository>(
  (ref) => buildMonetizationRepository(ref.watch(repositorySourceProvider)),
);
final safetyRepositoryProvider = Provider<SafetyRepository>(
  (ref) => buildSafetyRepository(ref.watch(repositorySourceProvider)),
);
final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => buildModerationRepository(ref.watch(repositorySourceProvider)),
);
final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => buildAnalyticsService(ref.watch(repositorySourceProvider)),
);
final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (ref) => buildRemoteConfigService(ref.watch(repositorySourceProvider)),
);
final rewardedAdsServiceProvider = Provider<RewardedAdsService>(
  (ref) => buildRewardedAdsService(),
);
final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) => buildPurchaseService(),
);
final notificationSyncServiceProvider = Provider<NotificationSyncService>(
  (ref) => NotificationSyncService(),
);
final locationServiceProvider = Provider<LocationService>(
  (ref) => const LocationService(),
);
