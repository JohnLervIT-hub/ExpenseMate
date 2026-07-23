import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/export_service.dart';
import '../../core/services/image_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/category.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/repositories/recurring_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/shopping_repository.dart';
import 'database_provider.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) => ExpenseRepository(ref.watch(appDatabaseProvider)));

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepository(ref.watch(appDatabaseProvider)));

final incomeRepositoryProvider =
    Provider<IncomeRepository>((ref) => IncomeRepository(ref.watch(appDatabaseProvider)));

final budgetRepositoryProvider =
    Provider<BudgetRepository>((ref) => BudgetRepository(ref.watch(appDatabaseProvider)));

final shoppingRepositoryProvider =
    Provider<ShoppingRepository>((ref) => ShoppingRepository(ref.watch(appDatabaseProvider)));

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository(ref.watch(appDatabaseProvider)));

final recurringRepositoryProvider =
    Provider<RecurringRepository>((ref) => RecurringRepository(ref.watch(appDatabaseProvider)));

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final backupServiceProvider = Provider<BackupService>((ref) => const BackupService());
final exportServiceProvider = Provider<ExportService>((ref) => const ExportService());
final imageServiceProvider = Provider<ImageService>((ref) => ImageService());
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);

// Category list watchable
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(categoryRepositoryProvider).getAll();
});
