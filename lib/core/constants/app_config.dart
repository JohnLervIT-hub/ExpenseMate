/// Build-time configuration flags controlled by `--dart-define`.
///
/// Build normal APK:
///   flutter build apk --release --no-tree-shake-icons
///
/// Build Appetize demo APK (skips onboarding, shows Demo chip):
///   flutter build apk --release --no-tree-shake-icons --dart-define=DEMO_MODE=true
class AppConfig {
  /// When true, the app skips the first-run onboarding, always lands on the
  /// dashboard and displays a "Live Demo" chip. Used for Appetize.io preview.
  static const bool demoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  /// Optional CodeCanyon buy URL surfaced on the demo chip. Set with
  /// --dart-define=DEMO_URL=https://codecanyon.net/item/....
  static const String demoBuyUrl = String.fromEnvironment('DEMO_URL', defaultValue: '');
}
