class AppConstants {
  static const String appName = 'ExpenseMate';

  // Settings keys
  static const String kThemeMode = 'theme_mode';
  static const String kCurrencySymbol = 'currency_symbol';
  static const String kLanguage = 'language';
  static const String kDateFormat = 'date_format';
  static const String kFirstDayOfWeek = 'first_day_of_week';
  static const String kPinHash = 'pin_hash';
  static const String kBiometricEnabled = 'biometric_enabled';
  static const String kHasOnboarded = 'has_onboarded';
  static const String kBackupPath = 'backup_path';
  static const String kUserName = 'user_name';

  // Premium / IAP (stored in flutter_secure_storage)
  static const String kInstallTs = 'install_ts';
  static const String kIsPremium = 'is_premium';
  static const String kPremiumSku = 'com.lervit.expensemate.premium';
  static const int trialDays = 14;

  // Notification prefs
  static const String kDailyReminder = 'notif_daily_reminder';       // '1'/'0'
  static const String kDailyReminderTime = 'notif_daily_time';       // 'HH:mm'
  static const String kWeeklyReview = 'notif_weekly_review';         // '1'/'0'
  static const String kBudgetThresholdAlerts = 'notif_budget_alerts'; // '1'/'0'
  static const String kBillReminders = 'notif_bill_reminders';       // '1'/'0'

  static const List<String> paymentMethods = [
    'Cash',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'Digital Wallet',
    'Other',
  ];

  static const List<String> currencySymbols = ['\$', '€', '£', '¥', '₹', '₽', 'CHF', 'A\$', 'C\$', '₦'];

  /// Full list with code and human name — used by the settings picker.
  /// Symbol is what actually gets stored & used in formatting.
  static const List<CurrencyChoice> currencies = [
    CurrencyChoice(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyChoice(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyChoice(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyChoice(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    CurrencyChoice(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    CurrencyChoice(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    CurrencyChoice(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyChoice(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyChoice(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    CurrencyChoice(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
    CurrencyChoice(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    CurrencyChoice(code: 'MXN', symbol: 'MX\$', name: 'Mexican Peso'),
    CurrencyChoice(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
    CurrencyChoice(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
    CurrencyChoice(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
    CurrencyChoice(code: 'GHS', symbol: 'GH₵', name: 'Ghanaian Cedi'),
    CurrencyChoice(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
    CurrencyChoice(code: 'HKD', symbol: 'HK\$', name: 'Hong Kong Dollar'),
    CurrencyChoice(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
    CurrencyChoice(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
  ];

  static const List<String> recurrenceOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];
}

class CurrencyChoice {
  final String code;
  final String symbol;
  final String name;
  const CurrencyChoice({required this.code, required this.symbol, required this.name});
}

class Routes {
  static const String lock = '/lock';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String expenseNew = '/expenses/new';
  static const String expenseScan = '/expenses/scan';
  static const String grocery = '/grocery';
  static const String groceryNew = '/grocery/new';
  static const String budget = '/budget';
  static const String more = '/more';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String backup = '/backup';
  static const String search = '/search';
  static const String pinSetup = '/pin-setup';
  static const String recurring = '/recurring';
  static const String recurringNew = '/recurring/new';
  static const String calendar = '/calendar';
  static const String splash = '/splash';
  static const String paywall = '/paywall';
}
