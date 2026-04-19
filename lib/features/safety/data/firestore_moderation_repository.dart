import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/shared/models/model_maps.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'moderation_repository.dart';

class FirestoreModerationRepository implements ModerationRepository {
  FirestoreModerationRepository({
    FirebaseFirestore Function()? firestore,
  }) : _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _trustEvents =>
      _firestore().collection(FirebaseCollectionPaths.trustEvents);

  @override
  Stream<List<ModerationEvent>> watchTrustEvents(String userId) {
    return _trustEvents
        .where(FirebaseDocumentFields.subjectUserId, isEqualTo: userId)
        .orderBy(FirebaseDocumentFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => moderationEventFromMap(
              doc.id,
              _normalizeMap(doc.data()),
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<void> createTrustEvent(ModerationEvent event) {
    final document = _trustEvents.doc(event.id);
    return document.set({
      ...moderationEventToMap(event),
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
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
