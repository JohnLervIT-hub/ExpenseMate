import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/utils/formatters.dart';

import '../../providers/repository_providers.dart';

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
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.backupRestoreConfirmTitle),
            content: Text(context.l10n.backupRestoreConfirmBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.actionCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.backupRestore)),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final restored = await ref.read(backupServiceProvider).restoreDatabase();
      setState(() => _status = restored ? 'Restored. Please restart the app.' : 'Cancelled');
    } catch (e) {
      setState(() => _status = 'Restore failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
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
      final bytes = await svc.buildExpensesPdf(expenses, cats);
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
            title: 'Export Database',
            subtitle: 'Save a copy of your SQLite database locally and share it.',
            action: 'Export & Share',
            onTap: _busy ? null : _exportDb,
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.restore_rounded,
            title: 'Restore Database',
            subtitle: 'Replace current data with a previous backup file.',
            action: 'Restore',
            onTap: _busy ? null : _restore,
          ),
          const SizedBox(height: 24),
          _rangeCard(context, l),
          const SizedBox(height: 12),
          _card(
            icon: Icons.description_rounded,
            title: 'Export Expenses as CSV',
            subtitle: 'For spreadsheets or manual analysis.',
            action: 'Export CSV',
            onTap: _busy ? null : _exportCsv,
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.table_chart_rounded,
            title: 'Export Expenses as Excel',
            subtitle: 'XLSX file with all your expenses.',
            action: 'Export Excel',
            onTap: _busy ? null : _exportExcel,
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Export Expenses as PDF',
            subtitle: 'Formatted PDF report of your expenses.',
            action: 'Export PDF',
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
