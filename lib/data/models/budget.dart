import 'package:flutter/foundation.dart';

@immutable
class Budget {
  final int id;
  final int month;
  final int year;
  final double income;
  final double savingsGoal;
  final double spendingLimit;
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.income,
    required this.savingsGoal,
    required this.spendingLimit,
    required this.createdAt,
  });

  Budget copyWith({int? id, int? month, int? year, double? income, double? savingsGoal, double? spendingLimit, DateTime? createdAt}) =>
      Budget(
        id: id ?? this.id,
        month: month ?? this.month,
        year: year ?? this.year,
        income: income ?? this.income,
        savingsGoal: savingsGoal ?? this.savingsGoal,
        spendingLimit: spendingLimit ?? this.spendingLimit,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'month': month,
        'year': year,
        'income': income,
        'savings_goal': savingsGoal,
        'spending_limit': spendingLimit,
        'created_at': createdAt.toIso8601String(),
      };

  factory Budget.fromMap(Map<String, dynamic> m) => Budget(
        id: m['id'] as int,
        month: m['month'] as int,
        year: m['year'] as int,
        income: (m['income'] as num?)?.toDouble() ?? 0,
        savingsGoal: (m['savings_goal'] as num?)?.toDouble() ?? 0,
        spendingLimit: (m['spending_limit'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  static Budget empty(int year, int month) => Budget(
        id: 0,
        month: month,
        year: year,
        income: 0,
        savingsGoal: 0,
        spendingLimit: 0,
        createdAt: DateTime.now(),
      );

  @override
  bool operator ==(Object other) => other is Budget && other.id == id && other.year == year && other.month == month;
  @override
  int get hashCode => Object.hash(id, year, month);
}
