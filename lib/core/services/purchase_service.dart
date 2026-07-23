import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constants/app_constants.dart';

/// Ephemeral UI signals the paywall reacts to (snackbars, dialogs).
/// [isPremium] state transitions still go through [premiumNotifier].
enum PurchaseEvent { pending, error, restoredNothing }

/// Wraps [InAppPurchase] with a small, opinionated API tailored to the
/// single-product one-time unlock ExpenseMate ships. Consumers should not
/// touch [InAppPurchase.instance] directly.
class PurchaseService {
  static final PurchaseService instance = PurchaseService._();
  PurchaseService._();

  final _iap = InAppPurchase.instance;
  final _storage = const FlutterSecureStorage();
  final _events = StreamController<PurchaseEvent>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _restorePending = false;

  bool _isPremium = false;
  bool get isPremium => _isPremium;
  ProductDetails? get product => _product;
  bool get productAvailable => _product != null;
  String get priceLabel => _product?.price ?? '\$3.99';
  Stream<PurchaseEvent> get events => _events.stream;

  /// Fires when [isPremium] changes so UI/provider can react.
  final ValueNotifier<bool> premiumNotifier = ValueNotifier<bool>(false);

  /// Fires when [_product] resolves (or fails to resolve) so the paywall
  /// can flip out of its loading state.
  final ValueNotifier<int> productNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    _isPremium = (await _storage.read(key: AppConstants.kIsPremium)) == 'true';
    premiumNotifier.value = _isPremium;

    final ts = await _storage.read(key: AppConstants.kInstallTs);
    if (ts == null || int.tryParse(ts) == null) {
      await _storage.write(
        key: AppConstants.kInstallTs,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    final available = await _iap.isAvailable();
    if (!available) {
      productNotifier.value++;
      return;
    }

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        debugPrint('purchaseStream error: $e');
        _events.add(PurchaseEvent.error);
      },
    );

    final resp = await _iap.queryProductDetails({AppConstants.kPremiumSku});
    if (resp.error != null) {
      debugPrint('queryProductDetails error: ${resp.error}');
    }
    if (resp.productDetails.isNotEmpty) {
      _product = resp.productDetails.first;
    }
    productNotifier.value++;
  }

  Future<DateTime?> installTimestamp() async {
    final raw = await _storage.read(key: AppConstants.kInstallTs);
    final ms = int.tryParse(raw ?? '');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<int> trialDaysLeft() async {
    if (_isPremium) return AppConstants.trialDays;
    final ts = await installTimestamp();
    if (ts == null) return AppConstants.trialDays;
    final elapsed = DateTime.now().difference(ts).inDays;
    return (AppConstants.trialDays - elapsed).clamp(0, AppConstants.trialDays).toInt();
  }

  Future<bool> isInTrial() async => (await trialDaysLeft()) > 0;

  /// Kicks off the buy flow. UI will be updated via [premiumNotifier] when
  /// the purchase stream confirms success.
  Future<bool> buy() async {
    if (_product == null) return false;
    final param = PurchaseParam(productDetails: _product!);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Ask Play for any previously-owned purchases (e.g. reinstall, new device).
  /// Emits [PurchaseEvent.restoredNothing] if no owned SKU comes back within
  /// a short window — otherwise the purchase stream handles the update.
  Future<void> restore() async {
    _restorePending = true;
    await _iap.restorePurchases();
    // Play answers restore via the purchase stream, which has no "done" signal
    // when nothing is owned. Poll briefly, then tell the UI to stop spinning.
    Future.delayed(const Duration(seconds: 3), () {
      if (_restorePending) {
        _restorePending = false;
        if (!_isPremium) _events.add(PurchaseEvent.restoredNothing);
      }
    });
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != AppConstants.kPremiumSku) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _restorePending = false;
          await _markPremium(true);
          break;
        case PurchaseStatus.error:
          _restorePending = false;
          _events.add(PurchaseEvent.error);
          break;
        case PurchaseStatus.canceled:
          _restorePending = false;
          break;
        case PurchaseStatus.pending:
          // Play policy: tell the user their purchase is being processed
          // and don't grant entitlement until it clears.
          _events.add(PurchaseEvent.pending);
          break;
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _markPremium(bool value) async {
    _isPremium = value;
    await _storage.write(key: AppConstants.kIsPremium, value: value ? 'true' : 'false');
    premiumNotifier.value = value;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _events.close();
  }
}
