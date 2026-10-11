import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/utils/formatters.dart';

import '../../providers/repository_providers.dart';
import '../../providers/user_name_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _status;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _rangeStart != null && _rangeEnd != null
          ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _rangeStart = picked.start;
        _rangeEnd = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
    }
  }

  void _clearRange() => setState(() {
        _rangeStart = null;
        _rangeEnd = null;
      });

  Future<void> _exportDb() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final svc = ref.read(backupServiceProvider);
      final path = await svc.exportDatabase();
      await svc.shareBackup(path);
      setState(() => _status = 'Backup created: $path');
    } catch (e) {
      setState(() => _status = 'Backup failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.backupRestoreConfirmTitle),
            content: Text(l.backupRestoreConfirmBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.backupRestore)),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    RestoreResult result = RestoreResult.error;
    try {
      result = await ref.read(backupServiceProvider).restoreDatabase();
    } catch (e) {
      debugPrint('restore error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    switch (result) {
      case RestoreResult.success:
        // DB is now closed and file replaced. If the user keeps interacting
        // with the app, every provider call throws. Force a close via a
        // non-dismissible dialog so they must reopen from Play Store icon.
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(l.backupRestoreSuccessTitle),
              content: Text(l.backupRestoreSuccessBody),
              actions: [
                FilledButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text(l.backupRestoreCloseApp),
                ),
              ],
            ),
          ),
        );
        break;
      case RestoreResult.cancelled:
        setState(() => _status = l.backupRestoreCancelled);
        break;
      case RestoreResult.invalidFile:
        setState(() => _status = l.backupRestoreInvalidFile);
        break;
      case RestoreResult.error:
        setState(() => _status = l.backupRestoreError);
        break;
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final expenses = await ref
          .read(expenseRepositoryProvider)
          .getAll(start: _rangeStart, end: _rangeEnd);
      final cats = await ref.read(categoryRepositoryProvider).getAll();
      final path = await ref.read(exportServiceProvider).exportExpensesCsv(expenses, cats);
      setState(() => _status = 'CSV saved (${expenses.length} rows): $path');
    } catch (e) {
      setState(() => _status = 'CSV export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _busy = true);
    try {
      final expenses = await ref
          .read(expenseRepositoryProvider)
          .getAll(start: _rangeStart, end: _rangeEnd);
      final cats = await ref.read(categoryRepositoryProvider).getAll();
      final path = await ref.read(exportServiceProvider).exportExpensesExcel(expenses, cats);
      setState(() => _status = 'Excel saved (${expenses.length} rows): $path');
    } catch (e) {
      setState(() => _status = 'Excel export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _busy = true);
    try {
      final expenses = await ref
          .read(expenseRepositoryProvider)
          .getAll(start: _rangeStart, end: _rangeEnd);
      final cats = await ref.read(categoryRepositoryProvider).getAll();
      final svc = ref.read(exportServiceProvider);
      final name = ref.read(userNameProvider);
      final preparedFor =
          name.isEmpty ? null : context.l10n.backupPdfPreparedFor(name);
      final bytes = await svc.buildExpensesPdf(
        expenses,
        cats,
        preparedFor: preparedFor,
      );
      await svc.printOrShare(bytes, 'expenses.pdf');
      setState(() => _status = 'PDF prepared (${expenses.length} rows)');
    } catch (e) {
      setState(() => _status = 'PDF export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.backupExportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            icon: Icons.cloud_upload_outlined,
            title: l.backupExportDatabase,
            subtitle: l.backupExportDatabaseBody,
            action: l.backupExportShare,
            onTap: _busy ? null : _exportDb,
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.restore_rounded,
            title: l.backupRestoreDatabase,
            subtitle: l.backupRestoreDatabaseBody,
            action: l.backupRestore,
            onTap: _busy ? null : _restore,
          ),
          const SizedBox(height: 24),
          _rangeCard(context, l),
          const SizedBox(height: 12),
          _card(
            icon: Icons.description_rounded,
            title: l.backupExportCsvTitle,
            subtitle: l.backupExportCsvBody,
            action: l.backupExportCsvAction,
            onTap: _busy ? null : _exportCsv,
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.table_chart_rounded,
            title: l.backupExportExcelTitle,
            subtitle: l.backupExportExcelBody,
            action: l.backupExportExcelAction,
            onTap: _busy ? null : _exportExcel,
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.picture_as_pdf_rounded,
            title: l.backupExportPdfTitle,
            subtitle: l.backupExportPdfBody,
            action: l.backupExportPdfAction,
            onTap: _busy ? null : _exportPdf,
          ),
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_status != null) ...[
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_status!, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rangeCard(BuildContext context, dynamic l) {
    final theme = Theme.of(context);
    final hasRange = _rangeStart != null && _rangeEnd != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.tertiaryContainer,
              child: Icon(Icons.date_range_rounded,
                  color: theme.colorScheme.onTertiaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.expensesFilterDateRange,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    hasRange
                        ? '${formatShortDate(_rangeStart!)}  —  ${formatShortDate(_rangeEnd!)}'
                        : l.filterAllTime,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (hasRange)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _busy ? null : _clearRange,
                tooltip: l.actionClear,
              ),
            TextButton(
              onPressed: _busy ? null : _pickRange,
              child: Text(hasRange ? l.actionEdit : l.filterCustom),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(onPressed: onTap, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
