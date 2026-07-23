import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Seeds a realistic US-profile dataset the first time the app runs
/// (i.e. when both `expenses` and `shopping_lists` tables are empty).
///
/// - 6 months of expenses across all 14 default categories, weighted realistically.
/// - Monthly salary + a couple of side-gig entries.
/// - Current-month budget + category budgets on 5 categories (with one overspent).
/// - Two shopping lists: one in-progress, one completed.
class DemoSeed {
  /// Uses a fixed seed so the demo data is deterministic across launches.
  static const _seed = 20260718;

  static Future<void> seedIfEmpty(Database db) async {
    try {
      final expCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM expenses')) ?? 0;
      final listCount =
          Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM shopping_lists')) ?? 0;
      if (expCount > 0 || listCount > 0) return;
      await _seed_(db);
    } catch (e) {
      debugPrint('DemoSeed error: $e');
    }
  }

  /// Wipes all transactional data (expenses, income, budgets, shopping lists +
  /// items, recurring rules, category budget amounts) and re-inserts the
  /// deterministic demo dataset. Categories, settings, PIN and theme are kept.
  static Future<void> reset(Database db) async {
    try {
      await db.transaction((txn) async {
        await txn.delete('expenses');
        await txn.delete('income');
        await txn.delete('budgets');
        await txn.delete('shopping_items');
        await txn.delete('shopping_lists');
        await txn.delete('recurring_expenses');
        await txn.update('categories', {'budget_amount': 0});
      });
      await _seed_(db);
    } catch (e) {
      debugPrint('DemoSeed.reset error: $e');
      rethrow;
    }
  }

  static Future<void> _seed_(Database db) async {
    final rng = Random(_seed);
    final now = DateTime.now();

    // Category name → id lookup (default categories were seeded at DB create).
    final catRows = await db.query('categories');
    final catId = <String, int>{for (final r in catRows) (r['name'] as String).toLowerCase(): r['id'] as int};

    int cat(String name) => catId[name.toLowerCase()] ?? catRows.first['id'] as int;

    // --- Expenses across the last 6 months ------------------------------------
    final batch = db.batch();

    for (var monthOffset = 5; monthOffset >= 0; monthOffset--) {
      final anchor = DateTime(now.year, now.month - monthOffset, 1);
      final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;

      DateTime randDate(int minDay, int maxDay) {
        var lo = min(daysInMonth, max(1, minDay));
        var hi = min(daysInMonth, max(1, maxDay));
        if (lo > hi) {
          final t = lo;
          lo = hi;
          hi = t;
        }
        final range = hi - lo + 1;
        final day = lo + rng.nextInt(range);
        return DateTime(anchor.year, anchor.month, day, 8 + rng.nextInt(12), rng.nextInt(60));
      }

      double randAmount(double min, double max) =>
          (min + rng.nextDouble() * (max - min));

      String pick(List<String> options) => options[rng.nextInt(options.length)];
      String pickPayment() {
        final r = rng.nextDouble();
        if (r < 0.40) return 'Debit Card';
        if (r < 0.75) return 'Credit Card';
        if (r < 0.90) return 'Cash';
        if (r < 0.97) return 'Bank Transfer';
        return 'Digital Wallet';
      }

      void ins({
        required String category,
        required String merchant,
        required double amount,
        required DateTime date,
        String notes = '',
        bool isFavorite = false,
        String? paymentMethod,
      }) {
        final pm = paymentMethod ?? pickPayment();
        batch.insert('expenses', {
          'amount': double.parse(amount.toStringAsFixed(2)),
          'category_id': cat(category),
          'merchant': merchant,
          'payment_method': pm,
          'notes': notes,
          'receipt_path': null,
          'is_favorite': isFavorite ? 1 : 0,
          'date': date.toIso8601String(),
          'created_at': date.toIso8601String(),
          'updated_at': date.toIso8601String(),
        });
      }

      // Groceries: 4-5/month, spread across weeks
      for (var i = 0; i < 4 + rng.nextInt(2); i++) {
        ins(
          category: 'Groceries',
          merchant: pick(const ['Whole Foods', 'Trader Joe\'s', 'Safeway', 'Costco', 'Aldi']),
          amount: randAmount(32, 175),
          date: randDate(1 + i * 7, 6 + i * 7 < daysInMonth ? 6 + i * 7 : daysInMonth),
          paymentMethod: 'Credit Card',
        );
      }

      // Fuel: 3-4/month
      for (var i = 0; i < 3 + rng.nextInt(2); i++) {
        ins(
          category: 'Fuel',
          merchant: pick(const ['Shell', 'Chevron', 'Costco Gas', 'BP', 'Arco']),
          amount: randAmount(32, 68),
          date: randDate(2 + i * 8, 7 + i * 8 < daysInMonth ? 7 + i * 8 : daysInMonth),
          paymentMethod: 'Credit Card',
        );
      }

      // Rent: 1/month, first of the month
      ins(
        category: 'Rent',
        merchant: 'Ridgeview Apartments',
        amount: 2100,
        date: DateTime(anchor.year, anchor.month, 1, 9, 0),
        notes: 'Monthly rent',
        paymentMethod: 'Bank Transfer',
      );

      // Utilities: internet, electric, water
      ins(
        category: 'Utilities',
        merchant: 'Comcast',
        amount: 79.99,
        date: DateTime(anchor.year, anchor.month, 5 + rng.nextInt(3), 10, 0),
        notes: 'Internet',
        paymentMethod: 'Debit Card',
      );
      ins(
        category: 'Utilities',
        merchant: 'PG&E',
        amount: randAmount(85, 165),
        date: DateTime(anchor.year, anchor.month, 12 + rng.nextInt(4), 10, 0),
        notes: 'Electric',
        paymentMethod: 'Bank Transfer',
      );
      ins(
        category: 'Utilities',
        merchant: 'City Water',
        amount: randAmount(38, 62),
        date: DateTime(anchor.year, anchor.month, 20 + rng.nextInt(4), 10, 0),
        paymentMethod: 'Bank Transfer',
      );

      // Dining: 8-14/month — heavier for current & recent months to trigger overspend
      final diningCount = monthOffset == 0 ? 14 : (8 + rng.nextInt(5));
      for (var i = 0; i < diningCount; i++) {
        ins(
          category: 'Dining',
          merchant: pick(const [
            'Chipotle', 'Sweetgreen', 'Starbucks', 'Blue Bottle Coffee', 'Panera',
            'In-N-Out', 'DoorDash', 'Uber Eats', 'Local Bistro', 'Ramen House',
          ]),
          amount: randAmount(9, 52),
          date: randDate(1, daysInMonth),
        );
      }

      // Shopping: 2-4/month
      for (var i = 0; i < 2 + rng.nextInt(3); i++) {
        ins(
          category: 'Shopping',
          merchant: pick(const ['Amazon', 'Target', 'Best Buy', 'Nike', 'REI', 'Nordstrom']),
          amount: randAmount(22, 275),
          date: randDate(1, daysInMonth),
          paymentMethod: 'Credit Card',
        );
      }

      // Entertainment: subscriptions + occasional outing
      ins(
        category: 'Entertainment',
        merchant: 'Netflix',
        amount: 15.49,
        date: DateTime(anchor.year, anchor.month, 4, 8, 0),
        notes: 'Streaming',
        paymentMethod: 'Credit Card',
      );
      ins(
        category: 'Entertainment',
        merchant: 'Spotify',
        amount: 11.99,
        date: DateTime(anchor.year, anchor.month, 8, 8, 0),
        paymentMethod: 'Credit Card',
      );
      if (rng.nextDouble() > 0.4) {
        ins(
          category: 'Entertainment',
          merchant: pick(const ['AMC Theatres', 'Steam', 'Disney+', 'Concert']),
          amount: randAmount(11, 48),
          date: randDate(10, daysInMonth),
        );
      }

      // Healthcare: 0-2/month
      for (var i = 0; i < rng.nextInt(3); i++) {
        ins(
          category: 'Healthcare',
          merchant: pick(const ['CVS Pharmacy', 'Walgreens', 'Kaiser Permanente']),
          amount: randAmount(18, 145),
          date: randDate(1, daysInMonth),
          paymentMethod: 'Debit Card',
        );
      }

      // Transportation: 4-8/month
      for (var i = 0; i < 4 + rng.nextInt(5); i++) {
        ins(
          category: 'Transportation',
          merchant: pick(const ['Uber', 'Lyft', 'BART', 'Metro', 'Parking Meter']),
          amount: randAmount(8, 42),
          date: randDate(1, daysInMonth),
          paymentMethod: rng.nextBool() ? 'Digital Wallet' : 'Credit Card',
        );
      }

      // Insurance: 1/month
      ins(
        category: 'Insurance',
        merchant: pick(const ['State Farm', 'Geico']),
        amount: 165.50,
        date: DateTime(anchor.year, anchor.month, 3, 8, 0),
        notes: 'Auto',
        paymentMethod: 'Bank Transfer',
      );

      // Education: 0-1/month
      if (rng.nextDouble() > 0.5) {
        ins(
          category: 'Education',
          merchant: pick(const ['Udemy', 'Coursera', 'Bookshop']),
          amount: randAmount(12, 44),
          date: randDate(1, daysInMonth),
          paymentMethod: 'Credit Card',
        );
      }

      // Travel: only 2 across all 6 months
      if (monthOffset == 4 || monthOffset == 1) {
        ins(
          category: 'Travel',
          merchant: pick(const ['United Airlines', 'Delta', 'Airbnb', 'Marriott']),
          amount: randAmount(285, 785),
          date: randDate(5, 20),
          notes: 'Weekend trip',
          isFavorite: true,
          paymentMethod: 'Credit Card',
        );
      }

      // Gifts: 0-2/month
      for (var i = 0; i < rng.nextInt(3); i++) {
        ins(
          category: 'Gifts',
          merchant: pick(const ['Etsy', 'Amazon', 'Local Boutique']),
          amount: randAmount(24, 120),
          date: randDate(1, daysInMonth),
          paymentMethod: 'Credit Card',
        );
      }

      // Miscellaneous: 1-2/month
      for (var i = 0; i < 1 + rng.nextInt(2); i++) {
        ins(
          category: 'Miscellaneous',
          merchant: pick(const ['Pet Store', 'Dry Cleaner', 'Hardware Store', 'Cash Withdrawal']),
          amount: randAmount(12, 65),
          date: randDate(1, daysInMonth),
          paymentMethod: 'Cash',
        );
      }
    }

    // --- Incomes --------------------------------------------------------------
    final currentAnchor = DateTime(now.year, now.month, 1, 9, 0);
    for (var monthOffset = 5; monthOffset >= 0; monthOffset--) {
      final anchor = DateTime(now.year, now.month - monthOffset, 1, 9, 0);
      batch.insert('income', {
        'amount': 5000.00,
        'source': 'Salary',
        'date': DateTime(anchor.year, anchor.month, 1, 9, 0).toIso8601String(),
        'notes': 'Bi-weekly + bi-weekly',
        'created_at': anchor.toIso8601String(),
      });
      if (monthOffset == 0 || monthOffset == 3) {
        batch.insert('income', {
          'amount': monthOffset == 0 ? 620.00 : 480.00,
          'source': 'Freelance',
          'date': DateTime(anchor.year, anchor.month, 15, 14, 30).toIso8601String(),
          'notes': 'Side gig',
          'created_at': anchor.toIso8601String(),
        });
      }
    }

    // --- Current-month budget -------------------------------------------------
    batch.insert('budgets', {
      'month': currentAnchor.month,
      'year': currentAnchor.year,
      'income': 5500.00,
      'savings_goal': 1500.00,
      'spending_limit': 4000.00,
      'created_at': currentAnchor.toIso8601String(),
    });

    // --- Category budgets (5 set, one intentionally overspent = Dining) -------
    Future<void> setCatBudget(String name, double amount) async {
      final id = cat(name);
      batch.update('categories', {'budget_amount': amount}, where: 'id = ?', whereArgs: [id]);
    }

    await setCatBudget('Groceries', 700);
    await setCatBudget('Dining', 250);
    await setCatBudget('Entertainment', 100);
    await setCatBudget('Shopping', 300);
    await setCatBudget('Fuel', 200);

    await batch.commit(noResult: true);

    // --- Recurring rules (auto-log rent, subscriptions, insurance) ------------
    final futureAnchor = DateTime(now.year, now.month, now.day);
    final ruleBatch = db.batch();
    ruleBatch.insert('recurring_expenses', {
      'amount': 15.49,
      'category_id': cat('Entertainment'),
      'merchant': 'Netflix',
      'frequency': 'Monthly',
      'next_due': futureAnchor.add(const Duration(days: 4)).toIso8601String(),
      'is_active': 1,
    });
    ruleBatch.insert('recurring_expenses', {
      'amount': 2100.00,
      'category_id': cat('Rent'),
      'merchant': 'Ridgeview Apartments',
      'frequency': 'Monthly',
      'next_due': DateTime(now.year, now.month + 1, 1, 9, 0).toIso8601String(),
      'is_active': 1,
    });
    ruleBatch.insert('recurring_expenses', {
      'amount': 165.50,
      'category_id': cat('Insurance'),
      'merchant': 'State Farm',
      'frequency': 'Monthly',
      'next_due': DateTime(now.year, now.month + 1, 3, 9, 0).toIso8601String(),
      'is_active': 1,
    });
    await ruleBatch.commit(noResult: true);

    // --- Shopping lists -------------------------------------------------------
    final nowIso = DateTime.now().toIso8601String();
    final listBatch = db.batch();

    // List 1: current week — partially checked
    final list1Id = await db.insert('shopping_lists', {
      'name': "This Week's Groceries",
      'is_favorite': 1,
      'is_archived': 0,
      'created_at': nowIso,
      'updated_at': nowIso,
    });
    const items1 = <List<dynamic>>[
      // name, qty, unit, estimated, actual, store, purchased, notes
      ['Bananas', 1.5, 'lb', 1.20, 1.28, 'Whole Foods', 1, ''],
      ['Greek yogurt', 4, 'ct', 5.99, 5.99, 'Whole Foods', 1, 'Plain'],
      ['Sourdough bread', 1, 'loaf', 6.50, 6.50, 'Whole Foods', 1, ''],
      ['Salmon fillet', 1, 'lb', 14.99, 15.75, 'Whole Foods', 1, ''],
      ['Baby spinach', 2, 'bag', 3.99, 0, 'Trader Joe\'s', 0, ''],
      ['Almond milk', 1, 'ct', 3.49, 0, 'Trader Joe\'s', 0, 'Unsweetened'],
      ['Eggs', 1, 'dz', 5.29, 0, 'Trader Joe\'s', 0, ''],
      ['Olive oil', 1, 'bottle', 12.99, 0, 'Trader Joe\'s', 0, ''],
      ['Blueberries', 1, 'pt', 4.49, 0, 'Trader Joe\'s', 0, ''],
      ['Chicken breast', 2, 'lb', 8.99, 0, 'Costco', 0, ''],
    ];
    for (var i = 0; i < items1.length; i++) {
      final it = items1[i];
      listBatch.insert('shopping_items', {
        'list_id': list1Id,
        'name': it[0],
        'quantity': it[1],
        'unit': it[2],
        'estimated_price': it[3],
        'actual_price': it[4],
        'store': it[5],
        'is_purchased': it[6],
        'notes': it[7],
        'sort_order': i + 1,
      });
    }

    // List 2: last weekend — completed
    final list2Id = await db.insert('shopping_lists', {
      'name': 'Weekend BBQ',
      'is_favorite': 0,
      'is_archived': 0,
      'created_at': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
    });
    const items2 = <List<dynamic>>[
      ['Ribeye steak', 3, 'lb', 24.99, 27.50, 'Costco', 1, ''],
      ['Corn on the cob', 6, 'ct', 3.99, 3.99, 'Safeway', 1, ''],
      ['Charcoal', 1, 'bag', 12.99, 12.99, 'Home Depot', 1, ''],
      ['Buns', 2, 'pack', 4.49, 4.49, 'Safeway', 1, ''],
      ['Cheddar slices', 1, 'pack', 5.99, 5.99, 'Safeway', 1, ''],
      ['Lettuce', 1, 'head', 2.49, 2.49, 'Safeway', 1, ''],
      ['Tomatoes', 3, 'ct', 3.49, 3.49, 'Safeway', 1, ''],
      ['Beers', 12, 'pack', 18.99, 21.50, 'BevMo', 1, 'IPA'],
      ['Ice', 2, 'bag', 4.99, 4.99, 'Gas Station', 1, ''],
    ];
    for (var i = 0; i < items2.length; i++) {
      final it = items2[i];
      listBatch.insert('shopping_items', {
        'list_id': list2Id,
        'name': it[0],
        'quantity': it[1],
        'unit': it[2],
        'estimated_price': it[3],
        'actual_price': it[4],
        'store': it[5],
        'is_purchased': it[6],
        'notes': it[7],
        'sort_order': i + 1,
      });
    }

    await listBatch.commit(noResult: true);
    debugPrint('DemoSeed: populated demo data.');
  }
}
