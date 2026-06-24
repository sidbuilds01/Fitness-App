Apex Fit bundle

How to use:
1. Extract this zip into your Flutter project root or copy the files manually.
2. Replace your existing lib/main.dart with lib/main.dart from this bundle.
3. Add the other lib files:
   - splash_screen.dart
   - login_screen.dart
   - notification_service.dart
4. Merge dependencies from pubspec.yaml.
5. Replace android/app/build.gradle.kts with the included version if needed for notifications.
6. Run:
   flutter clean
   flutter pub get
   flutter run

Notes:
- This uses demo local login, not Firebase.
- Meals list is not yet permanently stored.
- Good next upgrade: Firestore or local DB for full history.
