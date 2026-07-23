import 'package:flutter/foundation.dart';

@immutable
class Category {
  final int id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isDefault;
  final double budgetAmount;

  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.isDefault,
    required this.budgetAmount,
  });

  Category copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isDefault,
    double? budgetAmount,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
        colorValue: colorValue ?? this.colorValue,
        isDefault: isDefault ?? this.isDefault,
        budgetAmount: budgetAmount ?? this.budgetAmount,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'name': name,
        'icon_code': iconCode,
        'color_value': colorValue,
        'is_default': isDefault ? 1 : 0,
        'budget_amount': budgetAmount,
      };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as int,
        name: m['name'] as String,
        iconCode: m['icon_code'] as int,
        colorValue: m['color_value'] as int,
        isDefault: (m['is_default'] as int) == 1,
        budgetAmount: (m['budget_amount'] as num?)?.toDouble() ?? 0,
      );

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
