class AppSession {
  const AppSession({
    required this.isAuthenticated,
    required this.isOnboardingComplete,
    this.userId,
  });

  const AppSession.signedOut()
      : isAuthenticated = false,
        isOnboardingComplete = false,
        userId = null;

  final bool isAuthenticated;
  final bool isOnboardingComplete;
  final String? userId;

  AppSession copyWith({
    bool? isAuthenticated,
    bool? isOnboardingComplete,
    String? userId,
    bool clearUserId = false,
  }) {
    return AppSession(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      userId: clearUserId ? null : (userId ?? this.userId),
    );
  }
}
