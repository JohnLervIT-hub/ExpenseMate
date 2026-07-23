import 'package:flutter/foundation.dart';

@immutable
class Income {
  final int id;
  final double amount;
  final String source;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  const Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.notes,
    required this.createdAt,
  });

  Income copyWith({int? id, double? amount, String? source, DateTime? date, String? notes, DateTime? createdAt}) =>
      Income(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        source: source ?? this.source,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'amount': amount,
        'source': source,
        'date': date.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory Income.fromMap(Map<String, dynamic> m) => Income(
        id: m['id'] as int,
        amount: (m['amount'] as num).toDouble(),
        source: (m['source'] as String?) ?? '',
        date: DateTime.parse(m['date'] as String),
        notes: (m['notes'] as String?) ?? '',
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  static Income create({required double amount, String source = 'Salary', String notes = '', DateTime? date}) {
    final now = DateTime.now();
    return Income(id: 0, amount: amount, source: source, date: date ?? now, notes: notes, createdAt: now);
  }

  @override
  bool operator ==(Object other) => other is Income && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
