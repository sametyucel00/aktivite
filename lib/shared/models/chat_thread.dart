class ChatThread {
  const ChatThread({
    required this.id,
    required this.activityId,
    required this.participantIds,
    required this.lastMessagePreview,
    required this.safetyBannerVisible,
  });

  final String id;
  final String activityId;
  final List<String> participantIds;
  final String lastMessagePreview;
  final bool safetyBannerVisible;

  int get participantsCount => participantIds.length;

  bool get hasParticipants => participantIds.isNotEmpty;

  bool hasParticipant(String? userId) {
    return userId != null && participantIds.contains(userId);
  }

  bool shouldShowSafetyBanner(bool safetyBannerEnabled) {
    return safetyBannerVisible && safetyBannerEnabled;
  }

  ChatThread copyWith({
    String? id,
    String? activityId,
    List<String>? participantIds,
    String? lastMessagePreview,
    bool? safetyBannerVisible,
  }) {
    return ChatThread(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      participantIds: participantIds ?? this.participantIds,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      safetyBannerVisible: safetyBannerVisible ?? this.safetyBannerVisible,
    );
  }
}
