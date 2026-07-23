import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/l10n_extension.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  List<(String, IconData, IconData, String)> _tabs(BuildContext context) {
    final l = context.l10n;
    return [
      (Routes.dashboard, Icons.dashboard_rounded, Icons.dashboard_outlined, l.navHome),
      (Routes.expenses, Icons.receipt_long_rounded, Icons.receipt_long_outlined, l.navExpenses),
      (Routes.grocery, Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, l.navGrocery),
      (Routes.budget, Icons.savings_rounded, Icons.savings_outlined, l.navBudget),
      (Routes.more, Icons.menu_rounded, Icons.menu_outlined, l.navMore),
    ];
  }

  int _selectedIndex(String location, List<(String, IconData, IconData, String)> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs(context);
    final loc = GoRouterState.of(context).matchedLocation;
    final selected = _selectedIndex(loc, tabs);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(selected),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => context.go(tabs[i].$1),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.$3),
              selectedIcon: Icon(t.$2),
              label: t.$4,
            ),
        ],
      ),
    );
  }
}
