import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../data/models/shopping_list.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shopping_provider.dart';

class ShoppingListFormScreen extends ConsumerStatefulWidget {
  const ShoppingListFormScreen({super.key});

  @override
  ConsumerState<ShoppingListFormScreen> createState() => _ShoppingListFormScreenState();
}

class _ShoppingListFormScreenState extends ConsumerState<ShoppingListFormScreen> {
  final _nameCtrl = TextEditingController(text: 'Weekly Groceries');
  bool _favorite = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final list = ShoppingList.create(_nameCtrl.text.trim(), favorite: _favorite);
    final id = await ref.read(shoppingRepositoryProvider).insertList(list);
    ref.invalidate(shoppingListsProvider);
    if (!mounted) return;
    context.pop();
    context.push('/grocery/list/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.groceryNewShoppingList),
        actions: [IconButton(icon: const Icon(Icons.check_rounded), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'List name',
                prefixIcon: Icon(Icons.list_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _favorite,
              onChanged: (v) => setState(() => _favorite = v),
              title: Text(context.l10n.groceryMarkFavorite),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.groceryCreateList),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
