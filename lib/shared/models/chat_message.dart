class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderUserId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String threadId;
  final String senderUserId;
  final String text;
  final DateTime sentAt;

  String get trimmedText => text.trim();

  bool get hasText => trimmedText.isNotEmpty;
}
