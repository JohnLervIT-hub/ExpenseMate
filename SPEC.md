# ExpenseMate Shared Spec

Project root: `/Users/user/expensemate`
Flutter app name: `expensemate`
Package: `com.expensemate.app`
State mgmt: Riverpod (`flutter_riverpod` ^2.5.1)
DB: `sqflite` ^2.3.3 + `path_provider` ^2.1.4
Charts: `fl_chart` ^0.68.0
Routing: `go_router` ^14.2.7

## Currency default: USD ("$"), configurable via settings.

## Database schema (SQLite v1)

Tables (all with `id INTEGER PRIMARY KEY AUTOINCREMENT`):

- `categories(id, name, icon_code, color_value, is_default, budget_amount REAL DEFAULT 0)`
- `expenses(id, amount REAL, category_id INTEGER, merchant TEXT, payment_method TEXT, notes TEXT, receipt_path TEXT, is_favorite INTEGER DEFAULT 0, date TEXT ISO8601, created_at TEXT, updated_at TEXT)`
- `income(id, amount REAL, source TEXT, date TEXT, notes TEXT, created_at TEXT)`
- `budgets(id, month INTEGER, year INTEGER, income REAL, savings_goal REAL, spending_limit REAL, created_at TEXT)`
- `shopping_lists(id, name TEXT, is_favorite INTEGER, is_archived INTEGER, created_at TEXT, updated_at TEXT)`
- `shopping_items(id, list_id INTEGER, name TEXT, quantity REAL, unit TEXT, estimated_price REAL, actual_price REAL, store TEXT, is_purchased INTEGER, notes TEXT, sort_order INTEGER)`
- `recurring_expenses(id, amount REAL, category_id INTEGER, merchant TEXT, frequency TEXT, next_due TEXT, is_active INTEGER)`
- `settings(key TEXT PRIMARY KEY, value TEXT)`

Payment methods (enum-like strings): Cash, Debit Card, Credit Card, Bank Transfer, Digital Wallet, Other

Default categories seeded on first launch:
Groceries, Fuel, Rent, Utilities, Dining, Shopping, Entertainment, Healthcare, Transportation, Insurance, Education, Travel, Gifts, Miscellaneous.

## Repository contract

All repositories exposed via Riverpod providers. Repository interfaces (in `lib/data/repositories/`):

```dart
// ExpenseRepository
Future<List<Expense>> getAll({DateTime? start, DateTime? end, int? categoryId, String? query});
Future<Expense?> getById(int id);
Future<int> insert(Expense e);
Future<void> update(Expense e);
Future<void> delete(int id);
Future<double> totalForMonth(int year, int month);
Future<Map<int, double>> totalsByCategoryForMonth(int year, int month);
Future<List<Expense>> recent({int limit = 5});
Future<List<Expense>> favorites();

// CategoryRepository
Future<List<Category>> getAll();
Future<int> insert(Category c); Future<void> update(Category c); Future<void> delete(int id);

// IncomeRepository
Future<List<Income>> getAll({int? year, int? month});
Future<double> totalForMonth(int year, int month);
Future<int> insert(Income i); Future<void> update(Income i); Future<void> delete(int id);

// BudgetRepository
Future<Budget?> forMonth(int year, int month);
Future<void> upsert(Budget b);

// ShoppingRepository
Future<List<ShoppingList>> getAllLists({bool includeArchived = false});
Future<ShoppingList?> getListById(int id);
Future<int> insertList(ShoppingList l); Future<void> updateList(ShoppingList l);
Future<void> deleteList(int id); Future<int> duplicateList(int id);
Future<List<ShoppingItem>> getItems(int listId);
Future<int> insertItem(ShoppingItem it); Future<void> updateItem(ShoppingItem it);
Future<void> deleteItem(int id);
Future<double> totalActualForList(int listId);
Future<double> totalEstimatedForList(int listId);

// SettingsRepository
Future<String?> get(String key); Future<void> set(String key, String value);
```

## Riverpod providers (in `lib/presentation/providers/`)

- `databaseProvider` (Future<Database>)
- `expenseRepositoryProvider`, `categoryRepositoryProvider`, `incomeRepositoryProvider`,
  `budgetRepositoryProvider`, `shoppingRepositoryProvider`, `settingsRepositoryProvider`
- `themeModeProvider` (StateNotifier<ThemeMode>)
- `currencyProvider` (StateNotifier<String>) — symbol
- `dashboardSummaryProvider` (FutureProvider) returns:
  ```dart
  class DashboardSummary {
    final double monthlyIncome;
    final double monthlyExpenses;
    final double remainingBudget;
    final double savings;
    final double groceries;
    final double budgetLimit;
    final List<Expense> recent;
    final Map<int, double> byCategory;
    final List<double> last6MonthsExpenses;
  }
  ```
- `expensesProvider` (FutureProvider.family for filters)
- `shoppingListsProvider`, `shoppingItemsProvider(listId)`
- `pinLockProvider` (StateNotifier<bool> unlocked)

## Routes (go_router)
- `/lock` (PIN/biometric)
- `/` shell with bottom nav → `dashboard`, `expenses`, `grocery`, `budget`, `more`
- `/expenses/new`, `/expenses/edit/:id`
- `/grocery/list/:id`, `/grocery/new`
- `/reports`, `/settings`, `/search`, `/backup`, `/onboarding`

## Theme
Material 3 with seed color `Color(0xFF6750A4)` (indigo-violet).
Custom `AppColors`, `AppTextStyles`. Card radius 20, chips 12, buttons 14.
Support ThemeMode.system/light/dark. Store in settings under key `theme_mode`.

## Formatting
- Currency helper: `String formatCurrency(double v, {String symbol = '\$'})` — 2 decimals, thousand separators.
- Date helpers: `formatDate`, `formatMonthYear`, `daysInMonth`.

## Assets in pubspec.yaml
`assets/images/`, `assets/icons/` (may be empty dirs — do not error on missing files, use Icon widgets for illustrations).

## Coding rules
- Null-safe.
- No `print`; use debugPrint sparingly.
- Prefer const constructors.
- No TODO markers — implement each stub with real logic.
- Screens should compile with the providers/models above.
- Do NOT invent new tables or fields — stick to spec so both agents agree.
- Use ConsumerWidget / ConsumerStatefulWidget for screens.

## Deliverables you own vs the other agent

FOUNDATION AGENT owns:
- `pubspec.yaml`
- `lib/main.dart`, `lib/app.dart`
- `lib/core/**` (theme, constants, utils, services: notification, backup, pdf export, csv export, biometric, pin)
- `lib/data/**` (database helper, models, repositories)
- `lib/presentation/providers/**` (all providers)
- `README.md`, `.gitignore`, `analysis_options.yaml`
- `android/app/src/main/AndroidManifest.xml` snippet in README (permissions list)

UI AGENT owns:
- `lib/presentation/screens/**` (all screens listed above)
- `lib/presentation/widgets/**` (charts, cards, common)
- `lib/core/router/app_router.dart`

Both agents must follow this SPEC.md exactly. If a name is ambiguous, prefer what's written here.

## Exact file paths (both agents must use these — no renames)

Models (each in its own file):
- `lib/data/models/expense.dart` → class `Expense` (id, amount, categoryId, merchant, paymentMethod, notes, receiptPath, isFavorite, date DateTime, createdAt, updatedAt) with `fromMap`, `toMap`, `copyWith`.
- `lib/data/models/category.dart` → class `Category` (id, name, iconCode int, colorValue int, isDefault, budgetAmount).
- `lib/data/models/income.dart` → class `Income` (id, amount, source, date, notes, createdAt).
- `lib/data/models/budget.dart` → class `Budget` (id, month, year, income, savingsGoal, spendingLimit, createdAt).
- `lib/data/models/shopping_list.dart` → class `ShoppingList` (id, name, isFavorite, isArchived, createdAt, updatedAt).
- `lib/data/models/shopping_item.dart` → class `ShoppingItem` (id, listId, name, quantity, unit, estimatedPrice, actualPrice, store, isPurchased, notes, sortOrder).
- `lib/data/models/recurring_expense.dart` → class `RecurringExpense`.

Database:
- `lib/data/database/app_database.dart` → class `AppDatabase` with `Future<Database> get database`, `Future<void> close()`, plus static `Future<AppDatabase> initialize()`.

Repositories:
- `lib/data/repositories/expense_repository.dart` → class `ExpenseRepository`
- `lib/data/repositories/category_repository.dart` → class `CategoryRepository`
- `lib/data/repositories/income_repository.dart` → class `IncomeRepository`
- `lib/data/repositories/budget_repository.dart` → class `BudgetRepository`
- `lib/data/repositories/shopping_repository.dart` → class `ShoppingRepository`
- `lib/data/repositories/settings_repository.dart` → class `SettingsRepository`

Services:
- `lib/core/services/notification_service.dart` → class `NotificationService` (schedule, cancel, init). Use `flutter_local_notifications` ^17.2.2.
- `lib/core/services/backup_service.dart` → class `BackupService` (export DB file to app documents dir, restore from file). Uses `file_picker` ^8.1.2 and `share_plus` ^10.0.2.
- `lib/core/services/export_service.dart` → class `ExportService` with `exportExpensesCsv`, `exportExpensesPdf`, `exportReportPdf`. Use `pdf` ^3.11.1, `printing` ^5.13.1, and `csv` ^6.0.0.
- `lib/core/services/auth_service.dart` → class `AuthService` with PIN + biometric. Use `local_auth` ^2.3.0 and `flutter_secure_storage` ^9.2.2.
- `lib/core/services/image_service.dart` → class `ImageService` with `pickReceipt()` using `image_picker` ^1.1.2, saves to app dir returns path.

Providers (`lib/presentation/providers/`):
- `providers.dart` — barrel exporting all
- `database_provider.dart`
- `repository_providers.dart` — all six repo providers
- `theme_provider.dart` — themeModeProvider (StateNotifierProvider<ThemeModeNotifier, ThemeMode>)
- `currency_provider.dart` — currencySymbolProvider (StateNotifierProvider<CurrencyNotifier, String>)
- `dashboard_provider.dart` — dashboardSummaryProvider (FutureProvider<DashboardSummary>) + DashboardSummary class here
- `expenses_provider.dart` — expensesProvider (FutureProvider.family with `ExpenseFilter` class in same file: {DateTime? start, DateTime? end, int? categoryId, String? query})
- `shopping_provider.dart` — shoppingListsProvider + shoppingItemsProvider(int listId)
- `auth_provider.dart` — pinLockProvider (StateNotifierProvider<AuthNotifier, AuthState>) where AuthState has `isUnlocked`, `hasPin`, `biometricEnabled`

Screens (UI agent):
- `lib/presentation/screens/dashboard/dashboard_screen.dart` → `DashboardScreen`
- `lib/presentation/screens/expenses/expenses_screen.dart` → `ExpensesScreen`
- `lib/presentation/screens/expenses/expense_form_screen.dart` → `ExpenseFormScreen({int? expenseId})`
- `lib/presentation/screens/grocery/grocery_screen.dart` → `GroceryScreen`
- `lib/presentation/screens/grocery/shopping_list_detail_screen.dart` → `ShoppingListDetailScreen({required int listId})`
- `lib/presentation/screens/grocery/shopping_list_form_screen.dart` → `ShoppingListFormScreen`
- `lib/presentation/screens/budget/budget_screen.dart` → `BudgetScreen`
- `lib/presentation/screens/reports/reports_screen.dart` → `ReportsScreen`
- `lib/presentation/screens/settings/settings_screen.dart` → `SettingsScreen`
- `lib/presentation/screens/settings/backup_screen.dart` → `BackupScreen`
- `lib/presentation/screens/auth/lock_screen.dart` → `LockScreen`
- `lib/presentation/screens/auth/pin_setup_screen.dart` → `PinSetupScreen`
- `lib/presentation/screens/search/search_screen.dart` → `SearchScreen`
- `lib/presentation/screens/onboarding/onboarding_screen.dart` → `OnboardingScreen`
- `lib/presentation/screens/main_shell.dart` → `MainShell({required Widget child})` — bottom nav host (Dashboard, Expenses, Grocery, Budget, More)

Widgets:
- `lib/presentation/widgets/charts/category_pie_chart.dart` → `CategoryPieChart({required Map<int,double> totals, required List<Category> categories})`
- `lib/presentation/widgets/charts/monthly_bar_chart.dart` → `MonthlyBarChart({required List<double> values, required List<String> labels})`
- `lib/presentation/widgets/charts/monthly_trend_chart.dart` → `MonthlyTrendChart({required List<double> values})`
- `lib/presentation/widgets/cards/summary_card.dart` → `SummaryCard({required String title, required String value, required IconData icon, Color? color, String? trend})`
- `lib/presentation/widgets/cards/expense_tile.dart` → `ExpenseTile({required Expense expense, Category? category, VoidCallback? onTap, VoidCallback? onDelete, VoidCallback? onFavorite})`
- `lib/presentation/widgets/common/empty_state.dart` → `EmptyState({required IconData icon, required String title, String? subtitle, Widget? action})`
- `lib/presentation/widgets/common/loading_indicator.dart` → `AppLoadingIndicator`
- `lib/presentation/widgets/common/section_header.dart` → `SectionHeader({required String title, Widget? trailing})`

Router:
- `lib/core/router/app_router.dart` → exposes `appRouterProvider` (Riverpod provider returning `GoRouter`). Uses ShellRoute for bottom nav.

Theme:
- `lib/core/theme/app_theme.dart` → `AppTheme.light()`, `AppTheme.dark()` returning `ThemeData`.
- `lib/core/theme/app_colors.dart` → constants.

Utils:
- `lib/core/utils/formatters.dart` → `formatCurrency`, `formatDate`, `formatMonthYear`.
- `lib/core/utils/date_utils.dart` → `firstDayOfMonth`, `lastDayOfMonth`, `monthLabels`.
- `lib/core/constants/app_constants.dart` → routes, payment methods list, settings keys.
- `lib/core/constants/default_categories.dart` → list of default `Category` seed data (name, icon, color).

Do NOT import packages beyond those declared in the pubspec (foundation agent's responsibility). UI agent: assume ALL packages listed in pubspec below are available.

## Pubspec dependencies (foundation must include all)

```yaml
dependencies:
  flutter: {sdk: flutter}
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  sqflite: ^2.3.3
  path_provider: ^2.1.4
  path: ^1.9.0
  fl_chart: ^0.68.0
  intl: ^0.19.0
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4
  local_auth: ^2.3.0
  flutter_secure_storage: ^9.2.2
  image_picker: ^1.1.2
  file_picker: ^8.1.2
  share_plus: ^10.0.2
  pdf: ^3.11.1
  printing: ^5.13.1
  csv: ^6.0.0
  excel: ^4.0.6
  google_fonts: ^6.2.1
  cupertino_icons: ^1.0.8
```

Flutter SDK constraint: `sdk: ">=3.4.0 <4.0.0"`.

