import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/premium_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(pinLockProvider);
    final premium = ref.watch(premiumProvider);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.navMore)),
      body: ListView(
        children: [
          // The paywall used to be reachable only by redirect once the trial
          // had expired, so a user who wanted to pay during the trial — or to
          // restore a purchase after reinstalling — had nowhere to do it.
          if (!premium.isPremium)
            _unlockTile(context, l.paywallTitleTrial, l.paywallFinePrint),
          _tile(context, Icons.calendar_month_rounded, l.moreCalendarTitle, l.moreCalendarSubtitle, Routes.calendar),
          _tile(context, Icons.assessment_rounded, l.moreReportsTitle, l.moreReportsSubtitle, Routes.reports),
          _tile(context, Icons.autorenew_rounded, l.moreRecurringTitle, l.moreRecurringSubtitle, Routes.recurring),
          _tile(context, Icons.search_rounded, l.moreSearchTitle, l.moreSearchSubtitle, Routes.search),
          _tile(context, Icons.backup_rounded, l.moreBackupTitle, l.moreBackupSubtitle, Routes.backup),
          _tile(context, Icons.settings_rounded, l.moreSettingsTitle, l.moreSettingsSubtitle, Routes.settings),
          if (auth.hasPin)
            ListTile(
              leading: const Icon(Icons.lock_rounded),
              title: Text(l.moreLockNow),
              onTap: () {
                ref.read(pinLockProvider.notifier).lock();
              },
            ),
          _tile(context, Icons.info_outline_rounded, l.moreOnboardingTitle, l.moreOnboardingSubtitle, Routes.onboarding),
        ],
      ),
    );
  }

  Widget _unlockTile(BuildContext context, String title, String subtitle) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primaryContainer,
        ),
        child: Icon(Icons.lock_open_rounded, color: scheme.onPrimaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(paywallFromMoreRoute()),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(route),
    );
  }
}
