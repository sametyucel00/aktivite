import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/models/model_maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({
    FirebaseAuth Function()? auth,
    FirebaseFirestore Function()? firestore,
  })  : _auth = auth ?? (() => FirebaseAuth.instance),
        _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _firestore().collection(FirebaseCollectionPaths.chatThreads);

  @override
  Stream<List<ChatThread>> watchApprovedThreads() {
    return _auth().authStateChanges().asyncExpand((user) {
      final userId = user?.uid;
      if (userId == null) {
        return Stream.value(const <ChatThread>[]);
      }

      return _threads
          .where(
            FirebaseDocumentFields.participantIds,
            arrayContains: userId,
          )
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => chatThreadFromMap(doc.id, doc.data()))
            .toList(growable: false);
      });
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _threads
        .doc(threadId)
        .collection(FirebaseCollectionPaths.messages)
        .orderBy(FirebaseDocumentFields.sentAt)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => chatMessageFromMap(doc.id, _normalizeMap(doc.data())))
          .toList(growable: false);
    });
  }

  @override
  Future<void> ensureThreadForActivity({
    required String activityId,
    required List<String> participantIds,
    required String initialMessagePreview,
  }) async {
    final existing = await _threads
        .where(FirebaseDocumentFields.activityId, isEqualTo: activityId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.single.reference.update({
        FirebaseDocumentFields.participantIds: participantIds,
        FirebaseDocumentFields.lastMessagePreview: initialMessagePreview,
        FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    final document = _threads.doc();
    final createdAt = FieldValue.serverTimestamp();
    await document.set({
      ...chatThreadToMap(
        ChatThread(
          id: document.id,
          activityId: activityId,
          participantIds: participantIds,
          lastMessagePreview: initialMessagePreview,
          safetyBannerVisible: true,
        ),
      ),
      FirebaseDocumentFields.createdAt: createdAt,
      FirebaseDocumentFields.updatedAt: createdAt,
    });
  }

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String message,
  }) async {
    final thread = _threads.doc(threadId);
    final messages = thread.collection(FirebaseCollectionPaths.messages);
    final sentAt = FieldValue.serverTimestamp();

    await messages.add({
      FirebaseDocumentFields.threadId: threadId,
      FirebaseDocumentFields.senderUserId: senderUserId,
      FirebaseDocumentFields.text: message,
      FirebaseDocumentFields.sentAt: sentAt,
    });
    await thread.update({
      FirebaseDocumentFields.lastMessagePreview: message,
      FirebaseDocumentFields.updatedAt: sentAt,
    });
  }

  Map<String, Object?> _normalizeMap(Map<String, Object?> data) {
    return {
      for (final entry in data.entries)
        entry.key: entry.value is Timestamp
            ? (entry.value as Timestamp).toDate()
            : entry.value,
    };
  }
}
