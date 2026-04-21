import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/features/monetization/data/monetization_repository.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMonetizationRepository implements MonetizationRepository {
  FirestoreMonetizationRepository({
    FirebaseFirestore Function()? firestore,
  }) : _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseFirestore Function() _firestore;

  @override
  Stream<UserEntitlement> watchCurrentEntitlement(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    if (normalizedUserId.isEmpty) {
      return Stream.value(const UserEntitlement.free(userId: 'signed-out'));
    }

    return _firestore()
        .doc(FirebaseCollectionPaths.userEntitlement(normalizedUserId))
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return UserEntitlement.free(userId: normalizedUserId);
      }

      return UserEntitlement(
        userId: normalizedUserId,
        tier: premiumTierFromName(data[FirebaseDocumentFields.tier]),
        boostCredits: _int(
          data[FirebaseDocumentFields.boostCredits],
        ),
        rewardedExtraSlots: _int(
          data[FirebaseDocumentFields.rewardedExtraSlots],
        ),
        subscriptionExpiresAt:
            _dateTimeOrNull(data[FirebaseDocumentFields.subscriptionExpiresAt]),
      );
    });
  }

  int _int(Object? value) => value is int ? value : 0;

  DateTime? _dateTimeOrNull(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
