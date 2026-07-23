# Live Preview APK

`expensemate-preview.apk` is the **compiled, ready-to-install** version of ExpenseMate. Use it to test the app on a real Android phone in seconds, without waiting for a Flutter build.

## Install (Android)

1. Copy `expensemate-preview.apk` to your phone (AirDrop, email, USB, Google Drive — anything).
2. On the phone, open the file.
3. If Android asks: **Settings → Install unknown apps → Allow for this source**.
4. Tap **Install**.
5. Open **ExpenseMate**.

## What you'll see

This build has the `DEMO_MODE` flag on, so it:

- **Skips the onboarding** and lands directly on a fully-populated dashboard.
- Shows a small **"Live Demo — sample data"** banner at the top of the dashboard.
- Ships with **6 months of realistic sample transactions**, budget plan, savings goal, 2 shopping lists (one in-progress, one completed), 3 recurring rules (Netflix, Rent, State Farm insurance), and a real month total.

Perfect for showing to your own clients before you customize.

## Build your own APK (production, no demo flag)

The bundled APK is a demo build. To build the **clean** production APK (real onboarding, no banner, empty first-launch state), run:

```bash
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Build a demo APK yourself

To rebuild the same demo APK bundled here:

```bash
flutter build apk --release --no-tree-shake-icons --dart-define=DEMO_MODE=true
```

The `DEMO_MODE=true` flag activates the seeded data path, skips onboarding, and shows the demo banner.

## iOS

To install on iOS, open `ios/Runner.xcworkspace` in Xcode, connect your device, and hit Run. Or:

```bash
flutter build ios --release --no-tree-shake-icons
```

Then archive via Xcode → distribute.
