import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ExpenseMate'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get navGrocery;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get actionGetStarted;

  /// No description provided for @actionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get actionAllow;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get actionUndo;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get commonThisMonth;

  /// No description provided for @commonThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get commonThisWeek;

  /// No description provided for @commonNextBill.
  ///
  /// In en, this message translates to:
  /// **'Next bill'**
  String get commonNextBill;

  /// No description provided for @commonUpcomingBills.
  ///
  /// In en, this message translates to:
  /// **'Upcoming bills'**
  String get commonUpcomingBills;

  /// No description provided for @commonTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get commonTransactions;

  /// No description provided for @commonRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get commonRecentTransactions;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonOverspending.
  ///
  /// In en, this message translates to:
  /// **'Overspending — reduce discretionary categories.'**
  String get commonOverspending;

  /// No description provided for @commonPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get commonPurchased;

  /// No description provided for @commonEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get commonEstimated;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonActual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get commonActual;

  /// No description provided for @commonEst.
  ///
  /// In en, this message translates to:
  /// **'Est.'**
  String get commonEst;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get commonMerchant;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get commonCategory;

  /// No description provided for @commonDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get commonDetails;

  /// No description provided for @commonReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get commonReceipt;

  /// No description provided for @commonFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get commonFavorite;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get commonPaymentMethod;

  /// No description provided for @commonMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get commonMonth;

  /// No description provided for @commonWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get commonWeek;

  /// No description provided for @commonYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get commonYear;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'ExpenseMate'**
  String get dashboardTitle;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardOverview;

  /// No description provided for @dashboardMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get dashboardMonthlyIncome;

  /// No description provided for @dashboardMonthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get dashboardMonthlyExpenses;

  /// No description provided for @dashboardRemainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Remaining Budget'**
  String get dashboardRemainingBudget;

  /// No description provided for @dashboardSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get dashboardSavings;

  /// No description provided for @dashboardBudgetUtilization.
  ///
  /// In en, this message translates to:
  /// **'Budget Utilization'**
  String get dashboardBudgetUtilization;

  /// No description provided for @dashboardSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get dashboardSpendingByCategory;

  /// No description provided for @dashboardMonthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trend'**
  String get dashboardMonthlyTrend;

  /// No description provided for @dashboardQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get dashboardQuickAdd;

  /// No description provided for @dashboardScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt'**
  String get dashboardScanReceipt;

  /// No description provided for @dashboardScanReceiptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fills amount, merchant and date'**
  String get dashboardScanReceiptSubtitle;

  /// No description provided for @dashboardEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get dashboardEnterManually;

  /// No description provided for @dashboardEnterManuallySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill the expense form yourself'**
  String get dashboardEnterManuallySubtitle;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Quick Add to log your first expense.'**
  String get dashboardEmptySubtitle;

  /// No description provided for @dashboardLiveDemo.
  ///
  /// In en, this message translates to:
  /// **'Live Demo — sample data'**
  String get dashboardLiveDemo;

  /// No description provided for @dashboardLiveDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every transaction here is seeded. Buy the full source to make it yours.'**
  String get dashboardLiveDemoSubtitle;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get expensesAdd;

  /// No description provided for @expensesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get expensesEdit;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters or tap + to add one.'**
  String get expensesEmptySubtitle;

  /// No description provided for @expensesFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get expensesFilter;

  /// No description provided for @expensesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expensesDeleted;

  /// No description provided for @expensesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get expensesDeleteConfirmTitle;

  /// No description provided for @expensesDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove the expense.'**
  String get expensesDeleteConfirmBody;

  /// No description provided for @expensesDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get expensesDuplicate;

  /// No description provided for @expensesUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get expensesUnfavorite;

  /// No description provided for @expensesEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get expensesEnterAmount;

  /// No description provided for @expensesPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Please pick a category'**
  String get expensesPickCategory;

  /// No description provided for @expensesSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get expensesSaveExpense;

  /// No description provided for @expensesUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get expensesUpdateExpense;

  /// No description provided for @expensesNoReceipt.
  ///
  /// In en, this message translates to:
  /// **'No receipt attached'**
  String get expensesNoReceipt;

  /// No description provided for @expensesAttached.
  ///
  /// In en, this message translates to:
  /// **'Attached'**
  String get expensesAttached;

  /// No description provided for @expensesAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get expensesAttach;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetMonthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly plan'**
  String get budgetMonthlyPlan;

  /// No description provided for @budgetMonthlyIncomePlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly income (plan)'**
  String get budgetMonthlyIncomePlan;

  /// No description provided for @budgetSpendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Spending limit'**
  String get budgetSpendingLimit;

  /// No description provided for @budgetSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get budgetSavingsGoal;

  /// No description provided for @budgetCategoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get budgetCategoryBudgets;

  /// No description provided for @budgetLogIncome.
  ///
  /// In en, this message translates to:
  /// **'Log Income'**
  String get budgetLogIncome;

  /// No description provided for @budgetSavePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get budgetSavePlan;

  /// No description provided for @budgetSavingsProgress.
  ///
  /// In en, this message translates to:
  /// **'Savings progress'**
  String get budgetSavingsProgress;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetSaved;

  /// No description provided for @budgetActualIncome.
  ///
  /// In en, this message translates to:
  /// **'Actual income'**
  String get budgetActualIncome;

  /// No description provided for @budgetSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpent;

  /// No description provided for @budgetSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get budgetSource;

  /// No description provided for @budgetSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get budgetSalary;

  /// No description provided for @budgetSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a savings goal to track progress'**
  String get budgetSetGoal;

  /// No description provided for @groceryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get groceryTitle;

  /// No description provided for @groceryYourLists.
  ///
  /// In en, this message translates to:
  /// **'Your lists'**
  String get groceryYourLists;

  /// No description provided for @groceryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shopping lists'**
  String get groceryEmptyTitle;

  /// No description provided for @groceryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first list to start tracking groceries.'**
  String get groceryEmptySubtitle;

  /// No description provided for @groceryNewList.
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get groceryNewList;

  /// No description provided for @groceryNewShoppingList.
  ///
  /// In en, this message translates to:
  /// **'New Shopping List'**
  String get groceryNewShoppingList;

  /// No description provided for @groceryListName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get groceryListName;

  /// No description provided for @groceryEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get groceryEnterName;

  /// No description provided for @groceryMarkFavorite.
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite'**
  String get groceryMarkFavorite;

  /// No description provided for @groceryCreateList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get groceryCreateList;

  /// No description provided for @groceryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get groceryUpdated;

  /// No description provided for @groceryDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get groceryDuplicate;

  /// No description provided for @groceryArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get groceryArchive;

  /// No description provided for @groceryEmptyItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get groceryEmptyItemsTitle;

  /// No description provided for @groceryEmptyItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first item.'**
  String get groceryEmptyItemsSubtitle;

  /// No description provided for @groceryAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get groceryAddItem;

  /// No description provided for @groceryEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get groceryEditItem;

  /// No description provided for @groceryItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get groceryItemName;

  /// No description provided for @groceryQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get groceryQty;

  /// No description provided for @groceryUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get groceryUnit;

  /// No description provided for @groceryStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get groceryStore;

  /// No description provided for @groceryDuplicateList.
  ///
  /// In en, this message translates to:
  /// **'Duplicate list'**
  String get groceryDuplicateList;

  /// No description provided for @groceryDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get groceryDeleteList;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportsMonthly;

  /// No description provided for @reportsYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get reportsYearly;

  /// No description provided for @reportsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportsCategory;

  /// No description provided for @reportsIncomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get reportsIncomeVsExpense;

  /// No description provided for @reportsSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get reportsSavings;

  /// No description provided for @reportsCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get reportsCsv;

  /// No description provided for @reportsExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get reportsExcel;

  /// No description provided for @reportsPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get reportsPdf;

  /// No description provided for @reportsLastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get reportsLastSixMonths;

  /// No description provided for @reportsExpensesByMonth.
  ///
  /// In en, this message translates to:
  /// **'Expenses by month'**
  String get reportsExpensesByMonth;

  /// No description provided for @reportsIncomeByMonth.
  ///
  /// In en, this message translates to:
  /// **'Income by month'**
  String get reportsIncomeByMonth;

  /// No description provided for @reportsIncomeMo.
  ///
  /// In en, this message translates to:
  /// **'Income (mo)'**
  String get reportsIncomeMo;

  /// No description provided for @reportsExpensesMo.
  ///
  /// In en, this message translates to:
  /// **'Expenses (mo)'**
  String get reportsExpensesMo;

  /// No description provided for @reportsSavingsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Savings per month'**
  String get reportsSavingsPerMonth;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarNothingOnDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day'**
  String get calendarNothingOnDay;

  /// No description provided for @calendarNothingOnDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a day with a dot to see transactions.'**
  String get calendarNothingOnDaySubtitle;

  /// No description provided for @calendarTransactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String calendarTransactionsCount(int count);

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Expenses'**
  String get recurringTitle;

  /// No description provided for @recurringNewRule.
  ///
  /// In en, this message translates to:
  /// **'New Rule'**
  String get recurringNewRule;

  /// No description provided for @recurringNewRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Recurring Rule'**
  String get recurringNewRuleTitle;

  /// No description provided for @recurringEditRule.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get recurringEditRule;

  /// No description provided for @recurringEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recurring rules yet'**
  String get recurringEmptyTitle;

  /// No description provided for @recurringEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add subscriptions like Netflix, rent, or insurance. They\'ll auto-log on their due date.'**
  String get recurringEmptySubtitle;

  /// No description provided for @recurringNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get recurringNext;

  /// No description provided for @recurringFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringFrequency;

  /// No description provided for @recurringNextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get recurringNextDue;

  /// No description provided for @recurringEnterMerchant.
  ///
  /// In en, this message translates to:
  /// **'Enter a merchant'**
  String get recurringEnterMerchant;

  /// No description provided for @recurringCreateRule.
  ///
  /// In en, this message translates to:
  /// **'Create Rule'**
  String get recurringCreateRule;

  /// No description provided for @recurringSaveRule.
  ///
  /// In en, this message translates to:
  /// **'Save Rule'**
  String get recurringSaveRule;

  /// No description provided for @recurringDeleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete rule?'**
  String get recurringDeleteRule;

  /// No description provided for @recurringDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This won\'t remove past expenses. {merchant} will just stop auto-logging.'**
  String recurringDeleteBody(String merchant);

  /// No description provided for @recurringDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurringDaily;

  /// No description provided for @recurringWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringWeekly;

  /// No description provided for @recurringMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringMonthly;

  /// No description provided for @recurringYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringYearly;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanTitle;

  /// No description provided for @scanPoint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the receipt'**
  String get scanPoint;

  /// No description provided for @scanAutoFill.
  ///
  /// In en, this message translates to:
  /// **'We\'ll read the total, merchant, and date automatically.'**
  String get scanAutoFill;

  /// No description provided for @scanOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get scanOpenCamera;

  /// No description provided for @scanPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get scanPickGallery;

  /// No description provided for @scanReading.
  ///
  /// In en, this message translates to:
  /// **'Reading receipt…'**
  String get scanReading;

  /// No description provided for @scanCantRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the receipt clearly. Try again or fill in the details manually.'**
  String get scanCantRead;

  /// No description provided for @scanWhatFound.
  ///
  /// In en, this message translates to:
  /// **'What we found'**
  String get scanWhatFound;

  /// No description provided for @scanContinueForm.
  ///
  /// In en, this message translates to:
  /// **'Continue to expense form'**
  String get scanContinueForm;

  /// No description provided for @scanRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanRetake;

  /// No description provided for @scanRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get scanRead;

  /// No description provided for @scanItemsDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} items detected'**
  String scanItemsDetected(int count);

  /// No description provided for @scanFullListNote.
  ///
  /// In en, this message translates to:
  /// **'Full list will be saved to the expense notes.'**
  String get scanFullListNote;

  /// No description provided for @scanReceiptItems.
  ///
  /// In en, this message translates to:
  /// **'Receipt items:'**
  String get scanReceiptItems;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get settingsDateFormat;

  /// No description provided for @settingsFirstDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get settingsFirstDayOfWeek;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get settingsSetPin;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsPinEnabled.
  ///
  /// In en, this message translates to:
  /// **'PIN lock enabled'**
  String get settingsPinEnabled;

  /// No description provided for @settingsPinDisabled.
  ///
  /// In en, this message translates to:
  /// **'App is unlocked'**
  String get settingsPinDisabled;

  /// No description provided for @settingsRemovePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get settingsRemovePin;

  /// No description provided for @settingsRemovePinBody.
  ///
  /// In en, this message translates to:
  /// **'The app will no longer be locked.'**
  String get settingsRemovePinBody;

  /// No description provided for @settingsBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get settingsBiometric;

  /// No description provided for @settingsBiometricAvailable.
  ///
  /// In en, this message translates to:
  /// **'Face ID / Fingerprint'**
  String get settingsBiometricAvailable;

  /// No description provided for @settingsBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get settingsBiometricUnavailable;

  /// No description provided for @settingsBiometricNeedsPin.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN first to enable biometric unlock'**
  String get settingsBiometricNeedsPin;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsBackup;

  /// No description provided for @settingsReports.
  ///
  /// In en, this message translates to:
  /// **'Reports & Export'**
  String get settingsReports;

  /// No description provided for @settingsResetDemo.
  ///
  /// In en, this message translates to:
  /// **'Reset demo data'**
  String get settingsResetDemo;

  /// No description provided for @settingsResetDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wipe entries and reload the built-in demo dataset'**
  String get settingsResetDemoSubtitle;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset demo data?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This wipes all expenses, income, budgets, and shopping lists, then reloads the built-in demo dataset. Your PIN, currency and theme are kept.'**
  String get settingsResetConfirmBody;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Demo data reloaded'**
  String get settingsResetSuccess;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · Offline-first · No cloud'**
  String settingsVersion(String version);

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily log reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nudge at {time}'**
  String settingsDailyReminderSubtitle(String time);

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsWeeklyReview.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get settingsWeeklyReview;

  /// No description provided for @settingsWeeklyReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sunday 6 PM · spending recap'**
  String get settingsWeeklyReviewSubtitle;

  /// No description provided for @settingsBudgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget threshold alerts'**
  String get settingsBudgetAlerts;

  /// No description provided for @settingsBudgetAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert at 80% and 100% of category budgets'**
  String get settingsBudgetAlertsSubtitle;

  /// No description provided for @settingsBillReminders.
  ///
  /// In en, this message translates to:
  /// **'Bill reminders'**
  String get settingsBillReminders;

  /// No description provided for @settingsBillRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1 day before recurring expenses'**
  String get settingsBillRemindersSubtitle;

  /// No description provided for @settingsChooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose currency'**
  String get settingsChooseCurrency;

  /// No description provided for @settingsCurrenciesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String settingsCurrenciesAvailable(int count);

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsChooseLanguage;

  /// No description provided for @onboardTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Every dollar, tracked'**
  String get onboardTrackTitle;

  /// No description provided for @onboardTrackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log expenses in seconds. Categorize, favorite, and attach receipts — all fully offline.'**
  String get onboardTrackSubtitle;

  /// No description provided for @onboardGroceryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery lists that work'**
  String get onboardGroceryTitle;

  /// No description provided for @onboardGrocerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan trips with estimated prices, tick items off in-store, and see the real total.'**
  String get onboardGrocerySubtitle;

  /// No description provided for @onboardSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked behind Face ID'**
  String get onboardSecurityTitle;

  /// No description provided for @onboardSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional 4-digit PIN and biometric unlock. Your finances stay for your eyes only.'**
  String get onboardSecuritySubtitle;

  /// No description provided for @onboardOwnDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data, your device'**
  String get onboardOwnDataTitle;

  /// No description provided for @onboardOwnDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts. No cloud. Backup and export whenever you want — you\'re in control.'**
  String get onboardOwnDataSubtitle;

  /// No description provided for @onboardFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free forever, always'**
  String get onboardFreeTitle;

  /// No description provided for @onboardFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No subscription. No ads. No account. Just a premium finance tracker that works.'**
  String get onboardFreeSubtitle;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get categoryFuel;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryDining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get categoryDining;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get categoryHealthcare;

  /// No description provided for @categoryTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get categoryTransportation;

  /// No description provided for @categoryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get categoryInsurance;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// No description provided for @categoryMiscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get categoryMiscellaneous;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get paymentDebitCard;

  /// No description provided for @paymentCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get paymentCreditCard;

  /// No description provided for @paymentBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentBankTransfer;

  /// No description provided for @paymentDigitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get paymentDigitalWallet;

  /// No description provided for @paymentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentOther;

  /// No description provided for @lockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get lockEnterPin;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock ExpenseMate'**
  String get lockUnlock;

  /// No description provided for @pinSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to protect your data.'**
  String get pinCreateSubtitle;

  /// No description provided for @pinNew.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get pinNew;

  /// No description provided for @pinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinConfirm;

  /// No description provided for @pinSavePin.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get pinSavePin;

  /// No description provided for @pinMustBe4.
  ///
  /// In en, this message translates to:
  /// **'PIN must be exactly 4 digits'**
  String get pinMustBe4;

  /// No description provided for @pinNoMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinNoMatch;

  /// No description provided for @pinSet.
  ///
  /// In en, this message translates to:
  /// **'PIN set'**
  String get pinSet;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get commonAny;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get actionAttach;

  /// No description provided for @expensesFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get expensesFavorites;

  /// No description provided for @expensesScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get expensesScanTooltip;

  /// No description provided for @expensesFilterDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get expensesFilterDateRange;

  /// No description provided for @moreLockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get moreLockNow;

  /// No description provided for @groceryDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get groceryDetailFallbackTitle;

  /// No description provided for @backupExportDatabase.
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get backupExportDatabase;

  /// No description provided for @backupExportDatabaseBody.
  ///
  /// In en, this message translates to:
  /// **'Save a copy of your SQLite database locally and share it.'**
  String get backupExportDatabaseBody;

  /// No description provided for @backupExportShare.
  ///
  /// In en, this message translates to:
  /// **'Export & Share'**
  String get backupExportShare;

  /// No description provided for @backupRestoreDatabase.
  ///
  /// In en, this message translates to:
  /// **'Restore Database'**
  String get backupRestoreDatabase;

  /// No description provided for @backupRestoreDatabaseBody.
  ///
  /// In en, this message translates to:
  /// **'Replace current data with a previous backup file.'**
  String get backupRestoreDatabaseBody;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore;

  /// No description provided for @backupExportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Expenses as CSV'**
  String get backupExportCsvTitle;

  /// No description provided for @backupExportCsvBody.
  ///
  /// In en, this message translates to:
  /// **'For spreadsheets or manual analysis.'**
  String get backupExportCsvBody;

  /// No description provided for @backupExportExcelTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Expenses as Excel'**
  String get backupExportExcelTitle;

  /// No description provided for @backupExportExcelBody.
  ///
  /// In en, this message translates to:
  /// **'XLSX file with all your expenses.'**
  String get backupExportExcelBody;

  /// No description provided for @backupExportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Expenses as PDF'**
  String get backupExportPdfTitle;

  /// No description provided for @backupExportPdfBody.
  ///
  /// In en, this message translates to:
  /// **'Formatted PDF report of your expenses.'**
  String get backupExportPdfBody;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current data. You will need to restart the app afterward.'**
  String get backupRestoreConfirmBody;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search expenses, lists, notes…'**
  String get searchHint;

  /// No description provided for @searchTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Search everything'**
  String get searchTitleFallback;

  /// No description provided for @searchSubtitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Find expenses, categories, shopping lists and notes.'**
  String get searchSubtitleFallback;

  /// No description provided for @searchNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No matching expenses'**
  String get searchNoExpenses;

  /// No description provided for @searchNoLists.
  ///
  /// In en, this message translates to:
  /// **'No matching lists'**
  String get searchNoLists;

  /// No description provided for @searchNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No matching categories'**
  String get searchNoCategories;

  /// No description provided for @searchShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get searchShoppingLists;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get searchCategories;

  /// No description provided for @moreCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get moreCalendarTitle;

  /// No description provided for @moreCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See spending by day'**
  String get moreCalendarSubtitle;

  /// No description provided for @moreReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get moreReportsTitle;

  /// No description provided for @moreReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charts and export'**
  String get moreReportsSubtitle;

  /// No description provided for @moreRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Expenses'**
  String get moreRecurringTitle;

  /// No description provided for @moreRecurringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-log rent, subscriptions & more'**
  String get moreRecurringSubtitle;

  /// No description provided for @moreSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get moreSearchTitle;

  /// No description provided for @moreSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find anything'**
  String get moreSearchSubtitle;

  /// No description provided for @moreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get moreBackupTitle;

  /// No description provided for @moreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local backups'**
  String get moreBackupSubtitle;

  /// No description provided for @moreSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettingsTitle;

  /// No description provided for @moreSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your app'**
  String get moreSettingsSubtitle;

  /// No description provided for @moreOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get moreOnboardingTitle;

  /// No description provided for @moreOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View intro again'**
  String get moreOnboardingSubtitle;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get filterThisMonth;

  /// No description provided for @filterThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get filterThisYear;

  /// No description provided for @filterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAllTime;

  /// No description provided for @filterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get filterCustom;

  /// No description provided for @dashboardOverspendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Over budget this month'**
  String get dashboardOverspendingTitle;

  /// No description provided for @dashboardOverspendingBy.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String dashboardOverspendingBy(String amount);

  /// No description provided for @dashboardOverspendingViewBudget.
  ///
  /// In en, this message translates to:
  /// **'View Budget'**
  String get dashboardOverspendingViewBudget;

  /// No description provided for @lockUnlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock ExpenseMate'**
  String get lockUnlockApp;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Export'**
  String get backupExportTitle;

  /// No description provided for @calendarUpcomingBills.
  ///
  /// In en, this message translates to:
  /// **'Upcoming bills'**
  String get calendarUpcomingBills;

  /// No description provided for @calendarTransactionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get calendarTransactionsHeader;

  /// No description provided for @calendarAutoLog.
  ///
  /// In en, this message translates to:
  /// **'Auto-log'**
  String get calendarAutoLog;

  /// No description provided for @settingsSampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Sample: {value}'**
  String settingsSampleLabel(String value);

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @paywallTitleTrial.
  ///
  /// In en, this message translates to:
  /// **'Unlock ExpenseMate'**
  String get paywallTitleTrial;

  /// No description provided for @paywallTitleExpired.
  ///
  /// In en, this message translates to:
  /// **'Your free trial has ended'**
  String get paywallTitleExpired;

  /// No description provided for @paywallSubtitleTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in your free trial. Unlock forever with a one-time payment.'**
  String paywallSubtitleTrial(int days);

  /// No description provided for @paywallSubtitleExpired.
  ///
  /// In en, this message translates to:
  /// **'Continue tracking your money — one-time payment, no subscription.'**
  String get paywallSubtitleExpired;

  /// No description provided for @paywallFeatureOffline.
  ///
  /// In en, this message translates to:
  /// **'Works completely offline'**
  String get paywallFeatureOffline;

  /// No description provided for @paywallFeatureScanner.
  ///
  /// In en, this message translates to:
  /// **'Smart receipt scanner'**
  String get paywallFeatureScanner;

  /// No description provided for @paywallFeatureReports.
  ///
  /// In en, this message translates to:
  /// **'Detailed reports & charts'**
  String get paywallFeatureReports;

  /// No description provided for @paywallFeatureBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets & bill reminders'**
  String get paywallFeatureBudgets;

  /// No description provided for @paywallFeaturePrivacy.
  ///
  /// In en, this message translates to:
  /// **'PIN & biometric lock'**
  String get paywallFeaturePrivacy;

  /// No description provided for @paywallFeatureLanguages.
  ///
  /// In en, this message translates to:
  /// **'6 languages'**
  String get paywallFeatureLanguages;

  /// No description provided for @paywallBuyButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock forever · {price}'**
  String paywallBuyButton(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get paywallRestore;

  /// No description provided for @paywallFinePrint.
  ///
  /// In en, this message translates to:
  /// **'One-time payment. No subscription. No auto-renewal.'**
  String get paywallFinePrint;

  /// No description provided for @paywallErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Purchase couldn\'t start. Try again.'**
  String get paywallErrorGeneric;

  /// No description provided for @paywallProductUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store isn\'t reachable right now. Check your connection and try again.'**
  String get paywallProductUnavailable;

  /// No description provided for @paywallRestoreNone.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found on this account.'**
  String get paywallRestoreNone;

  /// No description provided for @paywallPending.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is being processed. You\'ll get access once it clears.'**
  String get paywallPending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'es',
        'fr',
        'hi',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
