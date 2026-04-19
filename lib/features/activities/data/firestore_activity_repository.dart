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
  Future<void> createPlan(ActivityPlan plan) async {
    final normalizedPlan = _normalizedCreatePlan(plan);
    if (normalizedPlan == null) {
      return;
    }

    final document = _activities.doc(normalizedPlan.id);
    final snapshot = await document.get();
    if (snapshot.exists) {
      return;
    }

    await document.set({
      ...activityPlanToMap(normalizedPlan),
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

  ActivityPlan? _normalizedCreatePlan(ActivityPlan plan) {
    final title = plan.title.trim();
    final description = plan.description.trim();
    final city = plan.city.trim();
    final approximateLocation = plan.approximateLocation.trim();
    if (plan.id.trim().isEmpty ||
        plan.ownerUserId.trim().isEmpty ||
        title.isEmpty ||
        description.isEmpty ||
        city.isEmpty ||
        approximateLocation.isEmpty) {
      return null;
    }

    return plan.copyWith(
      id: plan.id.trim(),
      ownerUserId: plan.ownerUserId.trim(),
      title: title,
      description: description,
      city: city,
      approximateLocation: approximateLocation,
      timeLabel: plan.timeLabel.trim(),
    );
  }
}
