import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/shopping_item.dart';
import '../../data/models/shopping_list.dart';
import 'repository_providers.dart';

final shoppingListsProvider = FutureProvider<List<ShoppingList>>((ref) async {
  return ref.watch(shoppingRepositoryProvider).getAllLists();
});

final shoppingItemsProvider = FutureProvider.family<List<ShoppingItem>, int>((ref, listId) async {
  return ref.watch(shoppingRepositoryProvider).getItems(listId);
});

final shoppingListDetailProvider = FutureProvider.family<ShoppingList?, int>((ref, listId) async {
  return ref.watch(shoppingRepositoryProvider).getListById(listId);
});
