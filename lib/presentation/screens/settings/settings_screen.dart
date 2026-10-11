import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/demo_seed.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/format_prefs_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/notification_prefs_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencySymbolProvider);
    final auth = ref.watch(pinLockProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        children: [
          _sectionHeader(theme, context.l10n.settingsAppearance),
          RadioListTile<ThemeMode>(
            title: Text(context.l10n.settingsSystem),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).set(m!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(context.l10n.settingsLight),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).set(m!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(context.l10n.settingsDark),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).set(m!),
          ),
          _sectionHeader(theme, context.l10n.settingsPreferences),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: Text(context.l10n.settingsCurrency),
            subtitle: Text(_currencyLabel(currency)),
            trailing: Text(currency, style: theme.textTheme.titleMedium),
            onTap: () => _pickCurrency(context, ref, currency),
          ),
          Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(localeProvider);
              final currentLang = supportedLanguages.firstWhere(
                (l) => l.code == locale.languageCode,
                orElse: () => supportedLanguages.first,
              );
              return ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(context.l10n.settingsLanguage),
                subtitle: Text(currentLang.english),
                trailing: Text(currentLang.label, style: theme.textTheme.titleMedium),
                onTap: () => _pickLanguage(context, ref, locale.languageCode),
              );
            },
          ),
          Consumer(builder: (context, ref, _) {
            final pattern = ref.watch(dateFormatProvider);
            return ListTile(
              leading: const Icon(Icons.event_rounded),
              title: Text(context.l10n.settingsDateFormat),
              subtitle: Text(_dateSample(pattern)),
              trailing: Text(pattern, style: theme.textTheme.labelMedium),
              onTap: () => _pickDateFormat(context, ref, pattern),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final day = ref.watch(firstDayOfWeekProvider);
            return ListTile(
              leading: const Icon(Icons.today_rounded),
              title: Text(context.l10n.settingsFirstDayOfWeek),
              trailing: Text(
                day == 1 ? context.l10n.weekdayMonday : context.l10n.weekdaySunday,
                style: theme.textTheme.titleMedium,
              ),
              onTap: () => _pickFirstDay(context, ref, day),
            );
          }),
          _sectionHeader(theme, context.l10n.settingsNotifications),
          _notificationsSection(context, ref, theme),
          _sectionHeader(theme, context.l10n.settingsSecurity),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(auth.hasPin ? context.l10n.settingsChangePin : context.l10n.settingsSetPin),
            subtitle: Text(auth.hasPin ? context.l10n.settingsPinEnabled : context.l10n.settingsPinDisabled),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.pinSetup),
          ),
          if (auth.hasPin)
            ListTile(
              leading: const Icon(Icons.no_encryption_rounded),
              title: Text(context.l10n.settingsRemovePin),
              onTap: () async {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(context.l10n.settingsRemovePin),
                        content: Text(context.l10n.settingsRemovePinBody),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.actionCancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.actionRemove)),
                        ],
                      ),
                    ) ??
                    false;
                if (ok) await ref.read(pinLockProvider.notifier).clearPin();
              },
            ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded),
            title: Text(context.l10n.settingsBiometric),
            subtitle: Text(!auth.hasPin
                ? context.l10n.settingsBiometricNeedsPin
                : (auth.biometricAvailable
                    ? context.l10n.settingsBiometricAvailable
                    : context.l10n.settingsBiometricUnavailable)),
            value: auth.biometricEnabled,
            onChanged: (auth.hasPin && auth.biometricAvailable)
                ? (v) => ref.read(pinLockProvider.notifier).setBiometricEnabled(v)
                : null,
          ),
          _sectionHeader(theme, context.l10n.settingsData),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: Text(context.l10n.settingsBackup),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.backup),
          ),
          ListTile(
            leading: const Icon(Icons.assessment_rounded),
            title: Text(context.l10n.settingsReports),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.reports),
          ),
          ListTile(
            leading: Icon(Icons.restart_alt_rounded, color: theme.colorScheme.error),
            title: Text(context.l10n.settingsResetDemo,
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
            subtitle: Text(context.l10n.settingsResetDemoSubtitle),
            onTap: () => _resetDemo(context, ref),
          ),
          _sectionHeader(theme, context.l10n.settingsAbout),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (ctx, snap) {
              final v = snap.data?.version ?? '';
              return ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(context.l10n.appName),
                subtitle: Text(context.l10n.settingsVersion(v)),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _notificationsSection(BuildContext context, WidgetRef ref, ThemeData t) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    String timeStr() {
      final h = prefs.dailyHour;
      final m = prefs.dailyMinute.toString().padLeft(2, '0');
      final suffix = h >= 12 ? 'PM' : 'AM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:$m $suffix';
    }

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_rounded),
          title: Text(context.l10n.settingsDailyReminder),
          subtitle: Text(context.l10n.settingsDailyReminderSubtitle(timeStr())),
          value: prefs.dailyReminder,
          onChanged: notifier.setDailyReminder,
        ),
        if (prefs.dailyReminder)
          ListTile(
            leading: const SizedBox(width: 24),
            title: Text(context.l10n.settingsReminderTime),
            trailing: TextButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: prefs.dailyHour, minute: prefs.dailyMinute),
                );
                if (picked != null) {
                  await notifier.setDailyTime(picked.hour, picked.minute);
                }
              },
              child: Text(timeStr()),
            ),
          ),
        SwitchListTile(
          secondary: const Icon(Icons.date_range_rounded),
          title: Text(context.l10n.settingsWeeklyReview),
          subtitle: Text(context.l10n.settingsWeeklyReviewSubtitle),
          value: prefs.weeklyReview,
          onChanged: notifier.setWeeklyReview,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.warning_amber_rounded),
          title: Text(context.l10n.settingsBudgetAlerts),
          subtitle: Text(context.l10n.settingsBudgetAlertsSubtitle),
          value: prefs.budgetThresholdAlerts,
          onChanged: notifier.setBudgetAlerts,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.autorenew_rounded),
          title: Text(context.l10n.settingsBillReminders),
          subtitle: Text(context.l10n.settingsBillRemindersSubtitle),
          value: prefs.billReminders,
          onChanged: notifier.setBillReminders,
        ),
      ],
    );
  }

  Widget _sectionHeader(ThemeData t, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text(label,
            style: t.textTheme.labelLarge?.copyWith(
              color: t.colorScheme.primary,
              fontWeight: FontWeight.w700,
            )),
      );

  String _currencyLabel(String symbol) {
    final match = AppConstants.currencies.firstWhere(
      (c) => c.symbol == symbol,
      orElse: () => const CurrencyChoice(code: '—', symbol: '—', name: 'Custom'),
    );
    return '${match.code} · ${match.name}';
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref, String current) async {
    final chosen = await showModalBottomSheet<CurrencyChoice>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, controller) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(children: [
                  Text(context.l10n.settingsChooseCurrency,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${AppConstants.currencies.length} available',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: AppConstants.currencies.length,
                  itemBuilder: (ctx, i) {
                    final c = AppConstants.currencies[i];
                    final selected = c.symbol == current;
                    return ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Text(
                          c.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      title: Text('${c.code} — ${c.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(context.l10n.settingsSampleLabel(_sample(c.symbol))),
                      trailing: selected
                          ? Icon(Icons.check_circle_rounded,
                              color: theme.colorScheme.primary)
                          : null,
                      onTap: () => Navigator.pop(ctx, c),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (chosen != null) ref.read(currencySymbolProvider.notifier).set(chosen.symbol);
  }

  String _sample(String symbol) {
    return '$symbol' '1,250.00';
  }

  String _dateSample(String pattern) {
    try {
      return DateFormat(pattern).format(DateTime.now());
    } catch (_) {
      return pattern;
    }
  }

  Future<void> _pickDateFormat(BuildContext context, WidgetRef ref, String current) async {
    final theme = Theme.of(context);
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(context.l10n.settingsDateFormat,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            for (final p in supportedDatePatterns)
              ListTile(
                title: Text(p),
                subtitle: Text(_dateSample(p)),
                trailing: p == current
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) ref.read(dateFormatProvider.notifier).set(chosen);
  }

  Future<void> _pickFirstDay(BuildContext context, WidgetRef ref, int current) async {
    final theme = Theme.of(context);
    final chosen = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(context.l10n.settingsFirstDayOfWeek,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            RadioListTile<int>(
              title: Text(context.l10n.weekdaySunday),
              value: 7,
              groupValue: current,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            RadioListTile<int>(
              title: Text(context.l10n.weekdayMonday),
              value: 1,
              groupValue: current,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) ref.read(firstDayOfWeekProvider.notifier).set(chosen);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref, String current) async {
    final chosen = await showModalBottomSheet<AppLanguage>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, controller) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(children: [
                  Text(context.l10n.settingsChooseLanguage,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${supportedLanguages.length} available',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: supportedLanguages.length,
                  itemBuilder: (ctx, i) {
                    final lang = supportedLanguages[i];
                    return ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lang.code == current
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Text(
                          lang.code.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: lang.code == current
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      title: Text(lang.label,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(lang.english),
                      trailing: lang.code == current
                          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                          : null,
                      onTap: () => Navigator.pop(ctx, lang),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (chosen != null) ref.read(localeProvider.notifier).set(chosen.code);
  }

  Future<void> _resetDemo(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.restart_alt_rounded, color: theme.colorScheme.error),
        title: Text(context.l10n.settingsResetConfirmTitle),
        content: Text(context.l10n.settingsResetConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.actionReset),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await DemoSeed.reset(ref.read(appDatabaseProvider).db);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(expensesProvider);
      ref.invalidate(shoppingListsProvider);
      ref.invalidate(shoppingItemsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(calendarMonthProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.settingsResetSuccess)),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
