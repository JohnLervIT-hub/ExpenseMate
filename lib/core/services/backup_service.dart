import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/database/app_database.dart';

class BackupService {
  const BackupService();

  Future<String> exportDatabase() async {
    final dbPath = AppDatabase.instance.path;
    final source = File(dbPath);
    if (!await source.exists()) {
      throw StateError('Database file not found at $dbPath');
    }
    final backupsDir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'backups'));
    if (!await backupsDir.exists()) await backupsDir.create(recursive: true);
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final destPath = p.join(backupsDir.path, 'expensemate_$stamp.db');
    await source.copy(destPath);
    return destPath;
  }

  Future<void> shareBackup(String path) async {
    await Share.shareXFiles([XFile(path)], text: 'ExpenseMate backup');
  }

  /// Returns true on success. Restores DB by overwriting the current sqlite file.
  /// App restart is required to pick up the new database (caller should prompt user).
  Future<bool> restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose backup file',
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return false;
    final picked = result.files.single;
    if (picked.path == null) return false;
    final src = File(picked.path!);
    if (!await src.exists()) return false;

    final dbPath = AppDatabase.instance.path;
    try {
      await AppDatabase.instance.close();
    } catch (e) {
      debugPrint('close db failed: $e');
    }
    await src.copy(dbPath);
    return true;
  }
}
