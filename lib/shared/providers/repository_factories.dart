import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/core/services/analytics_service.dart';
import 'package:aktivite/core/services/firebase_analytics_service.dart';
import 'package:aktivite/core/services/firebase_remote_config_service.dart';
import 'package:aktivite/core/services/in_memory_analytics_service.dart';
import 'package:aktivite/core/services/in_memory_remote_config_service.dart';
import 'package:aktivite/core/services/remote_config_service.dart';
import 'package:aktivite/features/activities/data/activity_repository.dart';
import 'package:aktivite/features/activities/data/firestore_activity_repository.dart';
import 'package:aktivite/features/activities/data/firestore_join_request_repository.dart';
import 'package:aktivite/features/activities/data/in_memory_activity_repository.dart';
import 'package:aktivite/features/activities/data/in_memory_join_request_repository.dart';
import 'package:aktivite/features/activities/data/join_request_repository.dart';
import 'package:aktivite/features/auth/data/auth_repository.dart';
import 'package:aktivite/features/auth/data/firebase_auth_repository.dart';
import 'package:aktivite/features/auth/data/in_memory_auth_repository.dart';
import 'package:aktivite/features/chat/data/chat_repository.dart';
import 'package:aktivite/features/chat/data/firestore_chat_repository.dart';
import 'package:aktivite/features/chat/data/in_memory_chat_repository.dart';
import 'package:aktivite/features/profile/data/firestore_profile_repository.dart';
import 'package:aktivite/features/profile/data/in_memory_profile_repository.dart';
import 'package:aktivite/features/profile/data/profile_repository.dart';
import 'package:aktivite/features/monetization/data/firestore_monetization_repository.dart';
import 'package:aktivite/features/monetization/data/in_memory_monetization_repository.dart';
import 'package:aktivite/features/monetization/data/monetization_repository.dart';
import 'package:aktivite/features/monetization/services/purchase_service.dart';
import 'package:aktivite/features/monetization/services/rewarded_ads_service.dart';
import 'package:aktivite/features/safety/data/firestore_moderation_repository.dart';
import 'package:aktivite/features/safety/data/firestore_safety_repository.dart';
import 'package:aktivite/features/safety/data/in_memory_moderation_repository.dart';
import 'package:aktivite/features/safety/data/in_memory_safety_repository.dart';
import 'package:aktivite/features/safety/data/moderation_repository.dart';
import 'package:aktivite/features/safety/data/safety_repository.dart';

AuthRepository buildAuthRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryAuthRepository();
    case RepositorySource.firebase:
      return FirebaseAuthRepository();
  }
}

ActivityRepository buildActivityRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryActivityRepository();
    case RepositorySource.firebase:
      return FirestoreActivityRepository();
  }
}

JoinRequestRepository buildJoinRequestRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryJoinRequestRepository();
    case RepositorySource.firebase:
      return FirestoreJoinRequestRepository();
  }
}

ChatRepository buildChatRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryChatRepository();
    case RepositorySource.firebase:
      return FirestoreChatRepository();
  }
}

ProfileRepository buildProfileRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryProfileRepository();
    case RepositorySource.firebase:
      return FirestoreProfileRepository();
  }
}

MonetizationRepository buildMonetizationRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryMonetizationRepository();
    case RepositorySource.firebase:
      return FirestoreMonetizationRepository();
  }
}

SafetyRepository buildSafetyRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemorySafetyRepository();
    case RepositorySource.firebase:
      return FirestoreSafetyRepository();
  }
}

ModerationRepository buildModerationRepository(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryModerationRepository();
    case RepositorySource.firebase:
      return FirestoreModerationRepository();
  }
}

AnalyticsService buildAnalyticsService(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryAnalyticsService();
    case RepositorySource.firebase:
      return FirebaseAnalyticsService();
  }
}

RemoteConfigService buildRemoteConfigService(RepositorySource source) {
  switch (source) {
    case RepositorySource.inMemory:
      return InMemoryRemoteConfigService();
    case RepositorySource.firebase:
      return FirebaseRemoteConfigService();
  }
}

RewardedAdsService buildRewardedAdsService() {
  return GoogleMobileRewardedAdsService();
}

PurchaseService buildPurchaseService() {
  return PlaceholderPurchaseService();
}
