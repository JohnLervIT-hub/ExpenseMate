import 'package:flutter/foundation.dart';

@immutable
class ShoppingItem {
  final int id;
  final int listId;
  final String name;
  final double quantity;
  final String unit;
  final double estimatedPrice;
  final double actualPrice;
  final String store;
  final bool isPurchased;
  final String notes;
  final int sortOrder;

  const ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    required this.actualPrice,
    required this.store,
    required this.isPurchased,
    required this.notes,
    required this.sortOrder,
  });

  ShoppingItem copyWith({
    int? id,
    int? listId,
    String? name,
    double? quantity,
    String? unit,
    double? estimatedPrice,
    double? actualPrice,
    String? store,
    bool? isPurchased,
    String? notes,
    int? sortOrder,
  }) =>
      ShoppingItem(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        estimatedPrice: estimatedPrice ?? this.estimatedPrice,
        actualPrice: actualPrice ?? this.actualPrice,
        store: store ?? this.store,
        isPurchased: isPurchased ?? this.isPurchased,
        notes: notes ?? this.notes,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'list_id': listId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'estimated_price': estimatedPrice,
        'actual_price': actualPrice,
        'store': store,
        'is_purchased': isPurchased ? 1 : 0,
        'notes': notes,
        'sort_order': sortOrder,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        id: m['id'] as int,
        listId: m['list_id'] as int,
        name: (m['name'] as String?) ?? '',
        quantity: (m['quantity'] as num?)?.toDouble() ?? 1,
        unit: (m['unit'] as String?) ?? '',
        estimatedPrice: (m['estimated_price'] as num?)?.toDouble() ?? 0,
        actualPrice: (m['actual_price'] as num?)?.toDouble() ?? 0,
        store: (m['store'] as String?) ?? '',
        isPurchased: (m['is_purchased'] as int? ?? 0) == 1,
        notes: (m['notes'] as String?) ?? '',
        sortOrder: (m['sort_order'] as int?) ?? 0,
      );

  @override
  bool operator ==(Object other) => other is ShoppingItem && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
