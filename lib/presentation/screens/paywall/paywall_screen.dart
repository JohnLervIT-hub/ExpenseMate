import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/purchase_service.dart';
import '../../providers/premium_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

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
    setState(() {
      _status = null;
      if (event == PurchaseEvent.restoredNothing || event == PurchaseEvent.error) {
        _restoring = false;
        _buying = false;
      }
    });
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
      // Service emits restoredNothing after a short window if no purchase
      // came back; that handler clears _restoring. Keep spinner meanwhile.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final state = ref.watch(premiumProvider);
    final busy = _buying || _restoring;
    final canBuy = state.productAvailable && !busy;

    // Purchase confirmed while on this screen? Router refreshListenable
    // reacts to premiumProvider and redirects us to /dashboard.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              Center(
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
              const SizedBox(height: 24),
              Text(
                state.isInTrial ? l.paywallTitleTrial : l.paywallTitleExpired,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
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
              _feature(theme, Icons.receipt_long_rounded, l.paywallFeatureScanner),
              _feature(theme, Icons.pie_chart_rounded, l.paywallFeatureReports),
              _feature(theme, Icons.savings_rounded, l.paywallFeatureBudgets),
              _feature(theme, Icons.lock_rounded, l.paywallFeaturePrivacy),
              _feature(theme, Icons.language_rounded, l.paywallFeatureLanguages),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: canBuy ? _buy : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: _buying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(l.paywallBuyButton(state.priceLabel)),
              ),
              if (!state.productAvailable) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l.paywallProductUnavailable,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
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
