import 'package:flutter/foundation.dart';

@immutable
class Expense {
  final int id;
  final double amount;
  final int categoryId;
  final String merchant;
  final String paymentMethod;
  final String notes;
  final String? receiptPath;
  final bool isFavorite;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.merchant,
    required this.paymentMethod,
    required this.notes,
    required this.receiptPath,
    required this.isFavorite,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    int? id,
    double? amount,
    int? categoryId,
    String? merchant,
    String? paymentMethod,
    String? notes,
    String? receiptPath,
    bool? isFavorite,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Expense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        merchant: merchant ?? this.merchant,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        notes: notes ?? this.notes,
        receiptPath: receiptPath ?? this.receiptPath,
        isFavorite: isFavorite ?? this.isFavorite,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'amount': amount,
        'category_id': categoryId,
        'merchant': merchant,
        'payment_method': paymentMethod,
        'notes': notes,
        'receipt_path': receiptPath,
        'is_favorite': isFavorite ? 1 : 0,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as int,
        amount: (m['amount'] as num).toDouble(),
        categoryId: m['category_id'] as int,
        merchant: (m['merchant'] as String?) ?? '',
        paymentMethod: (m['payment_method'] as String?) ?? '',
        notes: (m['notes'] as String?) ?? '',
        receiptPath: m['receipt_path'] as String?,
        isFavorite: (m['is_favorite'] as int? ?? 0) == 1,
        date: DateTime.parse(m['date'] as String),
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  static Expense create({
    required double amount,
    required int categoryId,
    String merchant = '',
    String paymentMethod = 'Cash',
    String notes = '',
    String? receiptPath,
    bool isFavorite = false,
    DateTime? date,
  }) {
    final now = DateTime.now();
    return Expense(
      id: 0,
      amount: amount,
      categoryId: categoryId,
      merchant: merchant,
      paymentMethod: paymentMethod,
      notes: notes,
      receiptPath: receiptPath,
      isFavorite: isFavorite,
      date: date ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) => other is Expense && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
