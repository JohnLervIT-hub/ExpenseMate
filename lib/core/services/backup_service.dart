import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/database/app_database.dart';

/// Outcome of a restore attempt so callers can show the right message.
enum RestoreResult {
  success,
  cancelled,
  invalidFile,
  error,
}

class BackupService {
  const BackupService();

  // First 16 bytes of every valid SQLite 3 file. Verifying this prevents
  // users from restoring a JPEG, PDF, or unrelated binary and corrupting
  // their install on next launch.
  static const List<int> _sqliteMagic = <int>[
    0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
    0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
  ];

  Future<String> exportDatabase() async {
    final dbPath = AppDatabase.instance.path;
    final source = File(dbPath);
    if (!await source.exists()) {
      throw StateError('Database file not found at $dbPath');
    }
    final backupsDir = await _backupsDir();
    final stamp = _timestamp();
    final destPath = p.join(backupsDir.path, 'expensemate_$stamp.db');
    await source.copy(destPath);
    return destPath;
  }

  Future<void> shareBackup(String path) async {
    await Share.shareXFiles([XFile(path)], text: 'ExpenseMate backup');
  }

  /// Restores DB by overwriting the current sqlite file after validating the
  /// picked file is a real SQLite database. Also snapshots the current DB
  /// into a `pre-restore` file so users can recover if the restored data
  /// turns out to be wrong.
  ///
  /// App restart is required to pick up the new database — the caller must
  /// prompt the user (see RestoreResult).
  Future<RestoreResult> restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose backup file',
      type: FileType.custom,
      allowedExtensions: const ['db'],
    );
    if (result == null || result.files.isEmpty) return RestoreResult.cancelled;
    final picked = result.files.single;
    if (picked.path == null) return RestoreResult.error;

    final src = File(picked.path!);
    if (!await src.exists()) return RestoreResult.error;

    // Belt-and-suspenders — some platforms let picker return other extensions.
    if (p.extension(src.path).toLowerCase() != '.db') {
      return RestoreResult.invalidFile;
    }

    if (!await _looksLikeSqlite(src)) return RestoreResult.invalidFile;

    final dbPath = AppDatabase.instance.path;
    final currentDb = File(dbPath);

    // Snapshot current DB before overwriting so a bad restore is recoverable.
    try {
      if (await currentDb.exists()) {
        final backupsDir = await _backupsDir();
        final safety = p.join(backupsDir.path, 'pre-restore_${_timestamp()}.db');
        await currentDb.copy(safety);
      }
    } catch (e) {
      debugPrint('pre-restore snapshot failed: $e');
      // Refuse to overwrite if we can't take a safety snapshot — losing
      // the user's data with no recovery is not acceptable.
      return RestoreResult.error;
    }

    try {
      await AppDatabase.instance.close();
    } catch (e) {
      debugPrint('close db failed: $e');
    }

    try {
      await src.copy(dbPath);
    } catch (e) {
      debugPrint('restore copy failed: $e');
      return RestoreResult.error;
    }
    return RestoreResult.success;
  }

  Future<Directory> _backupsDir() async {
    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'backups'),
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _timestamp() =>
      DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;

  Future<bool> _looksLikeSqlite(File file) async {
    try {
      final raf = await file.open();
      try {
        final header = await raf.read(_sqliteMagic.length);
        if (header.length < _sqliteMagic.length) return false;
        return _bytesMatch(header, _sqliteMagic);
      } finally {
        await raf.close();
      }
    } catch (e) {
      debugPrint('sqlite magic check failed: $e');
      return false;
    }
  }

  bool _bytesMatch(Uint8List actual, List<int> expected) {
    for (var i = 0; i < expected.length; i++) {
      if (actual[i] != expected[i]) return false;
    }
    return true;
  }
}
