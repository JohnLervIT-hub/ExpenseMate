import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/purchase_service.dart';

@immutable
class PremiumState {
  final bool isPremium;
  final int trialDaysLeft;

  /// Play's locale-formatted price, or null while it is unknown. The paywall
  /// must not invent a figure: the button falls back to a price-free label.
  final String? priceLabel;
  final bool productAvailable;
  final bool loadingProduct;
  final bool storeReachable;

  const PremiumState({
    required this.isPremium,
    required this.trialDaysLeft,
    required this.priceLabel,
    required this.productAvailable,
    required this.loadingProduct,
    required this.storeReachable,
  });

  bool get isInTrial => trialDaysLeft > 0;
  bool get hasAccess => isPremium || isInTrial;

  // No copyWith: every update comes from a single read of PurchaseService, and
  // a partial copy is what previously let a stale trialDaysLeft survive.

  // Value equality so a refresh that changed nothing doesn't notify listeners.
  // The router rebuilds its redirect off this provider, so identical states
  // churning through it is wasted work.
  @override
  bool operator ==(Object other) =>
      other is PremiumState &&
      other.isPremium == isPremium &&
      other.trialDaysLeft == trialDaysLeft &&
      other.priceLabel == priceLabel &&
      other.productAvailable == productAvailable &&
      other.loadingProduct == loadingProduct &&
      other.storeReachable == storeReachable;

  @override
  int get hashCode => Object.hash(isPremium, trialDaysLeft, priceLabel,
      productAvailable, loadingProduct, storeReachable);

  static const initial = PremiumState(
    isPremium: false,
    trialDaysLeft: AppConstants.trialDays,
    priceLabel: null,
    productAvailable: false,
    loadingProduct: true,
    storeReachable: false,
  );
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PurchaseService _svc;
  AppLifecycleListener? _lifecycle;

  PremiumNotifier(this._svc) : super(PremiumState.initial) {
    _svc.premiumNotifier.addListener(_syncFromService);
    _svc.productNotifier.addListener(_syncFromService);
    // The trial clock keeps running while the process is alive, so a session
    // left open across the expiry boundary has to re-read it on resume —
    // otherwise entitlement only lapses on a cold start.
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _refresh();
  }

  Future<void> _refresh() async {
    final days = await _svc.trialDaysLeft();
    if (!mounted) return;
    state = PremiumState(
      isPremium: _svc.isPremium,
      trialDaysLeft: days,
      priceLabel: _svc.priceLabel,
      productAvailable: _svc.productAvailable,
      loadingProduct: _svc.loadingProduct,
      storeReachable: _svc.storeReachable,
    );
  }

  /// Service-side change (purchase confirmed, product query finished). Goes
  /// through the full refresh so [PremiumState.trialDaysLeft] is recomputed
  /// too, rather than carrying a stale value forward.
  void _syncFromService() {
    _refresh();
  }

  Stream<PurchaseEvent> get events => _svc.events;

  /// On-device billing trace for the paywall's diagnostics sheet.
  List<String> get diagnostics => _svc.diagnostics;

  Future<bool> buy() => _svc.buy();
  Future<void> restore() => _svc.restore();

  /// Re-queries Play for the unlock SKU after a failed load.
  Future<void> retryProductLoad() => _svc.loadProduct();

  @override
  void dispose() {
    _svc.premiumNotifier.removeListener(_syncFromService);
    _svc.productNotifier.removeListener(_syncFromService);
    _lifecycle?.dispose();
    super.dispose();
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(PurchaseService.instance),
);
