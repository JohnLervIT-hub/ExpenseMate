import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/purchase_service.dart';

@immutable
class PremiumState {
  final bool isPremium;
  final int trialDaysLeft;
  final String priceLabel;
  final bool productAvailable;

  const PremiumState({
    required this.isPremium,
    required this.trialDaysLeft,
    required this.priceLabel,
    required this.productAvailable,
  });

  bool get isInTrial => trialDaysLeft > 0;
  bool get hasAccess => isPremium || isInTrial;

  PremiumState copyWith({
    bool? isPremium,
    int? trialDaysLeft,
    String? priceLabel,
    bool? productAvailable,
  }) =>
      PremiumState(
        isPremium: isPremium ?? this.isPremium,
        trialDaysLeft: trialDaysLeft ?? this.trialDaysLeft,
        priceLabel: priceLabel ?? this.priceLabel,
        productAvailable: productAvailable ?? this.productAvailable,
      );

  static const initial = PremiumState(
    isPremium: false,
    trialDaysLeft: AppConstants.trialDays,
    priceLabel: '\$3.99',
    productAvailable: false,
  );
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PurchaseService _svc;

  PremiumNotifier(this._svc) : super(PremiumState.initial) {
    _svc.premiumNotifier.addListener(_syncFromService);
    _svc.productNotifier.addListener(_syncFromService);
    _refresh();
  }

  Future<void> _refresh() async {
    final days = await _svc.trialDaysLeft();
    state = state.copyWith(
      isPremium: _svc.isPremium,
      trialDaysLeft: days,
      priceLabel: _svc.priceLabel,
      productAvailable: _svc.productAvailable,
    );
  }

  void _syncFromService() {
    state = state.copyWith(
      isPremium: _svc.isPremium,
      priceLabel: _svc.priceLabel,
      productAvailable: _svc.productAvailable,
    );
  }

  Stream<PurchaseEvent> get events => _svc.events;

  Future<bool> buy() => _svc.buy();
  Future<void> restore() => _svc.restore();

  @override
  void dispose() {
    _svc.premiumNotifier.removeListener(_syncFromService);
    _svc.productNotifier.removeListener(_syncFromService);
    super.dispose();
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(PurchaseService.instance),
);
