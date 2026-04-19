import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/model_maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'join_request_repository.dart';

class FirestoreJoinRequestRepository implements JoinRequestRepository {
  FirestoreJoinRequestRepository({
    FirebaseAuth Function()? auth,
    FirebaseFirestore Function()? firestore,
  })  : _auth = auth ?? (() => FirebaseAuth.instance),
        _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore().collection(FirebaseCollectionPaths.activities);

  @override
  Stream<List<JoinRequest>> watchRequestsForActivity(String activityId) {
    return _activities
        .doc(activityId)
        .collection(FirebaseCollectionPaths.joinRequests)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => joinRequestFromMap(doc.id, doc.data()))
          .toList(growable: false);
    });
  }

  @override
  Future<void> submitJoinRequest({
    required String activityId,
    required String message,
  }) async {
    final userId = _auth().currentUser?.uid;
    if (userId == null) {
      throw StateError(
        'A signed-in Firebase user is required before submitting a join request.',
      );
    }

    final requests = _activities
        .doc(activityId)
        .collection(FirebaseCollectionPaths.joinRequests);
    final document = requests.doc();
    await document.set({
      ...joinRequestToMap(
        JoinRequest(
          id: document.id,
          activityId: activityId,
          requesterId: userId,
          message: message,
          status: JoinRequestStatus.pending,
        ),
      ),
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
      FirebaseDocumentFields.workflowStatus: 'pendingOwnerReview',
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateRequestStatus({
    required String requestId,
    required JoinRequestStatus status,
  }) async {
    final query = await _firestore()
        .collectionGroup(FirebaseCollectionPaths.joinRequests)
        .where(FieldPath.documentId, isEqualTo: requestId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      return;
    }

    await query.docs.single.reference.update({
      FirebaseDocumentFields.status: status.name,
      FirebaseDocumentFields.workflowStatus: switch (status) {
        JoinRequestStatus.approved => 'approvalSideEffectsPending',
        JoinRequestStatus.rejected => 'closedRejected',
        JoinRequestStatus.cancelled => 'closedCancelled',
        JoinRequestStatus.pending => 'pendingOwnerReview',
      },
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
