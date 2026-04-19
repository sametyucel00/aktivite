import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/model_maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'activity_repository.dart';

class FirestoreActivityRepository implements ActivityRepository {
  FirestoreActivityRepository({
    FirebaseFirestore Function()? firestore,
  }) : _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore().collection(FirebaseCollectionPaths.activities);

  @override
  Stream<List<ActivityPlan>> watchNearbyPlans() {
    return _activities
        .orderBy(FirebaseDocumentFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => activityPlanFromMap(doc.id, doc.data()))
          .toList(growable: false);
    });
  }

  @override
  Future<void> createPlan(ActivityPlan plan) {
    return _activities.doc(plan.id).set({
      ...activityPlanToMap(plan),
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementParticipantCount(String activityId) async {
    final document = _activities.doc(activityId);
    await _firestore().runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      final currentPlan = activityPlanFromMap(snapshot.id, data);
      final nextCount = (currentPlan.participantCount + 1).clamp(
        0,
        currentPlan.maxParticipants,
      );
      final updatedPlan = currentPlan.copyWith(
        participantCount: nextCount,
      );

      transaction.update(document, {
        FirebaseDocumentFields.participantCount: nextCount,
        FirebaseDocumentFields.status:
            updatedPlan.isFull ? 'full' : currentPlan.status.name,
        FirebaseDocumentFields.workflowSource: 'clientFallback',
        FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  }
}
