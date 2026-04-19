import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatThread', () {
    const thread = ChatThread(
      id: 'thread-1',
      activityId: 'activity-1',
      participantIds: ['user-1', 'user-2'],
      lastMessagePreview: 'See you there',
      safetyBannerVisible: true,
    );

    test('exposes participant and banner helpers', () {
      expect(thread.participantsCount, 2);
      expect(thread.hasParticipants, isTrue);
      expect(thread.hasParticipant('user-1'), isTrue);
      expect(thread.hasParticipant('user-3'), isFalse);
      expect(thread.shouldShowSafetyBanner(true), isTrue);
      expect(thread.shouldShowSafetyBanner(false), isFalse);
    });

    test('copyWith updates selected values only', () {
      final updated = thread.copyWith(lastMessagePreview: 'Running late');

      expect(updated.lastMessagePreview, 'Running late');
      expect(updated.participantIds, thread.participantIds);
      expect(updated.activityId, thread.activityId);
    });
  });

  group('ChatMessage', () {
    final message = ChatMessage(
      id: 'message-1',
      threadId: 'thread-1',
      senderUserId: 'user-1',
      text: '  On my way  ',
      sentAt: DateTime.utc(2026, 4, 18, 18, 45),
    );

    test('trimmedText removes outer whitespace', () {
      expect(message.trimmedText, 'On my way');
      expect(message.hasText, isTrue);
    });

    test('normalizedText trims and clamps long messages', () {
      final long = ChatMessage(
        id: 'message-3',
        threadId: 'thread-1',
        senderUserId: 'user-1',
        text: ' ${'a' * 400} ',
        sentAt: DateTime.utc(2026, 4, 18, 18, 47),
      );

      expect(long.normalizedText.length, ChatMessage.maxTextLength);
      expect(long.exceedsMaxLength, isTrue);
    });

    test('hasText is false for blank messages', () {
      final blank = ChatMessage(
        id: 'message-2',
        threadId: 'thread-1',
        senderUserId: 'user-1',
        text: '   ',
        sentAt: DateTime.utc(2026, 4, 18, 18, 46),
      );

      expect(blank.trimmedText, '');
      expect(blank.hasText, isFalse);
    });
  });
}
