import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/default_categories.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static AppDatabase get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('AppDatabase not initialized. Call AppDatabase.initialize() in main() first.');
    }
    return i;
  }

  final Database _db;
  final String path;

  AppDatabase._(this._db, this.path);

  Database get db => _db;

  static Future<AppDatabase> initialize() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'expensemate.db');
    final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    if (isDesktop) {
      sqfliteFfiInit();
      final factory = databaseFactoryFfi;
      final db = await factory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onConfigure: (d) async {
            await d.execute('PRAGMA foreign_keys = ON');
          },
        ),
      );
      _instance = AppDatabase._(db, dbPath);
      return _instance!;
    }
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (d) async {
        await d.execute('PRAGMA foreign_keys = ON');
      },
    );
    _instance = AppDatabase._(db, dbPath);
    return _instance!;
  }

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        budget_amount REAL NOT NULL DEFAULT 0
      )
    ''');
    batch.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        merchant TEXT NOT NULL DEFAULT '',
        payment_method TEXT NOT NULL DEFAULT 'Cash',
        notes TEXT NOT NULL DEFAULT '',
        receipt_path TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET DEFAULT
      )
    ''');
    batch.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    batch.execute('CREATE INDEX idx_expenses_category ON expenses(category_id)');

    batch.execute('''
      CREATE TABLE income (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        source TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_income_date ON income(date)');

    batch.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        income REAL NOT NULL DEFAULT 0,
        savings_goal REAL NOT NULL DEFAULT 0,
        spending_limit REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        UNIQUE(month, year)
      )
    ''');

    batch.execute('''
      CREATE TABLE shopping_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        unit TEXT NOT NULL DEFAULT '',
        estimated_price REAL NOT NULL DEFAULT 0,
        actual_price REAL NOT NULL DEFAULT 0,
        store TEXT NOT NULL DEFAULT '',
        is_purchased INTEGER NOT NULL DEFAULT 0,
        notes TEXT NOT NULL DEFAULT '',
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (list_id) REFERENCES shopping_lists(id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_items_list ON shopping_items(list_id)');

    batch.execute('''
      CREATE TABLE recurring_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        merchant TEXT NOT NULL DEFAULT '',
        frequency TEXT NOT NULL DEFAULT 'Monthly',
        next_due TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    batch.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await batch.commit(noResult: true);

    // Seed default categories
    for (final c in DefaultCategories.seed()) {
      await db.insert('categories', c.toMap());
    }
  }
}
