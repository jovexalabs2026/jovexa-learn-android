/// Ad integration point for Jovexa Learn.
///
/// The app is architected so ads can be enabled without touching feature
/// code. Screens that may show a banner call [AdsService.instance.bannerFor]
/// and render nothing when ads are disabled, which is the default.
///
/// To enable AdMob later:
/// 1. Add google_mobile_ads to pubspec.yaml.
/// 2. Add the AdMob App ID meta-data tag to AndroidManifest.xml.
///    Use the Google TEST App ID during development:
///    ca-app-pub-3940256099942544~3347511713
/// 3. Implement [AdsService] with real ad loading, keeping unit IDs in
///    [AdUnitIds]. Only Google TEST unit IDs may be committed:
///    banner ca-app-pub-3940256099942544/6300978111
///    interstitial ca-app-pub-3940256099942544/1033173712
/// 4. Production ad unit IDs must never be committed to the repository.
///    Inject them at build time with --dart-define, for example:
///    flutter build appbundle --dart-define=ADMOB_BANNER_ID=...
library;

import 'package:flutter/widgets.dart';

/// Ad unit IDs resolved at build time. Defaults are empty, which keeps ads
/// fully disabled. No production ID exists anywhere in source control.
class AdUnitIds {
  static const banner = String.fromEnvironment('ADMOB_BANNER_ID');
  static const interstitial = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');

  static bool get configured => banner.isNotEmpty;
}

/// No-op ad service. Replace with a google_mobile_ads implementation when
/// monetization is switched on. Ads must never interrupt an active lesson,
/// quiz, or playground session.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool get enabled => AdUnitIds.configured;

  Future<void> initialize() async {
    // Intentionally empty until google_mobile_ads is integrated.
  }

  /// Returns a banner widget for the given placement, or null when ads are
  /// disabled. Callers must handle null by rendering nothing.
  Widget? bannerFor(String placement) => null;
}
