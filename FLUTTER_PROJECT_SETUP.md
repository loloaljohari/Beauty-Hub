# 🎨 Beauty Hub - Flutter Authentication App  
## Project Setup Instructions

**Version**: 1.0.0  
**Last Updated**: 2026-06-15  
**Architecture**: Clean MVC + BLoC  
**Responsive Design**: Yes (Mobile, Tablet, Desktop)

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Project Structure](#project-structure)
3. [Dependencies](#dependencies)
4. [Asset Setup](#asset-setup)
5. [Font Configuration](#font-configuration)
6. [Android Configuration](#android-configuration)
7. [iOS Configuration](#ios-configuration)
8. [Running the App](#running-the-app)
9. [Build Instructions](#build-instructions)
10. [Project Features](#project-features)
11. [File Structure Reference](#file-structure-reference)
12. [API Integration Guide](#api-integration-guide)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK: 3.16.0 or higher
- Dart SDK: 3.5.4 or higher
- Android Studio / Xcode (for emulator)
- VS Code or Android Studio with Flutter extensions

### Initial Setup

```bash
# 1. Clone/Navigate to project
cd beauty_hub

# 2. Get dependencies
flutter pub get

# 3. Run the app (debug mode)
flutter run

# 4. Run on specific device
flutter run -d chrome          # Web
flutter run -d emulator-5554   # Android Emulator
flutter run -d iPhone          # iOS Simulator
```

---

## 📁 Project Structure

```
beauty_hub/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart        # App-wide constants
│   │   ├── extensions/
│   │   │   └── build_context_extension.dart  # Responsive helpers
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Color palette
│   │   │   ├── app_text_styles.dart      # Typography
│   │   │   └── app_theme.dart            # Theme configuration
│   │   └── utils/
│   │       └── validators.dart           # Input validation
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   └── auth_local_datasource.dart    # Static data source
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── auth_request_model.dart
│   │   │   └── auth_response_model.dart
│   │   └── repositories/
│   │       ├── auth_repository.dart          # Interface
│   │       └── auth_repository_impl.dart     # Implementation
│   │
│   ├── presentation/
│   │   ├── blocs/
│   │   │   ├── login/
│   │   │   │   ├── login_bloc.dart
│   │   │   │   ├── login_event.dart
│   │   │   │   └── login_state.dart
│   │   │   ├── register/
│   │   │   │   ├── register_bloc.dart
│   │   │   │   ├── register_event.dart
│   │   │   │   └── register_state.dart
│   │   │   └── forgot_password/
│   │   │       ├── forgot_password_bloc.dart
│   │   │       ├── forgot_password_event.dart
│   │   │       └── forgot_password_state.dart
│   │   ├── pages/
│   │   │   ├── login/
│   │   │   │   └── login_page.dart
│   │   │   ├── register/
│   │   │   │   └── register_page.dart
│   │   │   └── forgot_password/
│   │   │       └── forgot_password_page.dart
│   │   └── widgets/
│   │       ├── auth_text_field.dart      # Reusable input field
│   │       ├── auth_button.dart          # Reusable button
│   │       ├── auth_form_header.dart     # Form header
│   │       └── responsive_spacer.dart    # Responsive spacing
│   │
│   ├── routes/
│   │   └── app_router.dart               # Navigation routes
│   │
│   └── main.dart                         # App entry point
│
├── assets/
│   ├── images/                           # App images
│   ├── icons/                            # PNG/SVG icons
│   │   ├── ic_email.svg
│   │   ├── ic_password.svg
│   │   ├── ic_eye.svg
│   │   └── ic_apple.svg
│   └── fonts/
│       ├── SFProText-Regular.ttf
│       ├── SFProText-Medium.ttf
│       ├── SFProText-Bold.ttf
│       ├── SFProDisplay-Regular.ttf
│       ├── SFProDisplay-Bold.ttf
│       └── Benne-Regular.ttf
│
├── pubspec.yaml                          # Dependencies
└── README.md
```

---

## 📦 Dependencies

All dependencies are configured in `pubspec.yaml`:

### Main Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.0      # BLoC pattern
  equatable: ^2.0.0         # Value equality

  # Navigation
  go_router: ^14.0.0        # Route management

  # Utilities
  intl: ^0.19.0             # Localization
  flutter_svg: ^2.0.0       # SVG rendering
  cached_network_image: ^3.3.0  # Image caching

  # UI
  cupertino_icons: ^1.0.8   # iOS icons
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^4.0.0     # Linting rules
  bloc_test: ^9.0.0         # BLoC testing
  mocktail: ^1.0.0          # Mocking library
```

### Installation

```bash
# Install all dependencies
flutter pub get

# Upgrade dependencies to latest versions
flutter pub upgrade

# Get specific packages
flutter pub add flutter_bloc
```

---

## 🎨 Asset Setup

### Create Asset Directories

```bash
mkdir -p assets/images
mkdir -p assets/icons/svg
mkdir -p assets/fonts
```

### Required Image Assets

Extract from Figma and place in `assets/images/`:
- `logo.png` - Beauty Hub logo (400x400px minimum)
- `bg_decorative_1.png` - Background decoration
- `bg_decorative_2.png` - Background decoration

### Required SVG/Icon Assets

Place in `assets/icons/`:
- `ic_email.svg` - Email icon
- `ic_password.svg` - Password icon
- `ic_eye.svg` - Eye icon (show/hide password)
- `ic_eye_off.svg` - Eye off icon
- `ic_google.svg` - Google logo
- `ic_apple.svg` - Apple logo
- `ic_facebook.svg` - Facebook logo

### Figma Export Settings

For images:
- Format: PNG
- Resolution: 2x (1024x1024 recommended)
- Scale: 1x, 2x, 3x variants

For SVG icons:
- Format: SVG
- Scale: 1x only (vectors scale automatically)

### Using Assets in Code

```dart
// Images
Image.asset('assets/images/logo.png')

// SVG Icons
import 'package:flutter_svg/flutter_svg.dart';
SvgPicture.asset('assets/icons/ic_email.svg')
```

---

## 🔤 Font Configuration

### Download Fonts

The following fonts are already configured in `pubspec.yaml`:

1. **SF Pro Text** (Apple System Font)
   - Weights: 400 (Regular), 500 (Medium), 700 (Bold)
   - Usage: Body text, labels, buttons

2. **SF Pro Display** (Apple System Font)
   - Weights: 400 (Regular), 700 (Bold)
   - Usage: Headings, titles

3. **Benne** (Decorative Font)
   - Weights: 400 (Regular)
   - Usage: Brand/logo text

### Font Files Location

Place font files in `assets/fonts/`:

```
assets/fonts/
├── SFProText-Regular.ttf
├── SFProText-Medium.ttf
├── SFProText-Bold.ttf
├── SFProDisplay-Regular.ttf
├── SFProDisplay-Bold.ttf
└── Benne-Regular.ttf
```

### Font Download Resources

- **SF Pro**: Available on [Apple's Developer Website](https://developer.apple.com/fonts/)
- **Benne**: Available on [Google Fonts](https://fonts.google.com)

### Using Fonts in Code

```dart
Text(
  'Welcome',
  style: TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 32,
    fontWeight: FontWeight.bold,
  ),
)
```

### Font Fallback

If fonts are missing, the app defaults to system fonts:

```dart
// In app_text_styles.dart
static const TextStyle heading1 = TextStyle(
  fontFamily: 'SF Pro Display',  // Primary
  fontSize: 32,
  fontWeight: FontWeight.bold,
  // Fallback to system fonts if SF Pro not found
);
```

---

## 🤖 Android Configuration

### Minimum Configuration

```yaml
# pubspec.yaml
environment:
  sdk: ^3.5.4
```

### build.gradle Settings

**File**: `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34  // Target API

    defaultConfig {
        minSdkVersion 21       // Minimum API
        targetSdkVersion 34    // Target API
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            proguardFiles getDefaultProguardFile(
                'proguard-android-optimize.txt'
            ),
            'proguard-rules.pro'
        }
    }
}
```

### AndroidManifest.xml Permissions

**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet Permission -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- App Configuration -->
    <application
        android:label="Beauty Hub"
        android:icon="@mipmap/ic_launcher"
        android:debuggable="false">

        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme">

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Customize Notification Icons -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
    </application>
</manifest>
```

### Run on Android

```bash
# Debug
flutter run

# Release
flutter build apk --release

# Install APK
adb install build/app/outputs/apk/release/app-release.apk

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## 🍎 iOS Configuration

### Minimum Configuration

**File**: `ios/Podfile`

```ruby
platform :ios, '12.0'  # Minimum iOS version

# Development and build dependencies
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

### Info.plist Configuration

**File**: `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Display Name -->
    <key>CFBundleDisplayName</key>
    <string>Beauty Hub</string>

    <!-- App Bundle Identifier -->
    <key>CFBundleIdentifier</key>
    <string>com.beautyhub.app</string>

    <!-- Min iOS Version -->
    <key>MinimumOSVersion</key>
    <string>12.0</string>

    <!-- Permissions -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Beauty Hub needs access to your photos</string>

    <key>NSCameraUsageDescription</key>
    <string>Beauty Hub needs access to your camera</string>

    <!-- Navigation -->
    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <!-- Orientation Support -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

### Run on iOS

```bash
# Install pods
cd ios && pod install && cd ..

# Debug
flutter run

# Release
flutter build ios --release

# Create IPA
flutter build ipa --release

# Run tests
flutter test

# Check deployment target
pod install --repo-update
```

---

## 🏃 Running the App

### Run in Debug Mode

```bash
# Default (auto-detects device)
flutter run

# Specific device
flutter run -d <device_id>

# List available devices
flutter devices

# With verbose output
flutter run -v

# With specific flavor (if configured)
flutter run --flavor dev -t lib/main_dev.dart
```

### Run in Release Mode

```bash
# Release build
flutter run --release

# Profiling mode (performance testing)
flutter run --profile
```

### Hot Reload & Hot Restart

```bash
# Hot Reload (keep app state)
# In terminal: press 'r'
# Rebuilds only changed code

# Hot Restart (clear app state)
# In terminal: press 'R'
# Restarts entire app

# Full Rebuild
flutter clean && flutter pub get && flutter run
```

### Run on Web

```bash
# Enable web support (if not already)
flutter config --enable-web

# Run on web
flutter run -d chrome

# Build web
flutter build web --release
```

---

## 🏗️ Build Instructions

### Build APK (Android)

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# Split APK by architecture
flutter build apk --split-per-abi

# Output location
# build/app/outputs/apk/release/app-release.apk
```

### Build IPA (iOS)

```bash
# Debug IPA
flutter build ios

# Release IPA
flutter build ipa --release

# Output location
# build/ios/ipa/
```

### Build Web

```bash
# Development
flutter build web

# Production (optimized)
flutter build web --release --dart2js-optimization O4

# Output location
# build/web/
```

### Build Windows/macOS

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

---

## ✨ Project Features

### Implemented Features

- ✅ **Login Screen**
  - Email/password authentication
  - Form validation
  - Show/hide password toggle
  - Guest login option
  - Forgot password link
  - Register link

- ✅ **Register Screen**
  - Email input
  - Password validation (strength check)
  - Confirm password matching
  - Terms acceptance checkbox
  - Login link

- ✅ **Forgot Password Screen**
  - Email-based password reset
  - OTP verification
  - Resend OTP functionality
  - Back to login navigation

- ✅ **Responsive Design**
  - Mobile (< 600px)
  - Tablet (600px - 900px)
  - Desktop (> 900px)
  - Portrait & Landscape support
  - SafeArea handling
  - Keyboard avoidance

- ✅ **Architecture**
  - Clean MVC pattern
  - BLoC state management
  - Repository pattern
  - Separation of concerns
  - Reusable widgets
  - Centralized theming

### Ready for Future Integration

- 🔄 **API Integration** - Replace `auth_local_datasource.dart` with HTTP client
- 🔐 **Token Management** - Add JWT token handling
- 📲 **Push Notifications** - Firebase Cloud Messaging ready
- 🌍 **Localization** - i18n setup with `intl` package
- 🎨 **Dark Mode** - Theme system supports multiple themes
- 🧪 **Unit Testing** - BLoC testing infrastructure in place

---

## 📄 File Structure Reference

### Core Module Files

| File | Purpose |
|------|---------|
| `app_constants.dart` | App-wide constants & config |
| `app_colors.dart` | Color palette definitions |
| `app_text_styles.dart` | Typography specifications |
| `app_theme.dart` | Material theme configuration |
| `build_context_extension.dart` | Responsive helper methods |
| `validators.dart` | Input validation utilities |

### Data Module Files

| File | Purpose |
|------|---------|
| `auth_local_datasource.dart` | Static data source (mock API) |
| `auth_repository.dart` | Repository interface |
| `auth_repository_impl.dart` | Repository implementation |
| `*_model.dart` | Data models (User, Auth requests/responses) |

### Presentation Module Files

| File | Purpose |
|------|---------|
| `*_bloc.dart` | Business logic (state management) |
| `*_event.dart` | BLoC events (user actions) |
| `*_state.dart` | BLoC states (UI states) |
| `*_page.dart` | Screen/page widgets |
| `auth_*.dart` | Reusable form widgets |
| `responsive_*.dart` | Responsive layout helpers |

---

## 🔌 API Integration Guide

### Step 1: Create HTTP Data Source

```dart
// lib/data/datasources/auth_remote_datasource.dart

import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl;
  final http.Client httpClient;

  AuthRemoteDataSource({
    required this.baseUrl,
    required this.httpClient,
  });

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed');
    }
  }
}
```

### Step 2: Update Repository

```dart
// lib/data/repositories/auth_repository_impl.dart

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource? remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    if (remoteDataSource != null) {
      // Use API
      return await remoteDataSource!.login(request);
    } else {
      // Use mock data
      return await localDataSource.login(request);
    }
  }
}
```

### Step 3: Add HTTP Package

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
```

### Step 4: Update main.dart

```dart
// lib/main.dart

void main() {
  final authRemoteDataSource = AuthRemoteDataSource(
    baseUrl: 'https://api.beautyhub.com/v1',
    httpClient: http.Client(),
  );

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: AuthLocalDataSource(),
  );

  runApp(BeautyHubApp(
    authRepository: authRepository,
  ));
}
```

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/presentation/blocs/login_bloc_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Generate Coverage Report

```bash
# Install lcov (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📊 Code Quality

### Run Linter

```bash
flutter analyze
```

### Format Code

```bash
# Check formatting
dart format --line-length=80 --set-exit-if-changed lib/

# Auto-format
dart format -w lib/
```

### Get Code Metrics

```bash
dart pub global activate dart_code_metrics
dartanalyzer lib/
```

---

## 🛠️ Troubleshooting

### Dependency Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade

# Get specific version
flutter pub add flutter_bloc:^8.1.0
```

### Build Issues

```bash
# Clean build directories
flutter clean

# Remove generated files
rm -rf ios/Pods
rm ios/Podfile.lock

# Rebuild
flutter pub get
flutter run
```

### Font Not Loading

```bash
# Ensure fonts are in assets/fonts/
# Check pubspec.yaml font configuration
# Rebuild: flutter clean && flutter run
```

### Hot Reload Not Working

```bash
# Full rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-15 | Initial release with authentication screens |

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Documentation](https://bloclibrary.dev)
- [GoRouter Documentation](https://gorouter.dev)
- [Material Design](https://m3.material.io)

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review the implementation plan
3. Check Flutter documentation
4. Run `flutter doctor` for environment issues

---

**Generated**: 2026-06-15  
**Architecture**: Clean MVC + BLoC  
**Responsive**: Yes  
**Null Safety**: Enabled
