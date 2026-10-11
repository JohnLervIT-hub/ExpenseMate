// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'ExpenseMate';

  @override
  String get navHome => 'होम';

  @override
  String get navExpenses => 'खर्च';

  @override
  String get navGrocery => 'किराना';

  @override
  String get navBudget => 'बजट';

  @override
  String get navMore => 'और';

  @override
  String get actionSave => 'सेव करें';

  @override
  String get actionCancel => 'रद्द';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionEdit => 'बदलें';

  @override
  String get actionDone => 'पूर्ण';

  @override
  String get actionSkip => 'छोड़ें';

  @override
  String get actionNext => 'आगे';

  @override
  String get actionBack => 'वापस';

  @override
  String get actionAdd => 'जोड़ें';

  @override
  String get actionSearch => 'खोजें';

  @override
  String get actionRetry => 'फिर से';

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get actionGetStarted => 'शुरू करें';

  @override
  String get actionAllow => 'अनुमति दें';

  @override
  String get actionRemove => 'हटाएं';

  @override
  String get actionUndo => 'पूर्ववत';

  @override
  String get actionReset => 'रीसेट';

  @override
  String get commonToday => 'आज';

  @override
  String get commonThisMonth => 'इस महीने';

  @override
  String get commonThisWeek => 'इस हफ्ते';

  @override
  String get commonNextBill => 'अगला बिल';

  @override
  String get commonUpcomingBills => 'आने वाले बिल';

  @override
  String get commonTransactions => 'लेन-देन';

  @override
  String get commonRecentTransactions => 'हाल के लेन-देन';

  @override
  String get commonViewAll => 'सभी देखें';

  @override
  String get commonOverspending =>
      'बजट से ज़्यादा — कम ज़रूरी श्रेणियां घटाएं.';

  @override
  String get commonPurchased => 'खरीदा';

  @override
  String get commonEstimated => 'अनुमानित';

  @override
  String get commonTotal => 'कुल';

  @override
  String get commonActual => 'वास्तविक';

  @override
  String get commonEst => 'अनु.';

  @override
  String get commonAmount => 'राशि';

  @override
  String get commonMerchant => 'दुकान';

  @override
  String get commonDate => 'दिनांक';

  @override
  String get commonNotes => 'नोट्स';

  @override
  String get commonCategory => 'श्रेणी';

  @override
  String get commonDetails => 'विवरण';

  @override
  String get commonReceipt => 'रसीद';

  @override
  String get commonFavorite => 'पसंदीदा';

  @override
  String get commonActive => 'सक्रिय';

  @override
  String get commonPaymentMethod => 'भुगतान तरीका';

  @override
  String get commonMonth => 'महीना';

  @override
  String get commonWeek => 'सप्ताह';

  @override
  String get commonTwoWeeks => '2 सप्ताह';

  @override
  String get commonYear => 'साल';

  @override
  String get dashboardTitle => 'ExpenseMate';

  @override
  String get dashboardOverview => 'सारांश';

  @override
  String dashboardGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get onboardNameTitle => 'हम आपको क्या कहें?';

  @override
  String get onboardNameSubtitle => 'ताकि ऐप खोलने पर हम आपका अभिवादन कर सकें.';

  @override
  String get onboardNameHint => 'आपका नाम';

  @override
  String get dashboardMonthlyIncome => 'मासिक आय';

  @override
  String get dashboardMonthlyExpenses => 'मासिक खर्च';

  @override
  String get dashboardRemainingBudget => 'बचा बजट';

  @override
  String get dashboardSavings => 'बचत';

  @override
  String get dashboardBudgetUtilization => 'बजट उपयोग';

  @override
  String get dashboardSpendingByCategory => 'श्रेणी अनुसार खर्च';

  @override
  String get dashboardMonthlyTrend => 'मासिक रुझान';

  @override
  String get dashboardQuickAdd => 'जल्दी जोड़ें';

  @override
  String get dashboardScanReceipt => 'रसीद स्कैन करें';

  @override
  String get dashboardScanReceiptSubtitle =>
      'राशि, दुकान और तारीख अपने आप भरता है';

  @override
  String get dashboardEnterManually => 'मैन्युअल भरें';

  @override
  String get dashboardEnterManuallySubtitle => 'फ़ॉर्म खुद भरें';

  @override
  String get dashboardEmptyTitle => 'अभी कोई लेन-देन नहीं';

  @override
  String get dashboardEmptySubtitle =>
      'जल्दी जोड़ें पर टैप कर पहला खर्च लिखें.';

  @override
  String get dashboardLiveDemo => 'लाइव डेमो — नमूना डेटा';

  @override
  String get dashboardLiveDemoSubtitle =>
      'यहां सब कुछ नमूना है. पूरा सोर्स खरीदें और अपना बनाएं.';

  @override
  String get expensesTitle => 'खर्च';

  @override
  String get expensesAdd => 'खर्च जोड़ें';

  @override
  String get expensesEdit => 'खर्च बदलें';

  @override
  String get expensesEmptyTitle => 'कोई खर्च नहीं मिला';

  @override
  String get expensesEmptySubtitle => 'फ़िल्टर बदलें या + दबाकर जोड़ें.';

  @override
  String get expensesFilter => 'फ़िल्टर';

  @override
  String get expensesDeleted => 'खर्च हटा दिया गया';

  @override
  String get expensesDeleteConfirmTitle => 'खर्च हटाएं?';

  @override
  String get expensesDeleteConfirmBody => 'यह खर्च हटा दिया जाएगा.';

  @override
  String get expensesDuplicate => 'प्रतिलिपि';

  @override
  String get expensesUnfavorite => 'पसंद से हटाएं';

  @override
  String get expensesEnterAmount => 'राशि डालें';

  @override
  String get expensesPickCategory => 'श्रेणी चुनें';

  @override
  String get expensesSaveExpense => 'खर्च सेव करें';

  @override
  String get expensesUpdateExpense => 'खर्च अपडेट करें';

  @override
  String get expensesNoReceipt => 'कोई रसीद नहीं';

  @override
  String get expensesAttached => 'जोड़ी गई';

  @override
  String get expensesAttach => 'जोड़ें';

  @override
  String get budgetTitle => 'बजट';

  @override
  String get budgetMonthlyPlan => 'मासिक योजना';

  @override
  String get budgetMonthlyIncomePlan => 'मासिक आय (योजना)';

  @override
  String get budgetSpendingLimit => 'खर्च सीमा';

  @override
  String get budgetSavingsGoal => 'बचत लक्ष्य';

  @override
  String get budgetCategoryBudgets => 'श्रेणी बजट';

  @override
  String get budgetLogIncome => 'आय दर्ज करें';

  @override
  String get budgetSavePlan => 'योजना सेव करें';

  @override
  String get budgetSavingsProgress => 'बचत प्रगति';

  @override
  String get budgetSaved => 'बजट सेव हो गया';

  @override
  String get budgetActualIncome => 'वास्तविक आय';

  @override
  String get budgetSpent => 'खर्च';

  @override
  String get budgetSource => 'स्रोत';

  @override
  String get budgetSalary => 'वेतन';

  @override
  String get budgetSetGoal => 'प्रगति देखने के लिए बचत लक्ष्य तय करें';

  @override
  String get groceryTitle => 'किराना';

  @override
  String get groceryYourLists => 'आपकी सूचियां';

  @override
  String get groceryEmptyTitle => 'कोई सूची नहीं';

  @override
  String get groceryEmptySubtitle => 'पहली सूची बनाकर शुरू करें.';

  @override
  String get groceryNewList => 'नई सूची';

  @override
  String get groceryNewShoppingList => 'नई खरीदारी सूची';

  @override
  String get groceryListName => 'सूची का नाम';

  @override
  String get groceryEnterName => 'नाम डालें';

  @override
  String get groceryMarkFavorite => 'पसंदीदा बनाएं';

  @override
  String get groceryCreateList => 'सूची बनाएं';

  @override
  String get groceryUpdated => 'अपडेट';

  @override
  String get groceryDuplicate => 'प्रतिलिपि';

  @override
  String get groceryArchive => 'संग्रह';

  @override
  String get groceryEmptyItemsTitle => 'अभी कोई आइटम नहीं';

  @override
  String get groceryEmptyItemsSubtitle => 'पहला आइटम जोड़ने के लिए + दबाएं.';

  @override
  String get groceryAddItem => 'आइटम जोड़ें';

  @override
  String get groceryEditItem => 'आइटम बदलें';

  @override
  String get groceryItemName => 'आइटम का नाम';

  @override
  String get groceryQty => 'मात्रा';

  @override
  String get groceryUnit => 'इकाई';

  @override
  String get groceryStore => 'दुकान';

  @override
  String get groceryDuplicateList => 'सूची की प्रतिलिपि';

  @override
  String get groceryDeleteList => 'सूची हटाएं';

  @override
  String get reportsTitle => 'रिपोर्ट';

  @override
  String get reportsMonthly => 'मासिक';

  @override
  String get reportsYearly => 'वार्षिक';

  @override
  String get reportsCategory => 'श्रेणी';

  @override
  String get reportsIncomeVsExpense => 'आय बनाम खर्च';

  @override
  String get reportsSavings => 'बचत';

  @override
  String get reportsCsv => 'CSV';

  @override
  String get reportsExcel => 'Excel';

  @override
  String get reportsPdf => 'PDF';

  @override
  String get reportsLastSixMonths => 'पिछले 6 महीने';

  @override
  String get reportsExpensesByMonth => 'महीने के अनुसार खर्च';

  @override
  String get reportsIncomeByMonth => 'महीने के अनुसार आय';

  @override
  String get reportsIncomeMo => 'आय (माह)';

  @override
  String get reportsExpensesMo => 'खर्च (माह)';

  @override
  String get reportsSavingsPerMonth => 'मासिक बचत';

  @override
  String get calendarTitle => 'कैलेंडर';

  @override
  String get calendarNothingOnDay => 'इस दिन कुछ नहीं';

  @override
  String get calendarNothingOnDaySubtitle =>
      'बिंदु वाला दिन दबाकर लेन-देन देखें.';

  @override
  String calendarTransactionsCount(int count) {
    return '$count लेन-देन';
  }

  @override
  String get recurringTitle => 'आवर्ती खर्च';

  @override
  String get recurringNewRule => 'नया नियम';

  @override
  String get recurringNewRuleTitle => 'नया आवर्ती नियम';

  @override
  String get recurringEditRule => 'नियम बदलें';

  @override
  String get recurringEmptyTitle => 'कोई आवर्ती नियम नहीं';

  @override
  String get recurringEmptySubtitle =>
      'Netflix, किराया या बीमा जैसे सब्सक्रिप्शन जोड़ें. देय तिथि पर स्वतः दर्ज होंगे.';

  @override
  String get recurringNext => 'अगला';

  @override
  String get recurringFrequency => 'आवृत्ति';

  @override
  String get recurringNextDue => 'अगली देय तिथि';

  @override
  String get recurringEnterMerchant => 'दुकान डालें';

  @override
  String get recurringCreateRule => 'नियम बनाएं';

  @override
  String get recurringSaveRule => 'नियम सेव करें';

  @override
  String get recurringDeleteRule => 'नियम हटाएं?';

  @override
  String recurringDeleteBody(String merchant) {
    return 'पिछले खर्च नहीं हटेंगे. $merchant स्वतः दर्ज होना बंद हो जाएगा.';
  }

  @override
  String get recurringDaily => 'दैनिक';

  @override
  String get recurringWeekly => 'साप्ताहिक';

  @override
  String get recurringMonthly => 'मासिक';

  @override
  String get recurringYearly => 'वार्षिक';

  @override
  String get scanTitle => 'रसीद स्कैन';

  @override
  String get scanPoint => 'कैमरा को रसीद पर रखें';

  @override
  String get scanAutoFill => 'हम कुल, दुकान और तारीख अपने आप पढ़ेंगे.';

  @override
  String get scanOpenCamera => 'कैमरा खोलें';

  @override
  String get scanPickGallery => 'गैलरी से चुनें';

  @override
  String get scanReading => 'रसीद पढ़ रहे हैं…';

  @override
  String get scanCantRead =>
      'रसीद स्पष्ट नहीं पढ़ पाए. फिर कोशिश करें या मैन्युअल भरें.';

  @override
  String get scanWhatFound => 'हमें क्या मिला';

  @override
  String get scanContinueForm => 'फ़ॉर्म पर जाएं';

  @override
  String get scanRetake => 'फिर से लें';

  @override
  String get scanRead => 'पढ़ा';

  @override
  String scanItemsDetected(int count) {
    return '$count आइटम मिले';
  }

  @override
  String get scanFullListNote => 'पूरी सूची नोट्स में सेव होगी.';

  @override
  String get scanReceiptItems => 'रसीद के आइटम:';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAppearance => 'रूप';

  @override
  String get settingsSystem => 'सिस्टम';

  @override
  String get settingsLight => 'लाइट';

  @override
  String get settingsDark => 'डार्क';

  @override
  String get settingsPreferences => 'प्राथमिकताएं';

  @override
  String get settingsCurrency => 'मुद्रा';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsDateFormat => 'तारीख का प्रारूप';

  @override
  String get settingsFirstDayOfWeek => 'हफ्ते का पहला दिन';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsSetPin => 'PIN सेट करें';

  @override
  String get settingsChangePin => 'PIN बदलें';

  @override
  String get settingsPinEnabled => 'PIN लॉक चालू';

  @override
  String get settingsPinDisabled => 'ऐप अनलॉक है';

  @override
  String get settingsRemovePin => 'PIN हटाएं';

  @override
  String get settingsRemovePinBody => 'ऐप अब लॉक नहीं होगा.';

  @override
  String get settingsBiometric => 'बायोमेट्रिक अनलॉक';

  @override
  String get settingsBiometricAvailable => 'Face ID / फिंगरप्रिंट';

  @override
  String get settingsBiometricUnavailable => 'इस डिवाइस पर उपलब्ध नहीं';

  @override
  String get settingsBiometricNeedsPin =>
      'बायोमेट्रिक अनलॉक चालू करने के लिए पहले PIN सेट करें';

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsBackup => 'बैकअप और रिस्टोर';

  @override
  String get settingsReports => 'रिपोर्ट और एक्सपोर्ट';

  @override
  String get settingsResetDemo => 'डेमो डेटा रीसेट';

  @override
  String get settingsResetDemoSubtitle =>
      'एंट्रीज मिटाकर डेमो डेटा फिर लोड करें';

  @override
  String get settingsResetConfirmTitle => 'डेमो डेटा रीसेट?';

  @override
  String get settingsResetConfirmBody =>
      'यह सभी खर्च, आय, बजट और सूचियां मिटाकर डेमो डेटा फिर लोड करता है. आपका PIN, मुद्रा और थीम बचे रहते हैं.';

  @override
  String get settingsResetSuccess => 'डेमो डेटा फिर लोड हो गया';

  @override
  String get settingsAbout => 'बारे में';

  @override
  String settingsVersion(String version) {
    return 'संस्करण $version · ऑफ़लाइन · बिना क्लाउड';
  }

  @override
  String get settingsNotifications => 'सूचनाएं';

  @override
  String get settingsDailyReminder => 'दैनिक रिमाइंडर';

  @override
  String settingsDailyReminderSubtitle(String time) {
    return '$time पर';
  }

  @override
  String get settingsReminderTime => 'रिमाइंडर समय';

  @override
  String get settingsWeeklyReview => 'साप्ताहिक समीक्षा';

  @override
  String get settingsWeeklyReviewSubtitle => 'रविवार 6 बजे · खर्च का सारांश';

  @override
  String get settingsBudgetAlerts => 'बजट अलर्ट';

  @override
  String get settingsBudgetAlertsSubtitle => 'बजट के 80% और 100% पर अलर्ट';

  @override
  String get settingsBillReminders => 'बिल रिमाइंडर';

  @override
  String get settingsBillRemindersSubtitle => 'आवर्ती खर्च से 1 दिन पहले';

  @override
  String get settingsChooseCurrency => 'मुद्रा चुनें';

  @override
  String settingsCurrenciesAvailable(int count) {
    return '$count उपलब्ध';
  }

  @override
  String get settingsChooseLanguage => 'भाषा चुनें';

  @override
  String get onboardTrackTitle => 'हर रुपया, दर्ज';

  @override
  String get onboardTrackSubtitle =>
      'सेकंडों में खर्च लिखें. श्रेणी दें, पसंदीदा बनाएं, रसीद जोड़ें — पूरी तरह ऑफ़लाइन.';

  @override
  String get onboardGroceryTitle => 'काम की खरीदारी सूचियां';

  @override
  String get onboardGrocerySubtitle =>
      'अनुमानित कीमतों से योजना बनाएं, दुकान में टिक करें, असली कुल देखें.';

  @override
  String get onboardSecurityTitle => 'Face ID से सुरक्षित';

  @override
  String get onboardSecuritySubtitle =>
      'वैकल्पिक 4-अंकीय PIN और बायोमेट्रिक अनलॉक. आपके पैसे सिर्फ आपके लिए.';

  @override
  String get onboardOwnDataTitle => 'आपका डेटा, आपका फोन';

  @override
  String get onboardOwnDataSubtitle =>
      'कोई अकाउंट नहीं. कोई क्लाउड नहीं. जब चाहें बैकअप और एक्सपोर्ट.';

  @override
  String get onboardFreeTitle => 'हमेशा के लिए मुफ्त';

  @override
  String get onboardFreeSubtitle =>
      'कोई सब्सक्रिप्शन नहीं. कोई विज्ञापन नहीं. कोई अकाउंट नहीं. काम करने वाला प्रीमियम ट्रैकर.';

  @override
  String get categoryGroceries => 'किराना';

  @override
  String get categoryFuel => 'ईंधन';

  @override
  String get categoryRent => 'किराया';

  @override
  String get categoryUtilities => 'यूटिलिटीज़';

  @override
  String get categoryDining => 'बाहर खाना';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryHealthcare => 'स्वास्थ्य';

  @override
  String get categoryTransportation => 'यातायात';

  @override
  String get categoryInsurance => 'बीमा';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryTravel => 'यात्रा';

  @override
  String get categoryGifts => 'तोहफे';

  @override
  String get categoryMiscellaneous => 'अन्य';

  @override
  String get paymentCash => 'नकद';

  @override
  String get paymentDebitCard => 'डेबिट कार्ड';

  @override
  String get paymentCreditCard => 'क्रेडिट कार्ड';

  @override
  String get paymentBankTransfer => 'बैंक ट्रांसफर';

  @override
  String get paymentDigitalWallet => 'डिजिटल वॉलेट';

  @override
  String get paymentOther => 'अन्य';

  @override
  String get lockEnterPin => 'PIN दर्ज करें';

  @override
  String get lockUnlock => 'ExpenseMate अनलॉक करें';

  @override
  String get pinSetupTitle => 'PIN सेट करें';

  @override
  String get pinCreateSubtitle =>
      'अपने डेटा को सुरक्षित रखने के लिए 4-अंकीय PIN बनाएं.';

  @override
  String get pinNew => 'नया PIN';

  @override
  String get pinConfirm => 'PIN की पुष्टि';

  @override
  String get pinSavePin => 'PIN सेव करें';

  @override
  String get pinMustBe4 => 'PIN में 4 अंक होने चाहिए';

  @override
  String get pinNoMatch => 'PIN मेल नहीं खाते';

  @override
  String get pinSet => 'PIN सेट हो गया';

  @override
  String get commonAll => 'सभी';

  @override
  String get commonAny => 'कोई भी';

  @override
  String get commonError => 'त्रुटि';

  @override
  String get commonNoData => 'अभी तक कोई डेटा नहीं';

  @override
  String get actionClear => 'साफ़';

  @override
  String get actionApply => 'लागू';

  @override
  String get actionAttach => 'जोड़ें';

  @override
  String get expensesFavorites => 'पसंदीदा';

  @override
  String get expensesScanTooltip => 'रसीद स्कैन';

  @override
  String get expensesFilterDateRange => 'तारीख की सीमा';

  @override
  String get moreLockNow => 'अभी लॉक करें';

  @override
  String get groceryDetailFallbackTitle => 'सूची';

  @override
  String get backupExportDatabase => 'डेटाबेस एक्सपोर्ट';

  @override
  String get backupExportDatabaseBody =>
      'आपके SQLite डेटाबेस की कॉपी सेव करें और साझा करें.';

  @override
  String get backupExportShare => 'एक्सपोर्ट और साझा';

  @override
  String get backupRestoreDatabase => 'डेटाबेस रिस्टोर';

  @override
  String get backupRestoreDatabaseBody =>
      'मौजूदा डेटा को बैकअप फ़ाइल से बदलें.';

  @override
  String get backupRestore => 'रिस्टोर';

  @override
  String get backupExportCsvTitle => 'खर्च को CSV में एक्सपोर्ट करें';

  @override
  String get backupExportCsvBody => 'स्प्रेडशीट या मैनुअल विश्लेषण के लिए.';

  @override
  String get backupExportExcelTitle => 'खर्च को Excel में एक्सपोर्ट';

  @override
  String get backupExportExcelBody => 'आपके सभी खर्चों वाली XLSX फ़ाइल.';

  @override
  String get backupExportPdfTitle => 'खर्च को PDF में एक्सपोर्ट';

  @override
  String get backupExportPdfBody => 'आपके खर्चों की PDF रिपोर्ट.';

  @override
  String get backupExportCsvAction => 'CSV निर्यात करें';

  @override
  String get backupExportExcelAction => 'Excel निर्यात करें';

  @override
  String get backupExportPdfAction => 'PDF निर्यात करें';

  @override
  String backupPdfPreparedFor(String name) {
    return '$name के लिए तैयार';
  }

  @override
  String get backupRestoreSuccessTitle => 'पुनर्स्थापना पूरी हुई';

  @override
  String get backupRestoreSuccessBody =>
      'पुनर्स्थापित डेटा लोड करने के लिए ExpenseMate को बंद करना होगा. होम स्क्रीन से फिर से खोलें.';

  @override
  String get backupRestoreCloseApp => 'ऐप बंद करें';

  @override
  String get backupRestoreInvalidFile =>
      'यह फ़ाइल एक मान्य ExpenseMate बैकअप नहीं है.';

  @override
  String get backupRestoreCancelled => 'पुनर्स्थापना रद्द की गई.';

  @override
  String get backupRestoreError =>
      'पुनर्स्थापना विफल. आपका मौजूदा डेटा सुरक्षित है.';

  @override
  String get backupRestoreConfirmTitle => 'बैकअप रिस्टोर करें?';

  @override
  String get backupRestoreConfirmBody =>
      'यह आपके मौजूदा डेटा को बदल देगा. आपको ऐप पुनः चालू करना होगा.';

  @override
  String get searchHint => 'खर्च, सूचियां, नोट्स खोजें…';

  @override
  String get searchTitleFallback => 'सब कुछ खोजें';

  @override
  String get searchSubtitleFallback =>
      'खर्च, श्रेणियां, खरीदारी सूचियां और नोट्स खोजें.';

  @override
  String get searchNoExpenses => 'कोई मेल खाता खर्च नहीं';

  @override
  String get searchNoLists => 'कोई मेल खाती सूची नहीं';

  @override
  String get searchNoCategories => 'कोई मेल खाती श्रेणी नहीं';

  @override
  String get searchShoppingLists => 'खरीदारी सूचियां';

  @override
  String get searchCategories => 'श्रेणियां';

  @override
  String get moreCalendarTitle => 'कैलेंडर';

  @override
  String get moreCalendarSubtitle => 'दिन के अनुसार खर्च देखें';

  @override
  String get moreReportsTitle => 'रिपोर्ट';

  @override
  String get moreReportsSubtitle => 'चार्ट और निर्यात';

  @override
  String get moreRecurringTitle => 'आवर्ती व्यय';

  @override
  String get moreRecurringSubtitle => 'किराया, सदस्यता और अधिक स्वतः लॉग करें';

  @override
  String get moreSearchTitle => 'खोजें';

  @override
  String get moreSearchSubtitle => 'कुछ भी खोजें';

  @override
  String get moreBackupTitle => 'बैकअप और पुनर्स्थापना';

  @override
  String get moreBackupSubtitle => 'स्थानीय बैकअप';

  @override
  String get moreSettingsTitle => 'सेटिंग्स';

  @override
  String get moreSettingsSubtitle => 'अपना ऐप कस्टमाइज़ करें';

  @override
  String get moreOnboardingTitle => 'परिचय';

  @override
  String get moreOnboardingSubtitle => 'परिचय फिर से देखें';

  @override
  String get filterThisMonth => 'इस महीने';

  @override
  String get filterThisYear => 'इस साल';

  @override
  String get filterAllTime => 'सर्वकाल';

  @override
  String get filterCustom => 'कस्टम';

  @override
  String get dashboardOverspendingTitle => 'इस महीने बजट से अधिक';

  @override
  String dashboardOverspendingBy(String amount) {
    return '$amount अधिक';
  }

  @override
  String get dashboardOverspendingViewBudget => 'बजट देखें';

  @override
  String dashboardOverspendingMore(int count) {
    return '+$count और';
  }

  @override
  String get lockUnlockApp => 'ExpenseMate अनलॉक करें';

  @override
  String get backupExportTitle => 'बैकअप और निर्यात';

  @override
  String get calendarUpcomingBills => 'आगामी बिल';

  @override
  String get calendarTransactionsHeader => 'लेनदेन';

  @override
  String get calendarAutoLog => 'स्वतः लॉग';

  @override
  String settingsSampleLabel(String value) {
    return 'उदाहरण: $value';
  }

  @override
  String get weekdaySunday => 'रविवार';

  @override
  String get weekdayMonday => 'सोमवार';

  @override
  String get paywallTitleTrial => 'ExpenseMate अनलॉक करें';

  @override
  String get paywallTitleExpired => 'आपका मुफ़्त ट्रायल समाप्त हो गया';

  @override
  String paywallSubtitleTrial(int days) {
    return 'आपके मुफ़्त ट्रायल में $days दिन बचे हैं. एक बार के भुगतान से हमेशा के लिए अनलॉक करें.';
  }

  @override
  String get paywallSubtitleExpired =>
      'अपने पैसे को ट्रैक करते रहें — एक बार का भुगतान, कोई सदस्यता नहीं.';

  @override
  String get paywallFeatureOffline => 'पूरी तरह ऑफ़लाइन काम करता है';

  @override
  String get paywallFeatureScanner => 'स्मार्ट रसीद स्कैनर';

  @override
  String get paywallFeatureReports => 'विस्तृत रिपोर्ट और चार्ट';

  @override
  String get paywallFeatureBudgets => 'बजट और रिमाइंडर';

  @override
  String get paywallFeaturePrivacy => 'PIN और बायोमेट्रिक लॉक';

  @override
  String get paywallFeatureLanguages => '6 भाषाएँ';

  @override
  String paywallBuyButton(String price) {
    return 'हमेशा के लिए अनलॉक · $price';
  }

  @override
  String get paywallRestore => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get paywallFinePrint =>
      'एक बार का भुगतान. कोई सदस्यता नहीं. कोई ऑटो-नवीनीकरण नहीं.';

  @override
  String get paywallErrorGeneric =>
      'खरीदारी शुरू नहीं हो सकी. पुनः प्रयास करें.';

  @override
  String get paywallProductUnavailable =>
      'स्टोर अभी उपलब्ध नहीं है. अपना कनेक्शन जाँचें और पुनः प्रयास करें.';

  @override
  String get paywallRestoreNone => 'इस खाते पर कोई पिछली खरीदारी नहीं मिली.';

  @override
  String get paywallPending =>
      'आपकी खरीदारी संसाधित हो रही है. पुष्टि होते ही आपको पहुँच मिल जाएगी.';

  @override
  String get paywallRetry => 'फिर से कोशिश करें';
}
