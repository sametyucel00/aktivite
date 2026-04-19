import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/auth/data/in_memory_auth_repository.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> pumpTestApp(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const <Override>[],
  bool signedIn = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(InMemoryAuthRepository()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  if (signedIn) {
    await container.read(sessionControllerProvider.notifier).signInDemo();
    container.read(sessionControllerProvider.notifier).completeOnboarding();
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
        ],
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

String currentUserId() => SampleIds.currentUser;
