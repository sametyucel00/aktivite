import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/chat/data/in_memory_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryChatRepository', () {
    test('watchApprovedThreads emits initial threads immediately', () async {
      final repository = InMemoryChatRepository();

      final threads = await repository.watchApprovedThreads().first;

      expect(threads, isNotEmpty);
      expect(threads.first.id, SampleIds.primaryThread);
    });

    test('watchMessages emits initial messages immediately', () async {
      final repository = InMemoryChatRepository();

      final messages =
          await repository.watchMessages(SampleIds.primaryThread).first;

      expect(messages, hasLength(2));
      expect(messages.last.text, 'Perfect, I will be there in 10 minutes.');
    });

    test('ensureThreadForActivity creates a new thread and initial message',
        () async {
      final repository = InMemoryChatRepository();

      await repository.ensureThreadForActivity(
        activityId: 'activity-2',
        participantIds: const [SampleIds.currentUser, SampleIds.guestTwo],
        initialMessagePreview: 'Thread created',
      );

      final threads = await repository.watchApprovedThreads().first;
      final created =
          threads.singleWhere((thread) => thread.activityId == 'activity-2');
      final messages = await repository.watchMessages(created.id).first;

      expect(created.lastMessagePreview, 'Thread created');
      expect(messages, hasLength(1));
      expect(messages.single.text, 'Thread created');
    });

    test('sendMessage updates last preview and appends message', () async {
      final repository = InMemoryChatRepository();

      await repository.sendMessage(
        threadId: SampleIds.primaryThread,
        senderUserId: SampleIds.currentUser,
        message: '  Running five minutes late.  ',
      );

      final threads = await repository.watchApprovedThreads().first;
      final thread =
          threads.singleWhere((item) => item.id == SampleIds.primaryThread);
      final messages =
          await repository.watchMessages(SampleIds.primaryThread).first;

      expect(thread.lastMessagePreview, 'Running five minutes late.');
      expect(messages.last.text, 'Running five minutes late.');
      expect(messages, hasLength(3));
    });

    test('sendMessage ignores blank messages', () async {
      final repository = InMemoryChatRepository();

      await repository.sendMessage(
        threadId: SampleIds.primaryThread,
        senderUserId: SampleIds.currentUser,
        message: '   ',
      );

      final threads = await repository.watchApprovedThreads().first;
      final thread =
          threads.singleWhere((item) => item.id == SampleIds.primaryThread);
      final messages =
          await repository.watchMessages(SampleIds.primaryThread).first;

      expect(thread.lastMessagePreview, 'See you near the ferry entrance.');
      expect(messages, hasLength(2));
    });

    test('sendMessage clamps long messages to coordination limit', () async {
      final repository = InMemoryChatRepository();
      final longMessage = ' ${'a' * 400} ';

      await repository.sendMessage(
        threadId: SampleIds.primaryThread,
        senderUserId: SampleIds.currentUser,
        message: longMessage,
      );

      final threads = await repository.watchApprovedThreads().first;
      final thread =
          threads.singleWhere((item) => item.id == SampleIds.primaryThread);
      final messages =
          await repository.watchMessages(SampleIds.primaryThread).first;

      expect(thread.lastMessagePreview.length, 280);
      expect(messages.last.text.length, 280);
      expect(messages, hasLength(3));
    });
  });
}
