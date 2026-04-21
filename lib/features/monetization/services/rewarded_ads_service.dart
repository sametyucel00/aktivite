import 'dart:async';

import 'package:aktivite/features/monetization/domain/rewarded_placement.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class RewardedAdsService {
  Future<bool> showRewardedPlacement({
    required RewardedPlacement placement,
  });
}

class GoogleMobileRewardedAdsService implements RewardedAdsService {
  GoogleMobileRewardedAdsService();

  Future<InitializationStatus>? _initialization;

  @override
  Future<bool> showRewardedPlacement({
    required RewardedPlacement placement,
  }) async {
    if (kIsWeb ||
        !(defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return false;
    }

    _initialization ??= MobileAds.instance.initialize();
    await _initialization;

    final completer = Completer<bool>();

    await RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          var rewarded = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(rewarded);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            },
          );
          ad.show(
            onUserEarnedReward: (ad, reward) {
              rewarded = true;
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () => false,
    );
  }
}

const _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
