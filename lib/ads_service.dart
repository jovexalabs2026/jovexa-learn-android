/// Ad integration for Jovexa Learn.
///
/// Ads are OFF by default. They only turn on when a banner ad unit ID is
/// injected at build time, so no store build ever shows ads by accident and
/// no production ID lives in source control:
///
///   flutter build appbundle --release \
///     --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/YYYY
///
/// For local ad testing use Google's published TEST unit ID:
///
///   flutter run --dart-define=ADMOB_BANNER_ID=ca-app-pub-3940256099942544/6300978111
///
/// The AdMob App ID lives in AndroidManifest.xml and currently uses Google's
/// TEST App ID. Replace it with the production App ID together with the
/// production unit IDs. Ads never appear inside a lesson, quiz, or the
/// playground, only as a single banner above the navigation bar.
library;

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad unit IDs resolved at build time. Empty means ads are disabled.
class AdUnitIds {
  static const banner = String.fromEnvironment('ADMOB_BANNER_ID');

  static bool get configured => banner.isNotEmpty;
}

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool get enabled => AdUnitIds.configured;

  Future<void> initialize() async {
    if (!enabled) return;
    await MobileAds.instance.initialize();
  }

  /// Returns a banner widget for the given placement, or null when ads are
  /// disabled. Callers must handle null by rendering nothing.
  Widget? bannerFor(String placement) =>
      enabled ? const _BannerSlot(adUnitId: AdUnitIds.banner) : null;
}

class _BannerSlot extends StatefulWidget {
  final String adUnitId;

  const _BannerSlot({required this.adUnitId});

  @override
  State<_BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<_BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad != null) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    _load(width);
  }

  Future<void> _load(int width) async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) return;
    _ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
