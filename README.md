# ExpenseMate

A fully offline personal finance and grocery tracker for Android and iOS. Built with Flutter, Material 3, SQLite and Riverpod. No accounts, no cloud, no internet required — everything lives on your device.

## Features

- **Dashboard** — monthly income, expenses, remaining budget, savings, budget progress, grocery spend, recent transactions, quick-add FAB, pie/bar/line charts.
- **Expense Tracker** — add, edit, delete, duplicate, favorite. Fields: date, amount, category, merchant, payment method, notes, receipt photo (local).
- **Categories** — 14 defaults (Groceries, Fuel, Rent, Utilities, Dining, Shopping, Entertainment, Healthcare, Transportation, Insurance, Education, Travel, Gifts, Misc.) plus user-added.
- **Grocery Manager** — multiple lists with items (name, quantity, estimated & actual price, store, purchased, notes), duplicate lists, favorite lists, auto totals, purchase history.
- **Budget Planner** — set monthly income, spending limit, savings goal, and per-category budgets. Overspend warnings and progress bars.
- **Reports** — Monthly, Yearly, Category, Income vs Expense, Savings tabs. Export to CSV, Excel, PDF (share sheet).
- **Search** — global search over expenses, merchants, categories, shopping lists and notes.
- **Settings** — light / dark / system theme, currency symbol, PIN lock, biometric unlock.
- **Backup & Restore** — export the SQLite database to a shareable file and restore from a picked file. Fully local.
- **Local Notifications** — schedule budget, shopping and monthly review reminders.
- **Security** — optional 4-digit PIN with SHA-256 hashing in secure storage, optional Face ID / Fingerprint via `local_auth`.
- **UX** — Material 3 rounded cards, smooth animations, bottom navigation, swipe-to-delete with undo, pull-to-refresh, empty states, confirmation dialogs.

## Tech stack

- Flutter 3.22+, Dart 3.4+
- SQLite (`sqflite`) with repository pattern
- Riverpod for state management (Clean architecture / MVVM)
- `go_router` for navigation with `ShellRoute` bottom nav
- `fl_chart` for charts
- `pdf` + `printing` for PDF export
- `excel`, `csv` for spreadsheets
- `flutter_local_notifications` + `timezone`
- `local_auth`, `flutter_secure_storage`, `crypto`
- `image_picker`, `file_picker`, `share_plus`, `path_provider`
- `google_fonts` (Inter)

## Project structure

```
lib/
├── app.dart                       # MaterialApp.router
├── main.dart                      # Bootstrap: init DB, notifications
├── core/
│   ├── constants/                 # app constants + default categories
│   ├── router/app_router.dart     # go_router with shell + redirects
│   ├── services/                  # notification, backup, export, auth, image
│   ├── theme/                     # AppTheme + AppColors (Material 3)
│   └── utils/                     # formatters, date utils
├── data/
│   ├── database/app_database.dart # sqflite singleton
│   ├── models/                    # Expense, Category, Income, Budget, ShoppingList, ShoppingItem, RecurringExpense
│   └── repositories/              # ExpenseRepository, CategoryRepository, IncomeRepository, BudgetRepository, ShoppingRepository, SettingsRepository
└── presentation/
    ├── providers/                 # Riverpod providers
    ├── screens/
    │   ├── dashboard/
    │   ├── expenses/
    │   ├── grocery/
    │   ├── budget/
    │   ├── reports/
    │   ├── settings/              # settings + backup
    │   ├── auth/                  # lock, pin_setup
    │   ├── search/
    │   ├── onboarding/
    │   ├── more/
    │   └── main_shell.dart        # bottom navigation host
    └── widgets/                   # charts, cards, common
```

## Prerequisites

- Flutter SDK **3.22 or newer** (`flutter --version`)
- **iOS**: Xcode 15+, CocoaPods
- **Android**: Android Studio (or command-line tools), JDK 17+, an Android SDK with API 34

## Setup

```bash
cd expensemate
flutter pub get
flutter run              # runs on the first connected device / simulator
```

The first launch creates `expensemate.db` in the app's Application Documents directory and seeds the 14 default categories.

## Build

Release Android builds go through `scripts/build_release.sh`, which enables
Dart obfuscation and writes symbols to `debug_symbols/<version>/`. R8 +
resource shrinking are on for the Android `release` build type (see
`android/app/build.gradle` and `android/app/proguard-rules.pro`).

**Android App Bundle (default)**
```bash
scripts/build_release.sh
# Output: build/app/outputs/bundle/release/app-release.aab
# Symbols: debug_symbols/<version>/
```

**Android APK**
```bash
scripts/build_release.sh apk
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Archive `debug_symbols/<version>/` alongside each released artifact — you
need it to decode obfuscated stack traces from crash reports.

**iOS**
```bash
flutter build ios --release --obfuscate --split-debug-info=debug_symbols/ios/ --no-tree-shake-icons
# Then open ios/Runner.xcworkspace in Xcode to archive
```

## Permissions

Add these to your platform manifests. (This project ships with a plain `flutter create` shell — you can regenerate `android/` and `ios/` with `flutter create .` from the project root; then add the entries below.)

### Android — `android/app/src/main/AndroidManifest.xml`
Inside `<manifest>`, above `<application>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Notes:
- `CAMERA` — receipt capture via `image_picker`.
- `USE_BIOMETRIC` — Face ID / Fingerprint unlock via `local_auth`.
- `RECEIVE_BOOT_COMPLETED` + `VIBRATE` — needed by `flutter_local_notifications` so scheduled reminders survive a reboot and can vibrate.
- `POST_NOTIFICATIONS` — required on Android 13+ (API 33) for `flutter_local_notifications` to actually fire; without it the app runs but scheduled reminders are silently dropped.
- For `local_auth`, edit `android/app/src/main/kotlin/.../MainActivity.kt` so `MainActivity` extends `FlutterFragmentActivity` (not `FlutterActivity`) — biometric prompt requires it.
- Set `minSdkVersion` to at least 21 in `android/app/build.gradle`.

### iOS — `ios/Runner/Info.plist`
Add these keys inside the top-level `<dict>`:
```xml
<key>NSCameraUsageDescription</key>
<string>To capture receipt photos</string>
<key>NSFaceIDUsageDescription</key>
<string>To authenticate with Face ID</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>To attach receipt images from your photo library</string>
```

Notes:
- `NSCameraUsageDescription` — receipt capture via `image_picker` (camera source).
- `NSFaceIDUsageDescription` — Face ID unlock via `local_auth`.
- `NSPhotoLibraryUsageDescription` — required by `image_picker` when the user picks a receipt from the photo library. Without it iOS crashes the app on first access.
- Set the iOS deployment target to 12.0+ in `ios/Podfile` (`platform :ios, '12.0'`) — `local_auth` and `flutter_local_notifications` require it.

## Architecture

- **Clean architecture** with three layers: `core`, `data`, `presentation`.
- **Repository pattern** — every table is accessed via a repository. Repositories are constructed once from the SQLite singleton and exposed as Riverpod `Provider`s.
- **MVVM** — Screens are `ConsumerWidget`s that watch state via providers; providers hold view-model logic (e.g. `dashboardSummaryProvider`).
- **Dependency Injection** — via `ProviderScope` overrides (see `main.dart`).
- **State management** — Riverpod `StateNotifier` for theme, currency, auth; `FutureProvider` for read models.

## Offline guarantees

- No network calls anywhere in the code.
- Backups and exports are written to the app's local Application Documents directory. Sharing is via the OS share sheet (opt-in per action).
- Optional PIN + biometric lock protects the app after launch when a PIN is set.

## Known limitations / follow-ups

- App icon is a placeholder — swap in via `flutter_launcher_icons` if desired.
- The native `android/` and `ios/` runner directories are not included; run `flutter create .` inside the project to generate them, then apply the permission entries above.
- Recurring expenses have a schema and repository, but the UI to manage recurrence is left as a small follow-up (add via the expense form, driven by `recurring_expenses`).
- Language picker in settings currently shows English only.

## License

MIT
