import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('repository providers', () {
    test('default source resolves in-memory implementations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(repositorySourceProvider),
        RepositorySource.inMemory,
      );
      expect(
        container.read(authRepositoryProvider).runtimeType.toString(),
        'InMemoryAuthRepository',
      );
      expect(
        container.read(activityRepositoryProvider).runtimeType.toString(),
        'InMemoryActivityRepository',
      );
      expect(
        container.read(joinRequestRepositoryProvider).runtimeType.toString(),
        'InMemoryJoinRequestRepository',
      );
      expect(
        container.read(chatRepositoryProvider).runtimeType.toString(),
        'InMemoryChatRepository',
      );
      expect(
        container.read(profileRepositoryProvider).runtimeType.toString(),
        'InMemoryProfileRepository',
      );
      expect(
        container.read(safetyRepositoryProvider).runtimeType.toString(),
        'InMemorySafetyRepository',
      );
      expect(
        container.read(moderationRepositoryProvider).runtimeType.toString(),
        'InMemoryModerationRepository',
      );
      expect(
        container.read(analyticsServiceProvider).runtimeType.toString(),
        'InMemoryAnalyticsService',
      );
      expect(
        container.read(remoteConfigServiceProvider).runtimeType.toString(),
        'InMemoryRemoteConfigService',
      );
    });

    test('overriding repository source to firebase resolves firebase providers',
        () {
      final container = ProviderContainer(
        overrides: [
          repositorySourceProvider.overrideWith((ref) {
            return RepositorySource.firebase;
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(authRepositoryProvider).runtimeType.toString(),
        'FirebaseAuthRepository',
      );
      expect(
        container.read(activityRepositoryProvider).runtimeType.toString(),
        'FirestoreActivityRepository',
      );
      expect(
        container.read(joinRequestRepositoryProvider).runtimeType.toString(),
        'FirestoreJoinRequestRepository',
      );
      expect(
        container.read(chatRepositoryProvider).runtimeType.toString(),
        'FirestoreChatRepository',
      );
      expect(
        container.read(profileRepositoryProvider).runtimeType.toString(),
        'FirestoreProfileRepository',
      );
      expect(
        container.read(moderationRepositoryProvider).runtimeType.toString(),
        'FirestoreModerationRepository',
      );
      expect(
        container.read(safetyRepositoryProvider).runtimeType.toString(),
        'FirestoreSafetyRepository',
      );
      expect(
        container.read(analyticsServiceProvider).runtimeType.toString(),
        'FirebaseAnalyticsService',
      );
      expect(
        container.read(remoteConfigServiceProvider).runtimeType.toString(),
        'FirebaseRemoteConfigService',
      );
    });
  });
}
