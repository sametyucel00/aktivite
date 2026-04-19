import 'package:aktivite/core/constants/safety_report_reasons.dart';
import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'safety_repository.dart';

class FirestoreSafetyRepository implements SafetyRepository {
  FirestoreSafetyRepository({
    FirebaseAuth Function()? auth,
    FirebaseFirestore Function()? firestore,
  })  : _auth = auth ?? (() => FirebaseAuth.instance),
        _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore().collection(FirebaseCollectionPaths.reports);

  CollectionReference<Map<String, dynamic>> get _blocks =>
      _firestore().collection(FirebaseCollectionPaths.blocks);

  @override
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    final currentUserId = _currentUserId;
    final normalizedTargetUserId = targetUserId.trim();
    final normalizedReason = SafetyReportReasons.normalize(reason);
    if (currentUserId == null ||
        normalizedTargetUserId.isEmpty ||
        normalizedTargetUserId == currentUserId ||
        normalizedReason == null) {
      return;
    }

    await _reports.add({
      FirebaseDocumentFields.userId: currentUserId,
      FirebaseDocumentFields.targetUserId: normalizedTargetUserId,
      FirebaseDocumentFields.reason: normalizedReason,
      FirebaseDocumentFields.status: 'pendingReview',
      FirebaseDocumentFields.workflowSource: 'clientReport',
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> blockUser({
    required String targetUserId,
  }) async {
    final currentUserId = _currentUserId;
    final normalizedTargetUserId = targetUserId.trim();
    if (currentUserId == null ||
        normalizedTargetUserId.isEmpty ||
        normalizedTargetUserId == currentUserId) {
      return;
    }

    await _blocks.doc('$currentUserId-$normalizedTargetUserId').set({
      FirebaseDocumentFields.userId: currentUserId,
      FirebaseDocumentFields.targetUserId: normalizedTargetUserId,
      FirebaseDocumentFields.status: 'active',
      FirebaseDocumentFields.workflowSource: 'clientBlock',
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  String? get _currentUserId => _auth().currentUser?.uid;
}
