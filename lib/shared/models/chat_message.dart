class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderUserId,
    required this.text,
    required this.sentAt,
  });

  static const maxTextLength = 280;

  final String id;
  final String threadId;
  final String senderUserId;
  final String text;
  final DateTime sentAt;

  String get trimmedText => text.trim();

  String get normalizedText => normalizeText(text);

  bool get hasText => normalizedText.isNotEmpty;

  bool get exceedsMaxLength => trimmedText.length > maxTextLength;

  static String normalizeText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.length <= maxTextLength) {
      return trimmed;
    }
    return trimmed.substring(0, maxTextLength);
  }
}
