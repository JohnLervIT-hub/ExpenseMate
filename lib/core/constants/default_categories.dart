import 'package:flutter/material.dart';
import '../../data/models/category.dart';

class DefaultCategories {
  static List<Category> seed() {
    return const [
      Category(id: 0, name: 'Groceries', iconCode: 0xe59c, colorValue: 0xFF4CAF50, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Fuel', iconCode: 0xe546, colorValue: 0xFFFF9800, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Rent', iconCode: 0xe88a, colorValue: 0xFF795548, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Utilities', iconCode: 0xe63a, colorValue: 0xFF03A9F4, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Dining', iconCode: 0xe56c, colorValue: 0xFFE91E63, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Shopping', iconCode: 0xe8cc, colorValue: 0xFF9C27B0, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Entertainment', iconCode: 0xe02c, colorValue: 0xFF673AB7, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Healthcare', iconCode: 0xe548, colorValue: 0xFFF44336, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Transportation', iconCode: 0xe530, colorValue: 0xFF00BCD4, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Insurance', iconCode: 0xe32a, colorValue: 0xFF607D8B, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Education', iconCode: 0xe80c, colorValue: 0xFF3F51B5, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Travel', iconCode: 0xe071, colorValue: 0xFF009688, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Gifts', iconCode: 0xe8f6, colorValue: 0xFFEC407A, isDefault: true, budgetAmount: 0),
      Category(id: 0, name: 'Miscellaneous', iconCode: 0xe148, colorValue: 0xFF9E9E9E, isDefault: true, budgetAmount: 0),
    ];
  }

  static IconData iconFor(int codePoint) => IconData(codePoint, fontFamily: 'MaterialIcons');
}
