import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/monetization/data/monetization_repository.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';

class InMemoryMonetizationRepository implements MonetizationRepository {
  InMemoryMonetizationRepository() {
    _controller.add(_snapshotForUser(SampleIds.currentUser));
  }

  final StreamController<UserEntitlement> _controller =
      StreamController<UserEntitlement>.broadcast();

  final UserEntitlement _seed = const UserEntitlement(
    userId: SampleIds.currentUser,
    tier: PremiumTier.plus,
    boostCredits: 2,
    rewardedExtraSlots: 0,
  );

  @override
  Stream<UserEntitlement> watchCurrentEntitlement(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    if (normalizedUserId.isEmpty) {
      return Stream.value(const UserEntitlement.free(userId: 'signed-out'));
    }

    return Stream<UserEntitlement>.multi((multi) {
      multi.add(_snapshotForUser(normalizedUserId));
      final subscription = _controller.stream.listen(
        multi.add,
        onError: multi.addError,
        onDone: multi.close,
      );
      multi.onCancel = subscription.cancel;
    });
  }

  UserEntitlement _snapshotForUser(String userId) {
    if (_seed.userId == userId) {
      return _seed;
    }
    return UserEntitlement.free(userId: userId);
  }
}
