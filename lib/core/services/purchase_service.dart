import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../data/repositories/settings_repository.dart';
import '../constants/app_constants.dart';
import 'billing_verifier.dart';

/// Flip to `true` once client-side signature verification has been
/// validated in the field (log-only period showed no false negatives).
/// Until then, failed signatures are logged but purchases still grant
/// entitlement so a verifier bug can't lock out real customers.
const bool _kEnforceSignatureVerification = false;

/// How long [PurchaseService.restore] waits for Play to answer through the
/// purchase stream before concluding that nothing is owned.
const Duration _kRestoreWindow = Duration(seconds: 6);

/// Cap on the on-device diagnostics ring buffer.
const int _kDiagnosticsLimit = 40;

/// Ephemeral UI signals the paywall reacts to (snackbars, dialogs).
/// [PurchaseService.isPremium] state transitions still go through
/// [PurchaseService.premiumNotifier].
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
  final List<String> _diagnostics = <String>[];

  StreamSubscription<List<PurchaseDetails>>? _sub;
  SettingsRepository? _mirror;
  ProductDetails? _product;
  /// Completes with `true` when the purchase stream delivered a terminal
  /// answer during a [restore] (so the outcome is already on screen), and with
  /// `false` only on timeout.
  Completer<bool>? _restoreCompleter;
  DateTime? _installTs;
  bool _storeReachable = false;
  bool _loadingProduct = false;

  bool _isPremium = false;
  bool get isPremium => _isPremium;
  ProductDetails? get product => _product;
  bool get productAvailable => _product != null;

  /// Null until Play hands back the real, locale-formatted price. There is
  /// deliberately no hardcoded fallback: quoting USD to a buyer in another
  /// currency is both wrong and a Play listing problem.
  String? get priceLabel => _product?.price;

  /// True while a product query is in flight, so the paywall can show a
  /// spinner instead of a dead button.
  bool get loadingProduct => _loadingProduct;

  /// Whether Play Billing answered [InAppPurchase.isAvailable] on the last
  /// [loadProduct] attempt — distinguishes "no Play Store here" from
  /// "product missing from the Console".
  bool get storeReachable => _storeReachable;

  Stream<PurchaseEvent> get events => _events.stream;

  /// Newest-last billing trace, on-device only — nothing leaves the handset.
  /// The paywall exposes it behind a long-press so a failure on a real user's
  /// device can be read out instead of guessed at.
  List<String> get diagnostics => List<String>.unmodifiable(_diagnostics);

  /// Fires when [isPremium] changes so UI/provider can react.
  final ValueNotifier<bool> premiumNotifier = ValueNotifier<bool>(false);

  /// Fires when [product] or [loadingProduct] changes so the paywall can
  /// flip out of its loading state.
  final ValueNotifier<int> productNotifier = ValueNotifier<int>(0);

  /// Reads persisted entitlement and the trial clock, then starts Play work
  /// in the background. Everything here is guarded: a keystore or billing
  /// failure must never stop the app from launching.
  Future<void> init({SettingsRepository? mirror}) async {
    _mirror = mirror;
    try {
      // Entitlement is read from secure storage only. The settings table is
      // deliberately not a fallback: restoreDatabase() copies a user-supplied
      // file over it, so a mirrored premium flag would be free premium for
      // anyone with a SQLite editor. Legitimate recovery after a keystore wipe
      // comes from Play instead, via the restorePurchases() in _connectStore.
      _isPremium = await _readSecure(AppConstants.kIsPremium) == 'true';
      premiumNotifier.value = _isPremium;

      await _ensureInstallTimestamp();

      _sub = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object e) {
          _log('purchaseStream error: $e');
          _finishRestore();
          _events.add(PurchaseEvent.error);
        },
      );

      // Deliberately not awaited: both steps hit the network and this runs
      // before runApp(), so awaiting them strands the user on a blank screen.
      unawaited(_connectStore());
    } catch (e) {
      _log('init FAILED: $e');
    }
  }

  Future<void> _connectStore() async {
    await loadProduct();
    try {
      // Replays owned purchases so (a) a reinstall gets its entitlement back
      // and (b) a purchase whose acknowledgement failed earlier is acked
      // before Play's three-day void window closes and refunds it.
      await _iap.restorePurchases();
    } catch (e) {
      _log('startup restore failed: $e');
    }
  }

  /// Queries Play for the unlock SKU. Safe to call repeatedly — the paywall's
  /// retry button does, because a product that failed to resolve at launch
  /// would otherwise leave the buy button dead for the whole session.
  Future<void> loadProduct() async {
    if (_loadingProduct) return;
    _loadingProduct = true;
    productNotifier.value++;
    try {
      _storeReachable = await _iap.isAvailable();
      if (!_storeReachable) {
        _log('store unavailable (isAvailable=false)');
        _product = null;
        return;
      }
      final resp = await _iap.queryProductDetails({AppConstants.kPremiumSku});
      if (resp.error != null) {
        _log('queryProductDetails error: '
            '${resp.error!.code} ${resp.error!.message}');
      }
      if (resp.notFoundIDs.isNotEmpty) {
        // Nearly always a Play Console problem: the product ID doesn't exist,
        // isn't active, or doesn't belong to this package.
        _log('product NOT FOUND in Play: ${resp.notFoundIDs.join(", ")}');
      }
      _product = resp.productDetails.isEmpty ? null : resp.productDetails.first;
      _log(_product == null
          ? 'no product resolved for ${AppConstants.kPremiumSku}'
          : 'product ${_product!.id} resolved at ${_product!.price}');
    } catch (e) {
      _log('loadProduct threw: $e');
      _product = null;
    } finally {
      _loadingProduct = false;
      productNotifier.value++;
    }
  }

  Future<DateTime> installTimestamp() => _ensureInstallTimestamp();

  Future<int> trialDaysLeft() async {
    if (_isPremium) return AppConstants.trialDays;
    final ts = await _ensureInstallTimestamp();
    final elapsed = DateTime.now().difference(ts).inDays;
    return (AppConstants.trialDays - elapsed)
        .clamp(0, AppConstants.trialDays)
        .toInt();
  }

  Future<bool> isInTrial() async => (await trialDaysLeft()) > 0;

  /// Kicks off the buy flow. UI will be updated via [premiumNotifier] when
  /// the purchase stream confirms success.
  Future<bool> buy() async {
    final product = _product;
    if (product == null) {
      _log('buy() called with no product loaded');
      return false;
    }
    _log('buy() launching flow for ${product.id}');
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Ask Play for any previously-owned purchases (e.g. reinstall, new device).
  ///
  /// Completes only once the outcome is known — either the purchase stream
  /// delivered something or [_kRestoreWindow] elapsed — so callers can clear
  /// their spinner in a `finally` and never strand the UI in a busy state.
  /// Emits [PurchaseEvent.restoredNothing] when no owned SKU comes back.
  Future<void> restore() async {
    final completer = Completer<bool>();
    _restoreCompleter = completer;
    try {
      await _iap.restorePurchases();
      // Play answers restore through the purchase stream, which has no "done"
      // signal when nothing is owned. Wait for the stream, then give up.
      final handled =
          await completer.future.timeout(_kRestoreWindow, onTimeout: () => false);
      // Only the timeout path means "nothing came back". Checking _isPremium
      // instead would race: the stream completes this future a microtask
      // before the entitlement write lands.
      if (!handled) {
        _log('restore found nothing');
        _events.add(PurchaseEvent.restoredNothing);
      }
    } catch (e) {
      _log('restore FAILED: $e');
      rethrow;
    } finally {
      if (identical(_restoreCompleter, completer)) _restoreCompleter = null;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != AppConstants.kPremiumSku) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _finishRestore();
          if (!_verifyPurchase(p) && _kEnforceSignatureVerification) {
            // Skip the acknowledgement as well as the entitlement: Play voids
            // an unacknowledged purchase after three days, which refunds a
            // buyer whose receipt we can't vouch for.
            _log('rejected ${p.productID}: signature verification failed');
            _events.add(PurchaseEvent.error);
            break;
          }
          // Acknowledge before anything else. An unacknowledged purchase is
          // auto-refunded after three days, so no storage write, notifier or
          // throw is allowed to run ahead of this.
          final acked = await _acknowledge(p);
          _log('entitled via ${p.status.name} (acknowledged=$acked)');
          await _markPremium(true);
          break;
        case PurchaseStatus.error:
          _finishRestore();
          _log('purchase error: ${p.error?.code} ${p.error?.message}');
          _events.add(PurchaseEvent.error);
          break;
        case PurchaseStatus.canceled:
          _finishRestore();
          _log('purchase canceled by user');
          break;
        case PurchaseStatus.pending:
          // Play policy: tell the user their purchase is being processed
          // and don't grant entitlement — or acknowledge — until it clears.
          _log('purchase pending');
          _events.add(PurchaseEvent.pending);
          break;
      }
    }
  }

  /// Acknowledges a purchase, swallowing failures. Not fatal on its own:
  /// [init] calls `restorePurchases` on every launch, so Play replays an
  /// unacknowledged purchase and we get another attempt before it is voided.
  Future<bool> _acknowledge(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return true;
    try {
      await _iap.completePurchase(p);
      return true;
    } catch (e) {
      _log('ACK FAILED for ${p.productID} — Play voids it in 3 days: $e');
      return false;
    }
  }

  /// Tells a waiting [restore] that Play gave a terminal answer, so it must
  /// not go on to report that nothing was found.
  void _finishRestore() {
    final completer = _restoreCompleter;
    if (completer != null && !completer.isCompleted) completer.complete(true);
  }

  bool _verifyPurchase(PurchaseDetails p) {
    if (p is! GooglePlayPurchaseDetails) return true;
    final ok = verifyPurchaseSignature(
      p.verificationData.localVerificationData,
      p.billingClientPurchase.signature,
    );
    if (!ok) {
      _log('signature verification FAILED for ${p.productID}');
    }
    return ok;
  }

  Future<void> _markPremium(bool value) async {
    // In-memory and notifier first: the customer has paid, so entitlement must
    // not hinge on a storage write that can throw.
    _isPremium = value;
    premiumNotifier.value = value;
    final raw = value ? 'true' : 'false';
    if (!await _writeSecure(AppConstants.kIsPremium, raw)) {
      // Entitlement survives in memory for this session, and the next launch
      // recovers it from Play through restorePurchases().
      _log('premium flag: secure write failed');
    }
  }

  /// Resolves the trial start, keeping the earliest stamp either store knows.
  ///
  /// Secure storage and the settings table can be cleared independently of one
  /// another, so taking the earliest of the two stops a wiped keystore from
  /// handing out a fresh 14 days. Earliest-wins is also what makes mirroring
  /// into the restorable settings table safe: a crafted backup can only ever
  /// move the trial start further into the past, never extend it.
  ///
  /// A full uninstall still resets the trial. That can only be closed off with
  /// a server-side record of the device.
  Future<DateTime> _ensureInstallTimestamp() async {
    final cached = _installTs;
    if (cached != null) return cached;

    final stamps = <int>[];
    final secure =
        int.tryParse(await _readSecure(AppConstants.kInstallTs) ?? '');
    if (secure != null) stamps.add(secure);
    final mirrored =
        int.tryParse(await _readMirror(AppConstants.kInstallTs) ?? '');
    if (mirrored != null) stamps.add(mirrored);

    final ms = stamps.isEmpty
        ? DateTime.now().millisecondsSinceEpoch
        : stamps.reduce((a, b) => a < b ? a : b);
    final ts = DateTime.fromMillisecondsSinceEpoch(ms);
    _installTs = ts;

    // Written back unconditionally so a store that was empty or wiped is
    // repopulated with the earliest stamp rather than today's date.
    final raw = '$ms';
    final secureOk = await _writeSecure(AppConstants.kInstallTs, raw);
    final mirrorOk = await _writeMirror(AppConstants.kInstallTs, raw);
    if (!secureOk && !mirrorOk) {
      // Nothing persisted, so the trial restarts next launch. Cached in
      // memory so at least this session stays consistent.
      _log('trial clock could not be persisted to either store');
    }
    return ts;
  }

  Future<String?> _readSecure(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _log('secure read failed for $key: $e');
      return null;
    }
  }

  Future<bool> _writeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      _log('secure write failed for $key: $e');
      return false;
    }
  }

  Future<String?> _readMirror(String key) async {
    final mirror = _mirror;
    if (mirror == null) return null;
    try {
      return await mirror.get(key);
    } catch (e) {
      _log('mirror read failed for $key: $e');
      return null;
    }
  }

  Future<bool> _writeMirror(String key, String value) async {
    final mirror = _mirror;
    if (mirror == null) return false;
    try {
      await mirror.set(key, value);
      return true;
    } catch (e) {
      _log('mirror write failed for $key: $e');
      return false;
    }
  }

  void _log(String line) {
    _diagnostics.add('${DateTime.now().toIso8601String()}  $line');
    if (_diagnostics.length > _kDiagnosticsLimit) _diagnostics.removeAt(0);
    debugPrint('purchase_service: $line');
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _events.close();
  }
}
