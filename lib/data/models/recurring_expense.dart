import 'package:flutter/foundation.dart';

@immutable
class RecurringExpense {
  final int id;
  final double amount;
  final int categoryId;
  final String merchant;
  final String frequency;
  final DateTime nextDue;
  final bool isActive;

  const RecurringExpense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.merchant,
    required this.frequency,
    required this.nextDue,
    required this.isActive,
  });

  RecurringExpense copyWith({
    int? id,
    double? amount,
    int? categoryId,
    String? merchant,
    String? frequency,
    DateTime? nextDue,
    bool? isActive,
  }) =>
      RecurringExpense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        merchant: merchant ?? this.merchant,
        frequency: frequency ?? this.frequency,
        nextDue: nextDue ?? this.nextDue,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'amount': amount,
        'category_id': categoryId,
        'merchant': merchant,
        'frequency': frequency,
        'next_due': nextDue.toIso8601String(),
        'is_active': isActive ? 1 : 0,
      };

  factory RecurringExpense.fromMap(Map<String, dynamic> m) => RecurringExpense(
        id: m['id'] as int,
        amount: (m['amount'] as num).toDouble(),
        categoryId: m['category_id'] as int,
        merchant: (m['merchant'] as String?) ?? '',
        frequency: (m['frequency'] as String?) ?? 'Monthly',
        nextDue: DateTime.parse(m['next_due'] as String),
        isActive: (m['is_active'] as int? ?? 1) == 1,
      );
}
