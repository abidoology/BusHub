# 🚀 Dhaka Bus Route & Fare Finder - Complete Setup Guide

---

# 📋 Table of Contents

- Prerequisites
- Project Setup
- Firebase Configuration
- Android Configuration
- iOS Configuration
- Running the Application
- Database Initialization
- Troubleshooting
- Common Issues & Solutions

---

# 📌 Prerequisites

## Required Software

Before you begin, ensure you have the following installed:

### 📋 Table 1: Software Requirements

| Software | Version | Purpose |
|-----------|---------|---------|
| Flutter SDK | ≥ 3.0.0 | Mobile app development framework |
| Dart SDK | ≥ 2.18.0 | Programming language (included with Flutter) |
| Android Studio | Latest | Android development IDE |
| VS Code | Latest | Alternative IDE (optional) |
| Git | Latest | Version control |
| Chrome/Edge | Latest | Web testing |

---

## 💻 Hardware Requirements

### 📋 Table 2: Hardware Requirements

| Device | Specification |
|--------|---------------|
| Development Machine | Minimum: Core i3, 8GB RAM, 100GB HDD |
| Target Device | Android 5.0+ / iOS 12.0+ |

---

# 📦 Project Setup

## Step 1: Clone the Repository

```bash
# Clone the project
git clone https://github.com/abidoology/BusHub.git

# Navigate to project directory
cd bushub

# Checkout to main branch
git checkout main
```

---

## Step 2: Install Dependencies

```bash
# Get all dependencies
flutter pub get

# Verify everything is installed correctly
flutter doctor

# Check for any missing dependencies
flutter doctor -v
```

---

## Step 3: Verify Installation

```bash
# Check Flutter version
flutter --version

# Check available devices
flutter devices

# Run flutter clean (if needed)
flutter clean
```

---

# 🔥 Firebase Configuration

## Step 1: Create Firebase Project

1. Go to **Firebase Console**
2. Click **"Add project"**
3. Enter project name: **"dhaka-bus-route-fare"** (or your preferred name)
4. Disable Google Analytics (optional)
5. Click **"Create project"**

---

## Step 2: Register Application

### 📱 A. Android App Registration

1. Click **"Add app"** → Select **Android**
2. Enter package name:

```text
com.example.dhaka_bus_route_fare
```

3. Enter app nickname:

```text
Dhaka Bus App
```

4. Click **"Register app"**

---

### 📥 B. Download Configuration File

Download:

```text
google-services.json
```

Place it in:

```text
android/app/google-services.json
```

---

### 🍎 C. iOS App Registration

1. Click **"Add app"** → Select **iOS**
2. Enter bundle ID:

```text
com.example.dhakaBusRouteFare
```

Download:

```text
GoogleService-Info.plist
```

Place it in:

```text
ios/Runner/GoogleService-Info.plist
```

---

## Step 3: Enable Authentication

1. Go to **Authentication → Sign-in methods**
2. Enable **Email/Password**
3. Click **Save**

---

## Step 4: Create Admin Account

1. Go to **Authentication → Users**
2. Click **"Add user"**

Enter:

```text
Email: admin@dhaka.com

Password: admin123
```

3. Click **"Add user"**

---

## Step 5: Set up Firestore Database

1. Go to **Firestore Database → Create database**
2. Select **"Start in test mode"**
3. Choose location:

```text
asia-east1
```

(or nearest to your region)

4. Click **Enable**

---

## Step 6: Firestore Security Rules

Navigate to **Firestore Database → Rules** and add:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Public read access for buses and locations
    match /buses/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /locations/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }

  }
}
```

---

# 🤖 Android Configuration

## Step 1: Update Gradle Files

### A. Project Level build.gradle

**Path:** `android/build.gradle`

```gradle
buildscript {
    ext.kotlin_version = '2.1.21'

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.6.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

---

### B. App Level build.gradle

**Path:** `android/app/build.gradle`

```gradle
plugins {
    id "com.android.application"
    id 'com.google.gms.google-services'
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.example.dhaka_bus_route_fare"
    compileSdkVersion 35

    defaultConfig {
        applicationId "com.example.dhaka_bus_route_fare"
        minSdkVersion 21
        targetSdkVersion 35
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

---

## Step 2: Update AndroidManifest.xml

**Path:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <application
        android:label="BusHub"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:exported="true">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

        </activity>

    </application>

</manifest>
```

---

## Step 3: Network Security Config

Create:

```text
android/app/src/main/res/xml/network_security_config.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>

<network-security-config>

    <domain-config cleartextTrafficPermitted="true">

        <domain includeSubdomains="true">
            firestore.googleapis.com
        </domain>

        <domain includeSubdomains="true">
            nominatim.openstreetmap.org
        </domain>

        <domain includeSubdomains="true">
            router.project-osrm.org
        </domain>

        <domain includeSubdomains="true">
            tile.openstreetmap.org
        </domain>

    </domain-config>

    <debug-overrides>

        <trust-anchors>
            <certificates src="system"/>
            <certificates src="user"/>
        </trust-anchors>

    </debug-overrides>

</network-security-config>
```

---

# 🍏 iOS Configuration

## Step 1: Update Podfile

**Path:** `ios/Podfile`

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

---

## Step 2: Install iOS Dependencies

```bash
# Navigate to iOS directory
cd ios

# Install pods
pod install

# Return to project root
cd ..
```

---

## Step 3: Update Info.plist

**Path:** `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>
This app needs location access to show you nearby bus stops and routes.
</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>
This app needs location access to show you nearby bus stops and routes.
</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>

    <key>NSAllowsArbitraryLoadsForMedia</key>
    <true/>

    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

---

# 📄 Part 3

# ▶️ Running the Application

## 1. Get Dependencies

```bash
flutter pub get
```

---

## 2. Check Flutter Installation

```bash
flutter doctor
```

Resolve any issues shown before running the application.

---

## 3. Run on Connected Device

```bash
flutter run
```

---

## 4. Run Specific Platform

### Android

```bash
flutter run -d android
```

### Chrome (Web)

```bash
flutter run -d chrome
```

### Windows

```bash
flutter run -d windows
```

### Show Available Devices

```bash
flutter devices
```

---

## 5. Build Release APK

```bash
flutter build apk --release
```

---

## 6. Build Android App Bundle

```bash
flutter build appbundle
```

---

## 7. Build iOS

```bash
flutter build ios
```

---

# 🗄️ Database Initialization

After successful login as an administrator:

1. Open **Admin Dashboard**
2. Click **Load Sample Data**
3. Wait until initialization completes
4. Verify that the following Firestore collections are created:

```
buses
locations
```

The application is now ready for use.

---

# 🛠️ Troubleshooting

## Flutter Doctor Issues

Run:

```bash
flutter doctor
```

Resolve all reported issues before continuing.

---

## Firebase Connection Failed

Verify:

- Firebase project is correctly created
- `google-services.json` exists
- `GoogleService-Info.plist` exists
- `firebase_options.dart` is generated correctly

---

## Pub Get Failed

Run:

```bash
flutter clean
flutter pub get
```

---

## Build Failed

Run:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Android Gradle Problems

Update:

- Gradle
- Android Gradle Plugin
- Kotlin Version

Then rebuild the project.

---

## Firebase Authentication Not Working

Check:

- Email/Password Authentication is enabled
- Admin account exists
- Internet connection is available

---

## Firestore Permission Denied

Verify Firestore Security Rules are correctly deployed.

---

## OpenStreetMap Not Loading

Check:

- Internet connection
- Tile server accessibility
- Network permissions

---

## Location Not Working

Ensure:

- GPS is enabled
- Location permission is granted
- Device location service is active

---

# 🌍 Environment Variables

Current Firebase configuration includes:

- Firebase Project ID
- API Key
- App ID
- Messaging Sender ID

These values are generated automatically by FlutterFire CLI.

---

# ⚙️ App Configuration

Default application settings:

| Setting | Value |
|----------|-------|
| Theme | Material Design 3 |
| Primary Color | Green |
| Maps | OpenStreetMap |
| Routing | OSRM |
| Geocoding | Nominatim |
| Database | Cloud Firestore |
| Authentication | Firebase Authentication |

---

# ✅ Post-Setup Checklist

Verify the following after setup:

- [ ] Flutter installed successfully
- [ ] Firebase connected
- [ ] Dependencies installed
- [ ] Application builds successfully
- [ ] Admin login works
- [ ] Firestore collections created
- [ ] Search buses works
- [ ] Maps display correctly
- [ ] Route visualization works
- [ ] GPS location works
- [ ] CRUD operations work
- [ ] Sample data loaded successfully

---

# ⚡ Quick Commands

## Get Packages

```bash
flutter pub get
```

---

## Run Application

```bash
flutter run
```

---

## Clean Project

```bash
flutter clean
```

---

## Analyze Project

```bash
flutter analyze
```

---

## Run Tests

```bash
flutter test
```

---

## Build APK

```bash
flutter build apk
```

---

## Build App Bundle

```bash
flutter build appbundle
```

---

## Upgrade Dependencies

```bash
flutter pub upgrade
```

---

# 📞 Support

If you encounter any issues:

- Verify Flutter installation using `flutter doctor`
- Check Firebase Console configuration
- Review terminal error logs carefully
- Ensure all required packages are installed
- Confirm internet connectivity
- Verify Firestore Security Rules
- Make sure Firebase Authentication is enabled

For additional assistance, refer to:

- Flutter Documentation: https://flutter.dev/docs
- Firebase Documentation: https://firebase.google.com/docs
- OpenStreetMap: https://wiki.openstreetmap.org 
- OSRM: https://project-osrm.org/docs
- Nominatim : https://pub.dev/packages/geolocator

---

**Project:** Dhaka Bus Route & Fare Finder

**Technology Stack:** Flutter • Firebase • OpenStreetMap

**Platform:** Android & iOS

**Version:** 1.0.0
