import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/models/model_maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    FirebaseAuth Function()? auth,
    FirebaseFirestore Function()? firestore,
  })  : _auth = auth ?? (() => FirebaseAuth.instance),
        _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore().collection(FirebaseCollectionPaths.profiles);

  @override
  Stream<AppUserProfile> watchCurrentProfile() {
    return _auth().authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(_signedOutProfile());
      }

      return _profiles.doc(user.uid).snapshots().asyncMap((snapshot) async {
        final data = snapshot.data();
        if (data == null) {
          final seededProfile = _seedProfileForUser(user);
          await saveProfile(seededProfile);
          return seededProfile;
        }
        return appUserProfileFromMap(snapshot.id, data);
      });
    });
  }

  @override
  Future<void> saveProfile(AppUserProfile profile) {
    return _profiles.doc(profile.id).set(
      {
        ...appUserProfileToMap(profile),
        FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  AppUserProfile _seedProfileForUser(User user) {
    return AppUserProfile(
      id: user.uid,
      displayName: user.displayName ?? '',
      profilePhotoUrl: user.photoURL ?? '',
      city: '',
      bio: '',
      profileCompletion: 0,
      favoriteActivities: const [],
      activeTimes: const [],
      groupPreference: GroupPreference.flexible,
      socialMood: SocialMood.casual,
      verificationLabel: user.phoneNumber != null ? 'phone' : '',
      verificationLevel: user.phoneNumber != null
          ? VerificationLevel.phone
          : VerificationLevel.none,
    );
  }

  AppUserProfile _signedOutProfile() {
    return const AppUserProfile(
      id: 'signed-out',
      displayName: '',
      profilePhotoUrl: '',
      city: '',
      bio: '',
      profileCompletion: 0,
      favoriteActivities: [],
      activeTimes: [],
      groupPreference: GroupPreference.flexible,
      socialMood: SocialMood.casual,
      verificationLabel: '',
      verificationLevel: VerificationLevel.none,
    );
  }
}
