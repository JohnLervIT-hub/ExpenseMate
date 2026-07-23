import 'package:flutter/foundation.dart';

@immutable
class ShoppingList {
  final int id;
  final String name;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.isFavorite,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingList copyWith({int? id, String? name, bool? isFavorite, bool? isArchived, DateTime? createdAt, DateTime? updatedAt}) =>
      ShoppingList(
        id: id ?? this.id,
        name: name ?? this.name,
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'name': name,
        'is_favorite': isFavorite ? 1 : 0,
        'is_archived': isArchived ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ShoppingList.fromMap(Map<String, dynamic> m) => ShoppingList(
        id: m['id'] as int,
        name: (m['name'] as String?) ?? '',
        isFavorite: (m['is_favorite'] as int? ?? 0) == 1,
        isArchived: (m['is_archived'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  static ShoppingList create(String name, {bool favorite = false}) {
    final now = DateTime.now();
    return ShoppingList(
      id: 0,
      name: name,
      isFavorite: favorite,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) => other is ShoppingList && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
