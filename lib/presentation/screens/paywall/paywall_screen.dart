import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/purchase_service.dart';
import '../../providers/premium_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  /// True when the user opened the paywall themselves (the "Unlock" row in
  /// More) rather than being redirected here by an expired trial. A voluntary
  /// visit can be closed; the hard wall cannot.
  final bool dismissible;

  const PaywallScreen({super.key, this.dismissible = false});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _buying = false;
  bool _restoring = false;
  String? _status;
  StreamSubscription<PurchaseEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = ref.read(premiumProvider.notifier).events.listen(_onEvent);
    // A product that failed to resolve at launch would otherwise leave this
    // screen with a permanently dead buy button, so try again on open.
    final premium = ref.read(premiumProvider);
    if (!premium.productAvailable && !premium.loadingProduct) {
      ref.read(premiumProvider.notifier).retryProductLoad();
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _onEvent(PurchaseEvent event) {
    if (!mounted) return;
    final l = context.l10n;
    final message = switch (event) {
      PurchaseEvent.pending => l.paywallPending,
      PurchaseEvent.restoredNothing => l.paywallRestoreNone,
      PurchaseEvent.error => l.paywallErrorGeneric,
    };
    // Clear inline status once we surface via snackbar to avoid duplicate copy.
    setState(() => _status = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _buy() async {
    setState(() {
      _buying = true;
      _status = null;
    });
    try {
      final ok = await ref.read(premiumProvider.notifier).buy();
      if (!ok && mounted) {
        setState(() => _status = context.l10n.paywallErrorGeneric);
      }
    } catch (e) {
      if (mounted) setState(() => _status = '$e');
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _restoring = true;
      _status = null;
    });
    try {
      await ref.read(premiumProvider.notifier).restore();
    } catch (e) {
      if (mounted) setState(() => _status = '$e');
    } finally {
      // Unconditional: restore() only completes once the outcome is known, and
      // leaving this to an event meant a thrown restore disabled Buy for the
      // rest of the session.
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _retryProduct() async {
    setState(() => _status = null);
    await ref.read(premiumProvider.notifier).retryProductLoad();
  }

  /// Hidden developer aid: long-press the lock badge to read the on-device
  /// billing trace off a real handset. Intentionally untranslated — it is a
  /// diagnostic, not a user-facing feature.
  void _showDiagnostics() {
    final lines = ref.read(premiumProvider.notifier).diagnostics;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Billing diagnostics'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              lines.isEmpty ? 'No billing events recorded.' : lines.join('\n'),
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final state = ref.watch(premiumProvider);
    final busy = _buying || _restoring;
    final canBuy = state.productAvailable && !busy;
    final price = state.priceLabel;

    // A voluntary visit has nothing left to sell once the purchase lands, so
    // close it. The hard wall stays put and lets the router redirect instead.
    if (widget.dismissible) {
      ref.listen(premiumProvider, (prev, next) {
        if (next.isPremium && !(prev?.isPremium ?? false) && mounted) {
          Navigator.of(context).maybePop();
        }
      });
    }

    return PopScope(
      canPop: widget.dismissible,
      child: Scaffold(
        appBar: widget.dismissible ? AppBar() : null,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onLongPress: _showDiagnostics,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_open_rounded,
                        size: 48, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state.isInTrial ? l.paywallTitleTrial : l.paywallTitleExpired,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                state.isInTrial
                    ? l.paywallSubtitleTrial(state.trialDaysLeft)
                    : l.paywallSubtitleExpired,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              _feature(theme, Icons.cloud_off_rounded, l.paywallFeatureOffline),
              _feature(
                  theme, Icons.receipt_long_rounded, l.paywallFeatureScanner),
              _feature(theme, Icons.pie_chart_rounded, l.paywallFeatureReports),
              _feature(theme, Icons.savings_rounded, l.paywallFeatureBudgets),
              _feature(theme, Icons.lock_rounded, l.paywallFeaturePrivacy),
              _feature(
                  theme, Icons.language_rounded, l.paywallFeatureLanguages),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: canBuy ? _buy : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: _buying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    // Without a resolved price the button shows the plain
                    // unlock label; it never quotes a guessed currency.
                    : Text(price == null
                        ? l.paywallTitleTrial
                        : l.paywallBuyButton(price)),
              ),
              if (state.loadingProduct && !state.productAvailable) ...[
                const SizedBox(height: 16),
                const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ] else if (!state.productAvailable) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l.paywallProductUnavailable,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton.icon(
                    onPressed: busy ? null : _retryProduct,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l.paywallRetry),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: busy ? null : _restore,
                  child: _restoring
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.paywallRestore),
                ),
              ),
              // Expired, unpaid users still own their expense history. Leaving
              // them no way to get it out is what turns a paywall into a
              // refund request and a one-star review.
              if (!state.hasAccess) ...[
                Center(
                  child: TextButton.icon(
                    onPressed:
                        busy ? null : () => context.push(Routes.backup),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(l.moreBackupTitle),
                  ),
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _status!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l.paywallFinePrint,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(ThemeData theme, IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
          ],
        ),
      );
}
