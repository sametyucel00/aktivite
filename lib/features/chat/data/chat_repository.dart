import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';

abstract class ChatRepository {
  Stream<List<ChatThread>> watchApprovedThreads();
  Stream<List<ChatMessage>> watchMessages(String threadId);

  Future<void> ensureThreadForActivity({
    required String activityId,
    required List<String> participantIds,
    required String initialMessagePreview,
  });

  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String message,
  });
}
