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
    final normalizedActivityId = activityId.trim();
    final normalizedMessage = message.trim();
    if (normalizedActivityId.isEmpty || normalizedMessage.isEmpty) {
      return;
    }

    final userId = _auth().currentUser?.uid;
    if (userId == null) {
      throw StateError(
        'A signed-in Firebase user is required before submitting a join request.',
      );
    }

    final requests = _activities
        .doc(normalizedActivityId)
        .collection(FirebaseCollectionPaths.joinRequests);
    final document = requests.doc(
      _joinRequestDocumentId(
        activityId: normalizedActivityId,
        requesterId: userId,
      ),
    );
    final snapshot = await document.get();
    if (snapshot.exists) {
      final existing = joinRequestFromMap(snapshot.id, snapshot.data()!);
      if (existing.isPending || existing.isApproved) {
        return;
      }
    }

    await document.set({
      ...joinRequestToMap(
        JoinRequest(
          id: document.id,
          activityId: normalizedActivityId,
          requesterId: userId,
          message: normalizedMessage,
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
    final requestPath = _joinRequestPath(requestId);
    if (requestPath == null) {
      return;
    }
    final snapshot = await requestPath.get();
    if (!snapshot.exists) {
      return;
    }

    await requestPath.update({
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

  @override
  Future<void> cancelJoinRequest({
    required String requestId,
  }) {
    return updateRequestStatus(
      requestId: requestId,
      status: JoinRequestStatus.cancelled,
    );
  }

  String _joinRequestDocumentId({
    required String activityId,
    required String requesterId,
  }) {
    return '${activityId.trim()}__${requesterId.trim()}';
  }

  DocumentReference<Map<String, dynamic>>? _joinRequestPath(String requestId) {
    final parts = requestId.split('__');
    if (parts.length != 2) {
      return null;
    }

    final activityId = parts.first.trim();
    final requesterId = parts.last.trim();
    if (activityId.isEmpty || requesterId.isEmpty) {
      return null;
    }

    return _activities
        .doc(activityId)
        .collection(FirebaseCollectionPaths.joinRequests)
        .doc(requestId);
  }
}
