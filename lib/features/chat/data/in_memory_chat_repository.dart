import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/utils/app_time.dart';
import 'package:aktivite/features/chat/data/chat_repository.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';

class InMemoryChatRepository implements ChatRepository {
  InMemoryChatRepository() {
    _controller.add(_snapshotThreads());
    _messagesController.add(_snapshotMessages());
  }

  final List<ChatThread> _threads = [
    const ChatThread(
      id: SampleIds.primaryThread,
      activityId: SampleIds.coffeeActivity,
      participantIds: [SampleIds.currentUser, SampleIds.guestOne],
      lastMessagePreview: 'See you near the ferry entrance.',
      safetyBannerVisible: true,
    ),
  ];
  final Map<String, List<ChatMessage>> _messagesByThread = {
    SampleIds.primaryThread: [
      ChatMessage(
        id: 'message-1',
        threadId: SampleIds.primaryThread,
        senderUserId: SampleIds.guestOne,
        text: 'See you near the ferry entrance.',
        sentAt: DateTime(2026, 4, 18, 18, 40),
      ),
      ChatMessage(
        id: 'message-2',
        threadId: SampleIds.primaryThread,
        senderUserId: SampleIds.currentUser,
        text: 'Perfect, I will be there in 10 minutes.',
        sentAt: DateTime(2026, 4, 18, 18, 44),
      ),
    ],
  };
  final StreamController<List<ChatThread>> _controller =
      StreamController<List<ChatThread>>.broadcast();
  final StreamController<Map<String, List<ChatMessage>>> _messagesController =
      StreamController<Map<String, List<ChatMessage>>>.broadcast();

  @override
  Future<void> ensureThreadForActivity({
    required String activityId,
    required List<String> participantIds,
    required String initialMessagePreview,
  }) async {
    final existingIndex = _threads.indexWhere(
      (thread) => thread.activityId == activityId,
    );
    if (existingIndex >= 0) {
      final existing = _threads[existingIndex];
      _threads[existingIndex] = existing.copyWith(
        participantIds: participantIds,
      );
      _controller.add(_snapshotThreads());
      return;
    }

    final threadId = AppIdFactory.sequenceId(
      prefix: 'thread',
      nextNumber: _threads.length + 1,
    );
    final sentAt = AppClock.now();
    _threads.add(
      ChatThread(
        id: threadId,
        activityId: activityId,
        participantIds: participantIds,
        lastMessagePreview: initialMessagePreview,
        safetyBannerVisible: true,
      ),
    );
    _messagesByThread[threadId] = [
      ChatMessage(
        id: AppIdFactory.timestampId(prefix: 'message', now: sentAt),
        threadId: threadId,
        senderUserId: participantIds.first,
        text: initialMessagePreview,
        sentAt: sentAt,
      ),
    ];
    _controller.add(_snapshotThreads());
    _messagesController.add(_snapshotMessages());
  }

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String message,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      return;
    }

    final index = _threads.indexWhere((thread) => thread.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _threads[index];
    _threads[index] = current.copyWith(
      lastMessagePreview: normalizedMessage,
    );
    final messages = [...?_messagesByThread[threadId]];
    final sentAt = AppClock.now();
    messages.add(
      ChatMessage(
        id: AppIdFactory.timestampId(prefix: 'message', now: sentAt),
        threadId: threadId,
        senderUserId: senderUserId,
        text: normalizedMessage,
        sentAt: sentAt,
      ),
    );
    _messagesByThread[threadId] = messages;
    _controller.add(_snapshotThreads());
    _messagesController.add(_snapshotMessages());
  }

  @override
  Stream<List<ChatThread>> watchApprovedThreads() {
    return Stream<List<ChatThread>>.multi((multi) {
      multi.add(_snapshotThreads());
      final subscription = _controller.stream.listen(
        multi.add,
        onError: multi.addError,
        onDone: multi.close,
      );
      multi.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return Stream<List<ChatMessage>>.multi((multi) {
      multi.add(_messagesForThread(threadId));
      final subscription = _messagesController.stream
          .map((messagesByThread) =>
              _messagesForThread(threadId, messagesByThread))
          .listen(
            multi.add,
            onError: multi.addError,
            onDone: multi.close,
          );
      multi.onCancel = subscription.cancel;
    });
  }

  List<ChatThread> _snapshotThreads() =>
      List<ChatThread>.unmodifiable(_threads);

  Map<String, List<ChatMessage>> _snapshotMessages() {
    return {
      for (final entry in _messagesByThread.entries)
        entry.key: List<ChatMessage>.unmodifiable(entry.value),
    };
  }

  List<ChatMessage> _messagesForThread(
    String threadId, [
    Map<String, List<ChatMessage>>? messagesByThread,
  ]) {
    return messagesByThread?[threadId] ??
        _messagesByThread[threadId] ??
        const <ChatMessage>[];
  }
}
