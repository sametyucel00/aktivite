import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/features/activities/presentation/activities_screen.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/auth/presentation/auth_gate_screen.dart';
import 'package:aktivite/features/chat/presentation/chat_screen.dart';
import 'package:aktivite/features/explore/presentation/explore_screen.dart';
import 'package:aktivite/features/map/presentation/map_screen.dart';
import 'package:aktivite/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aktivite/features/profile/presentation/profile_screen.dart';
import 'package:aktivite/features/safety/presentation/safety_screen.dart';
import 'package:aktivite/features/settings/presentation/settings_screen.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: AuthGateScreen.routePath,
    redirect: (context, state) {
      final location = state.uri.toString();
      final isAuthRoute = location == AuthGateScreen.routePath;
      final isOnboardingRoute = location == OnboardingScreen.routePath;

      if (!session.isAuthenticated) {
        return isAuthRoute ? null : AuthGateScreen.routePath;
      }

      if (!session.isOnboardingComplete) {
        return isOnboardingRoute ? null : OnboardingScreen.routePath;
      }

      if (isAuthRoute || isOnboardingRoute) {
        return ExploreScreen.routePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AuthGateScreen.routePath,
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: OnboardingScreen.routePath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: ExploreScreen.routePath,
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: ActivitiesScreen.routePath,
            builder: (context, state) => const ActivitiesScreen(),
          ),
          GoRoute(
            path: MapScreen.routePath,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: ChatScreen.routePath,
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: ProfileScreen.routePath,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: SafetyScreen.routePath,
        builder: (context, state) => const SafetyScreen(),
      ),
      GoRoute(
        path: SettingsScreen.routePath,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingJoinRequests =
        ref.watch(pendingJoinRequestsCountProvider).valueOrNull ?? 0;
    final chatThreadsCount = ref.watch(chatThreadsCountProvider);
    final tabs = [
      _AppShellTab(
        label: l10n.navExplore,
        icon: Icons.explore_outlined,
        path: AppRoutes.explore,
      ),
      _AppShellTab(
        label: l10n.navPlans,
        icon: Icons.add_circle_outline,
        path: AppRoutes.activities,
        badgeCount: pendingJoinRequests,
      ),
      _AppShellTab(
        label: l10n.navMap,
        icon: Icons.map_outlined,
        path: AppRoutes.map,
      ),
      _AppShellTab(
        label: l10n.navChat,
        icon: Icons.chat_bubble_outline,
        path: AppRoutes.chat,
        badgeCount: chatThreadsCount,
      ),
      _AppShellTab(
        label: l10n.navProfile,
        icon: Icons.person_outline,
        path: AppRoutes.profile,
      ),
    ];
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex =
        tabs.indexWhere((tab) => location.startsWith(tab.path));
    final selectedIndex = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: tabs
            .map(
              (tab) => NavigationDestination(
                icon: _TabIcon(
                  icon: tab.icon,
                  badgeCount: tab.badgeCount,
                ),
                label: tab.label,
              ),
            )
            .toList(),
        onDestinationSelected: (index) => context.go(tabs[index].path),
      ),
    );
  }
}

class _AppShellTab {
  const _AppShellTab({
    required this.label,
    required this.icon,
    required this.path,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final String path;
  final int badgeCount;
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.badgeCount,
  });

  final IconData icon;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (badgeCount > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
