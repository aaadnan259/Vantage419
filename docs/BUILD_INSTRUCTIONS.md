# Build & Signing Instructions

## 1. Prerequisites
- Flutter SDK installed (`flutter doctor -v` to check)
- Java JDK 11+ (for Android builds)
- Android Studio (SDK Manager)
- Xcode (for iOS builds, macOS only)

## 2. Android Signing (Production)

### A. Generate Keystore
Run the following command to generate a private signing key:

```bash
# Windows
keytool -genkey -v -keystore c:\Users\aaadn\upload-keystore.jks ^
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 ^
        -alias upload
```

> **IMPORTANT**: Keep this file safe! If you lose it, you cannot update your app on the Play Store.

### B. Configure Gradle
1. Create a file named `android/key.properties`:
   ```properties
   storePassword=<password-from-step-A>
   keyPassword=<password-from-step-A>
   keyAlias=upload
   storeFile=c:/Users/aaadn/upload-keystore.jks
   ```

2. The `android/app/build.gradle.kts` is already configured to read this property file if it exists and apply the release signing config automatically.

## 3. Build Commands

### Android
**For Play Store (App Bundle):**
```bash
flutter build appbundle --release
```
*Output: `build/app/outputs/bundle/release/app-release.aab`*

**For Sideloading (APK):**
```bash
flutter build apk --release
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

### iOS (macOS Only)
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select **Product > Archive**.
3. Validate and upload to **TestFlight** via App Store Connect.

## 4. Obfuscation (Optional)
To make reverse engineering harder, build with obfuscation:
```bash
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
```
