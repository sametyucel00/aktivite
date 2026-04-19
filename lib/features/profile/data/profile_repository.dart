import 'package:aktivite/shared/models/app_user_profile.dart';

abstract class ProfileRepository {
  Stream<AppUserProfile> watchCurrentProfile();

  Future<void> saveProfile(AppUserProfile profile);
}
