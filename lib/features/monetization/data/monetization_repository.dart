import 'package:aktivite/features/monetization/domain/user_entitlement.dart';

abstract class MonetizationRepository {
  Stream<UserEntitlement> watchCurrentEntitlement(String? userId);
}
