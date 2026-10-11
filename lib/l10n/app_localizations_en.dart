// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ExpenseMate';

  @override
  String get navHome => 'Home';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navGrocery => 'Grocery';

  @override
  String get navBudget => 'Budget';

  @override
  String get navMore => 'More';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionGetStarted => 'Get Started';

  @override
  String get actionAllow => 'Allow';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionUndo => 'UNDO';

  @override
  String get actionReset => 'Reset';

  @override
  String get commonToday => 'Today';

  @override
  String get commonThisMonth => 'This month';

  @override
  String get commonThisWeek => 'This week';

  @override
  String get commonNextBill => 'Next bill';

  @override
  String get commonUpcomingBills => 'Upcoming bills';

  @override
  String get commonTransactions => 'Transactions';

  @override
  String get commonRecentTransactions => 'Recent Transactions';

  @override
  String get commonViewAll => 'View all';

  @override
  String get commonOverspending =>
      'Overspending — reduce discretionary categories.';

  @override
  String get commonPurchased => 'Purchased';

  @override
  String get commonEstimated => 'Estimated';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonActual => 'Actual';

  @override
  String get commonEst => 'Est.';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonMerchant => 'Merchant';

  @override
  String get commonDate => 'Date';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonDetails => 'Details';

  @override
  String get commonReceipt => 'Receipt';

  @override
  String get commonFavorite => 'Favorite';

  @override
  String get commonActive => 'Active';

  @override
  String get commonPaymentMethod => 'Payment method';

  @override
  String get commonMonth => 'Month';

  @override
  String get commonWeek => 'Week';

  @override
  String get commonTwoWeeks => '2 wks';

  @override
  String get commonYear => 'Year';

  @override
  String get dashboardTitle => 'ExpenseMate';

  @override
  String get dashboardOverview => 'Overview';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get onboardNameTitle => 'What should we call you?';

  @override
  String get onboardNameSubtitle =>
      'So we can greet you when you open the app.';

  @override
  String get onboardNameHint => 'Your name';

  @override
  String get dashboardMonthlyIncome => 'Monthly Income';

  @override
  String get dashboardMonthlyExpenses => 'Monthly Expenses';

  @override
  String get dashboardRemainingBudget => 'Remaining Budget';

  @override
  String get dashboardSavings => 'Savings';

  @override
  String get dashboardBudgetUtilization => 'Budget Utilization';

  @override
  String get dashboardSpendingByCategory => 'Spending by Category';

  @override
  String get dashboardMonthlyTrend => 'Monthly Trend';

  @override
  String get dashboardQuickAdd => 'Quick Add';

  @override
  String get dashboardScanReceipt => 'Scan a receipt';

  @override
  String get dashboardScanReceiptSubtitle =>
      'Auto-fills amount, merchant and date';

  @override
  String get dashboardEnterManually => 'Enter manually';

  @override
  String get dashboardEnterManuallySubtitle => 'Fill the expense form yourself';

  @override
  String get dashboardEmptyTitle => 'No transactions yet';

  @override
  String get dashboardEmptySubtitle =>
      'Tap Quick Add to log your first expense.';

  @override
  String get dashboardLiveDemo => 'Live Demo — sample data';

  @override
  String get dashboardLiveDemoSubtitle =>
      'Every transaction here is seeded. Buy the full source to make it yours.';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesAdd => 'Add Expense';

  @override
  String get expensesEdit => 'Edit Expense';

  @override
  String get expensesEmptyTitle => 'No expenses found';

  @override
  String get expensesEmptySubtitle =>
      'Try changing filters or tap + to add one.';

  @override
  String get expensesFilter => 'Filter';

  @override
  String get expensesDeleted => 'Expense deleted';

  @override
  String get expensesDeleteConfirmTitle => 'Delete expense?';

  @override
  String get expensesDeleteConfirmBody => 'This will remove the expense.';

  @override
  String get expensesDuplicate => 'Duplicate';

  @override
  String get expensesUnfavorite => 'Unfavorite';

  @override
  String get expensesEnterAmount => 'Enter an amount';

  @override
  String get expensesPickCategory => 'Please pick a category';

  @override
  String get expensesSaveExpense => 'Save Expense';

  @override
  String get expensesUpdateExpense => 'Update Expense';

  @override
  String get expensesNoReceipt => 'No receipt attached';

  @override
  String get expensesAttached => 'Attached';

  @override
  String get expensesAttach => 'Attach';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetMonthlyPlan => 'Monthly plan';

  @override
  String get budgetMonthlyIncomePlan => 'Monthly income (plan)';

  @override
  String get budgetSpendingLimit => 'Spending limit';

  @override
  String get budgetSavingsGoal => 'Savings goal';

  @override
  String get budgetCategoryBudgets => 'Category Budgets';

  @override
  String get budgetLogIncome => 'Log Income';

  @override
  String get budgetSavePlan => 'Save Plan';

  @override
  String get budgetSavingsProgress => 'Savings progress';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetActualIncome => 'Actual income';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetSource => 'Source';

  @override
  String get budgetSalary => 'Salary';

  @override
  String get budgetSetGoal => 'Set a savings goal to track progress';

  @override
  String get groceryTitle => 'Grocery';

  @override
  String get groceryYourLists => 'Your lists';

  @override
  String get groceryEmptyTitle => 'No shopping lists';

  @override
  String get groceryEmptySubtitle =>
      'Create your first list to start tracking groceries.';

  @override
  String get groceryNewList => 'New List';

  @override
  String get groceryNewShoppingList => 'New Shopping List';

  @override
  String get groceryListName => 'List name';

  @override
  String get groceryEnterName => 'Enter a name';

  @override
  String get groceryMarkFavorite => 'Mark as favorite';

  @override
  String get groceryCreateList => 'Create List';

  @override
  String get groceryUpdated => 'Updated';

  @override
  String get groceryDuplicate => 'Duplicate';

  @override
  String get groceryArchive => 'Archive';

  @override
  String get groceryEmptyItemsTitle => 'No items yet';

  @override
  String get groceryEmptyItemsSubtitle => 'Tap + to add your first item.';

  @override
  String get groceryAddItem => 'Add Item';

  @override
  String get groceryEditItem => 'Edit Item';

  @override
  String get groceryItemName => 'Item name';

  @override
  String get groceryQty => 'Qty';

  @override
  String get groceryUnit => 'Unit';

  @override
  String get groceryStore => 'Store';

  @override
  String get groceryDuplicateList => 'Duplicate list';

  @override
  String get groceryDeleteList => 'Delete list';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsMonthly => 'Monthly';

  @override
  String get reportsYearly => 'Yearly';

  @override
  String get reportsCategory => 'Category';

  @override
  String get reportsIncomeVsExpense => 'Income vs Expense';

  @override
  String get reportsSavings => 'Savings';

  @override
  String get reportsCsv => 'CSV';

  @override
  String get reportsExcel => 'Excel';

  @override
  String get reportsPdf => 'PDF';

  @override
  String get reportsLastSixMonths => 'Last 6 months';

  @override
  String get reportsExpensesByMonth => 'Expenses by month';

  @override
  String get reportsIncomeByMonth => 'Income by month';

  @override
  String get reportsIncomeMo => 'Income (mo)';

  @override
  String get reportsExpensesMo => 'Expenses (mo)';

  @override
  String get reportsSavingsPerMonth => 'Savings per month';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarNothingOnDay => 'Nothing on this day';

  @override
  String get calendarNothingOnDaySubtitle =>
      'Tap a day with a dot to see transactions.';

  @override
  String calendarTransactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get recurringTitle => 'Recurring Expenses';

  @override
  String get recurringNewRule => 'New Rule';

  @override
  String get recurringNewRuleTitle => 'New Recurring Rule';

  @override
  String get recurringEditRule => 'Edit Rule';

  @override
  String get recurringEmptyTitle => 'No recurring rules yet';

  @override
  String get recurringEmptySubtitle =>
      'Add subscriptions like Netflix, rent, or insurance. They\'ll auto-log on their due date.';

  @override
  String get recurringNext => 'Next';

  @override
  String get recurringFrequency => 'Frequency';

  @override
  String get recurringNextDue => 'Next due';

  @override
  String get recurringEnterMerchant => 'Enter a merchant';

  @override
  String get recurringCreateRule => 'Create Rule';

  @override
  String get recurringSaveRule => 'Save Rule';

  @override
  String get recurringDeleteRule => 'Delete rule?';

  @override
  String recurringDeleteBody(String merchant) {
    return 'This won\'t remove past expenses. $merchant will just stop auto-logging.';
  }

  @override
  String get recurringDaily => 'Daily';

  @override
  String get recurringWeekly => 'Weekly';

  @override
  String get recurringMonthly => 'Monthly';

  @override
  String get recurringYearly => 'Yearly';

  @override
  String get scanTitle => 'Scan Receipt';

  @override
  String get scanPoint => 'Point the camera at the receipt';

  @override
  String get scanAutoFill =>
      'We\'ll read the total, merchant, and date automatically.';

  @override
  String get scanOpenCamera => 'Open Camera';

  @override
  String get scanPickGallery => 'Pick from Gallery';

  @override
  String get scanReading => 'Reading receipt…';

  @override
  String get scanCantRead =>
      'Could not read the receipt clearly. Try again or fill in the details manually.';

  @override
  String get scanWhatFound => 'What we found';

  @override
  String get scanContinueForm => 'Continue to expense form';

  @override
  String get scanRetake => 'Retake';

  @override
  String get scanRead => 'Read';

  @override
  String scanItemsDetected(int count) {
    return '$count items detected';
  }

  @override
  String get scanFullListNote =>
      'Full list will be saved to the expense notes.';

  @override
  String get scanReceiptItems => 'Receipt items:';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDateFormat => 'Date format';

  @override
  String get settingsFirstDayOfWeek => 'First day of week';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsSetPin => 'Set PIN';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsPinEnabled => 'PIN lock enabled';

  @override
  String get settingsPinDisabled => 'App is unlocked';

  @override
  String get settingsRemovePin => 'Remove PIN';

  @override
  String get settingsRemovePinBody => 'The app will no longer be locked.';

  @override
  String get settingsBiometric => 'Biometric unlock';

  @override
  String get settingsBiometricAvailable => 'Face ID / Fingerprint';

  @override
  String get settingsBiometricUnavailable => 'Not available on this device';

  @override
  String get settingsBiometricNeedsPin =>
      'Set a PIN first to enable biometric unlock';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackup => 'Backup & Restore';

  @override
  String get settingsReports => 'Reports & Export';

  @override
  String get settingsResetDemo => 'Reset demo data';

  @override
  String get settingsResetDemoSubtitle =>
      'Wipe entries and reload the built-in demo dataset';

  @override
  String get settingsResetConfirmTitle => 'Reset demo data?';

  @override
  String get settingsResetConfirmBody =>
      'This wipes all expenses, income, budgets, and shopping lists, then reloads the built-in demo dataset. Your PIN, currency and theme are kept.';

  @override
  String get settingsResetSuccess => 'Demo data reloaded';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version · Offline-first · No cloud';
  }

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDailyReminder => 'Daily log reminder';

  @override
  String settingsDailyReminderSubtitle(String time) {
    return 'Nudge at $time';
  }

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsWeeklyReview => 'Weekly review';

  @override
  String get settingsWeeklyReviewSubtitle => 'Sunday 6 PM · spending recap';

  @override
  String get settingsBudgetAlerts => 'Budget threshold alerts';

  @override
  String get settingsBudgetAlertsSubtitle =>
      'Alert at 80% and 100% of category budgets';

  @override
  String get settingsBillReminders => 'Bill reminders';

  @override
  String get settingsBillRemindersSubtitle => '1 day before recurring expenses';

  @override
  String get settingsChooseCurrency => 'Choose currency';

  @override
  String settingsCurrenciesAvailable(int count) {
    return '$count available';
  }

  @override
  String get settingsChooseLanguage => 'Choose language';

  @override
  String get onboardTrackTitle => 'Every dollar, tracked';

  @override
  String get onboardTrackSubtitle =>
      'Log expenses in seconds. Categorize, favorite, and attach receipts — all fully offline.';

  @override
  String get onboardGroceryTitle => 'Grocery lists that work';

  @override
  String get onboardGrocerySubtitle =>
      'Plan trips with estimated prices, tick items off in-store, and see the real total.';

  @override
  String get onboardSecurityTitle => 'Locked behind Face ID';

  @override
  String get onboardSecuritySubtitle =>
      'Optional 4-digit PIN and biometric unlock. Your finances stay for your eyes only.';

  @override
  String get onboardOwnDataTitle => 'Your data, your device';

  @override
  String get onboardOwnDataSubtitle =>
      'No accounts. No cloud. Backup and export whenever you want — you\'re in control.';

  @override
  String get onboardFreeTitle => 'Free forever, always';

  @override
  String get onboardFreeSubtitle =>
      'No subscription. No ads. No account. Just a premium finance tracker that works.';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryDining => 'Dining';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealthcare => 'Healthcare';

  @override
  String get categoryTransportation => 'Transportation';

  @override
  String get categoryInsurance => 'Insurance';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryMiscellaneous => 'Miscellaneous';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentDebitCard => 'Debit Card';

  @override
  String get paymentCreditCard => 'Credit Card';

  @override
  String get paymentBankTransfer => 'Bank Transfer';

  @override
  String get paymentDigitalWallet => 'Digital Wallet';

  @override
  String get paymentOther => 'Other';

  @override
  String get lockEnterPin => 'Enter PIN';

  @override
  String get lockUnlock => 'Unlock ExpenseMate';

  @override
  String get pinSetupTitle => 'Set PIN';

  @override
  String get pinCreateSubtitle => 'Create a 4-digit PIN to protect your data.';

  @override
  String get pinNew => 'New PIN';

  @override
  String get pinConfirm => 'Confirm PIN';

  @override
  String get pinSavePin => 'Save PIN';

  @override
  String get pinMustBe4 => 'PIN must be exactly 4 digits';

  @override
  String get pinNoMatch => 'PINs do not match';

  @override
  String get pinSet => 'PIN set';

  @override
  String get commonAll => 'All';

  @override
  String get commonAny => 'Any';

  @override
  String get commonError => 'Error';

  @override
  String get commonNoData => 'No data yet';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionAttach => 'Attach';

  @override
  String get expensesFavorites => 'Favorites';

  @override
  String get expensesScanTooltip => 'Scan receipt';

  @override
  String get expensesFilterDateRange => 'Date range';

  @override
  String get moreLockNow => 'Lock now';

  @override
  String get groceryDetailFallbackTitle => 'List';

  @override
  String get backupExportDatabase => 'Export Database';

  @override
  String get backupExportDatabaseBody =>
      'Save a copy of your SQLite database locally and share it.';

  @override
  String get backupExportShare => 'Export & Share';

  @override
  String get backupRestoreDatabase => 'Restore Database';

  @override
  String get backupRestoreDatabaseBody =>
      'Replace current data with a previous backup file.';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupExportCsvTitle => 'Export Expenses as CSV';

  @override
  String get backupExportCsvBody => 'For spreadsheets or manual analysis.';

  @override
  String get backupExportExcelTitle => 'Export Expenses as Excel';

  @override
  String get backupExportExcelBody => 'XLSX file with all your expenses.';

  @override
  String get backupExportPdfTitle => 'Export Expenses as PDF';

  @override
  String get backupExportPdfBody => 'Formatted PDF report of your expenses.';

  @override
  String get backupExportCsvAction => 'Export CSV';

  @override
  String get backupExportExcelAction => 'Export Excel';

  @override
  String get backupExportPdfAction => 'Export PDF';

  @override
  String backupPdfPreparedFor(String name) {
    return 'Prepared for $name';
  }

  @override
  String get backupRestoreSuccessTitle => 'Restore complete';

  @override
  String get backupRestoreSuccessBody =>
      'ExpenseMate needs to close so your restored data loads correctly. Reopen it from your home screen.';

  @override
  String get backupRestoreCloseApp => 'Close app';

  @override
  String get backupRestoreInvalidFile =>
      'That file isn\'t a valid ExpenseMate backup.';

  @override
  String get backupRestoreCancelled => 'Restore cancelled.';

  @override
  String get backupRestoreError =>
      'Restore failed. Your existing data is safe.';

  @override
  String get backupRestoreConfirmTitle => 'Restore backup?';

  @override
  String get backupRestoreConfirmBody =>
      'This will replace your current data. You will need to restart the app afterward.';

  @override
  String get searchHint => 'Search expenses, lists, notes…';

  @override
  String get searchTitleFallback => 'Search everything';

  @override
  String get searchSubtitleFallback =>
      'Find expenses, categories, shopping lists and notes.';

  @override
  String get searchNoExpenses => 'No matching expenses';

  @override
  String get searchNoLists => 'No matching lists';

  @override
  String get searchNoCategories => 'No matching categories';

  @override
  String get searchShoppingLists => 'Shopping Lists';

  @override
  String get searchCategories => 'Categories';

  @override
  String get moreCalendarTitle => 'Calendar';

  @override
  String get moreCalendarSubtitle => 'See spending by day';

  @override
  String get moreReportsTitle => 'Reports';

  @override
  String get moreReportsSubtitle => 'Charts and export';

  @override
  String get moreRecurringTitle => 'Recurring Expenses';

  @override
  String get moreRecurringSubtitle => 'Auto-log rent, subscriptions & more';

  @override
  String get moreSearchTitle => 'Search';

  @override
  String get moreSearchSubtitle => 'Find anything';

  @override
  String get moreBackupTitle => 'Backup & Restore';

  @override
  String get moreBackupSubtitle => 'Local backups';

  @override
  String get moreSettingsTitle => 'Settings';

  @override
  String get moreSettingsSubtitle => 'Customize your app';

  @override
  String get moreOnboardingTitle => 'Onboarding';

  @override
  String get moreOnboardingSubtitle => 'View intro again';

  @override
  String get filterThisMonth => 'This Month';

  @override
  String get filterThisYear => 'This Year';

  @override
  String get filterAllTime => 'All Time';

  @override
  String get filterCustom => 'Custom';

  @override
  String get dashboardOverspendingTitle => 'Over budget this month';

  @override
  String dashboardOverspendingBy(String amount) {
    return '$amount over';
  }

  @override
  String get dashboardOverspendingViewBudget => 'View Budget';

  @override
  String dashboardOverspendingMore(int count) {
    return '+$count more';
  }

  @override
  String get lockUnlockApp => 'Unlock ExpenseMate';

  @override
  String get backupExportTitle => 'Backup & Export';

  @override
  String get calendarUpcomingBills => 'Upcoming bills';

  @override
  String get calendarTransactionsHeader => 'Transactions';

  @override
  String get calendarAutoLog => 'Auto-log';

  @override
  String settingsSampleLabel(String value) {
    return 'Sample: $value';
  }

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get paywallTitleTrial => 'Unlock ExpenseMate';

  @override
  String get paywallTitleExpired => 'Your free trial has ended';

  @override
  String paywallSubtitleTrial(int days) {
    return '$days days left in your free trial. Unlock forever with a one-time payment.';
  }

  @override
  String get paywallSubtitleExpired =>
      'Continue tracking your money — one-time payment, no subscription.';

  @override
  String get paywallFeatureOffline => 'Works completely offline';

  @override
  String get paywallFeatureScanner => 'Smart receipt scanner';

  @override
  String get paywallFeatureReports => 'Detailed reports & charts';

  @override
  String get paywallFeatureBudgets => 'Budgets & bill reminders';

  @override
  String get paywallFeaturePrivacy => 'PIN & biometric lock';

  @override
  String get paywallFeatureLanguages => '6 languages';

  @override
  String paywallBuyButton(String price) {
    return 'Unlock forever · $price';
  }

  @override
  String get paywallRestore => 'Restore purchase';

  @override
  String get paywallFinePrint =>
      'One-time payment. No subscription. No auto-renewal.';

  @override
  String get paywallErrorGeneric => 'Purchase couldn\'t start. Try again.';

  @override
  String get paywallProductUnavailable =>
      'Store isn\'t reachable right now. Check your connection and try again.';

  @override
  String get paywallRestoreNone =>
      'No previous purchase found on this account.';

  @override
  String get paywallPending =>
      'Your purchase is being processed. You\'ll get access once it clears.';

  @override
  String get paywallRetry => 'Try again';
}
