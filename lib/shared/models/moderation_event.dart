class ModerationEvent {
  const ModerationEvent({
    required this.id,
    required this.subjectUserId,
    required this.reasonCode,
    required this.isUserVisible,
    required this.createdAt,
  });

  final String id;
  final String subjectUserId;
  final String reasonCode;
  final bool isUserVisible;
  final DateTime createdAt;
}
