import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/onboarding_provider.dart';
import '../constants/app_config.dart';
import '../../presentation/screens/auth/lock_screen.dart';
import '../../presentation/screens/auth/pin_setup_screen.dart';
import '../../presentation/screens/budget/budget_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/expenses/expense_form_screen.dart';
import '../../presentation/screens/expenses/expenses_screen.dart';
import '../../presentation/screens/expenses/scan_receipt_screen.dart';
import '../../presentation/screens/grocery/grocery_screen.dart';
import '../../presentation/screens/grocery/shopping_list_detail_screen.dart';
import '../../presentation/screens/grocery/shopping_list_form_screen.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/more/more_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/recurring/recurring_form_screen.dart';
import '../../presentation/screens/recurring/recurring_screen.dart';
import '../../presentation/screens/reports/reports_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/providers/premium_provider.dart';
import '../../presentation/screens/paywall/paywall_screen.dart';
import '../../presentation/screens/settings/backup_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../constants/app_constants.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod → GoRouter so redirect re-runs when access-controlling
  // state changes (e.g. purchase confirmed, PIN unlocked, onboarding done).
  // Without this the paywall would not dismiss until the next navigation.
  final refresh = _RouterRefresh();
  ref.listen(premiumProvider, (_, __) => refresh.notify());
  ref.listen(pinLockProvider, (_, __) => refresh.notify());
  ref.listen(hasOnboardedProvider, (_, __) => refresh.notify());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(pinLockProvider);
      final hasOnboarded = ref.read(hasOnboardedProvider);
      final premium = ref.read(premiumProvider);
      final loc = state.matchedLocation;
      final atLock = loc == Routes.lock;
      final atOnboarding = loc == Routes.onboarding;
      final atSplash = loc == Routes.splash;
      final atPaywall = loc == Routes.paywall;

      if (atSplash) return null;

      if (auth.hasPin && !auth.isUnlocked && !atLock) return Routes.lock;
      if (atLock && auth.isUnlocked) return Routes.dashboard;

      if (AppConfig.demoMode) return null;

      if (!hasOnboarded && !atOnboarding) return Routes.onboarding;

      // Paywall: block app when trial is expired AND user hasn't purchased.
      if (!premium.hasAccess && !atPaywall) return Routes.paywall;
      if (atPaywall && premium.hasAccess) return Routes.dashboard;

      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.paywall, builder: (_, __) => const PaywallScreen()),
      GoRoute(path: Routes.lock, builder: (_, __) => const LockScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: Routes.pinSetup, builder: (_, __) => const PinSetupScreen()),
      GoRoute(path: Routes.reports, builder: (_, __) => const ReportsScreen()),
      GoRoute(path: Routes.settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: Routes.backup, builder: (_, __) => const BackupScreen()),
      GoRoute(path: Routes.search, builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: Routes.expenseNew,
        builder: (_, s) => ExpenseFormScreen(prefill: s.extra is ScanPayload ? s.extra as ScanPayload : null),
      ),
      GoRoute(
        path: '/expenses/edit/:id',
        builder: (_, s) => ExpenseFormScreen(expenseId: int.tryParse(s.pathParameters['id'] ?? '')),
      ),
      GoRoute(path: Routes.expenseScan, builder: (_, __) => const ScanReceiptScreen()),
      GoRoute(path: Routes.calendar, builder: (_, __) => const CalendarScreen()),
      GoRoute(path: Routes.recurring, builder: (_, __) => const RecurringScreen()),
      GoRoute(path: Routes.recurringNew, builder: (_, __) => const RecurringFormScreen()),
      GoRoute(
        path: '/recurring/edit/:id',
        builder: (_, s) => RecurringFormScreen(recurringId: int.tryParse(s.pathParameters['id'] ?? '')),
      ),
      GoRoute(path: Routes.groceryNew, builder: (_, __) => const ShoppingListFormScreen()),
      GoRoute(
        path: '/grocery/list/:id',
        builder: (_, s) => ShoppingListDetailScreen(listId: int.parse(s.pathParameters['id']!)),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: Routes.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: Routes.expenses, builder: (_, __) => const ExpensesScreen()),
          GoRoute(path: Routes.grocery, builder: (_, __) => const GroceryScreen()),
          GoRoute(path: Routes.budget, builder: (_, __) => const BudgetScreen()),
          GoRoute(path: Routes.more, builder: (_, __) => const MoreScreen()),
        ],
      ),
    ],
  );
});
