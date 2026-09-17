# IronFlow - Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying IronFlow to the Apple App Store and Google Play Store.

---

## Prerequisites

### Development Environment
- ✅ Flutter SDK 3.10.7 or higher
- ✅ Xcode 15+ (for iOS)
- ✅ Android Studio (for Android)
- ✅ Valid Apple Developer Account ($99/year)
- ✅ Valid Google Play Developer Account ($25 one-time)

### Project Requirements
- ✅ All tests passing (315+ tests)
- ✅ Zero compilation errors
- ✅ Performance benchmarks met
- ✅ Security audit completed
- ✅ Privacy policy published
- ✅ Terms of service published

---

## Phase 1: Pre-Deployment Checklist

### 1.1 Code Quality
```bash
# Run all tests
flutter test

# Check for compilation errors
flutter analyze

# Verify no warnings
flutter doctor
```

### 1.2 Version Management
Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes
- BUILD_NUMBER: Incremental build number

### 1.3 Environment Configuration
Ensure all API keys and secrets are configured:
- Firebase configuration files
- API keys in `.env` file
- Signing certificates

---

## Phase 2: iOS Deployment (Apple App Store)

### 2.1 Prepare iOS Build

#### Update iOS Configuration
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>IronFlow</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

#### Configure App Capabilities
In Xcode, enable required capabilities:
- ✅ Push Notifications
- ✅ Background Modes (Background fetch, Remote notifications)
- ✅ Sign in with Apple
- ✅ HealthKit (if using health data)

### 2.2 Build iOS Release

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build iOS release
flutter build ios --release

# Or build IPA directly
flutter build ipa --release
```

### 2.3 Code Signing

#### Automatic Signing (Recommended)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Enable "Automatically manage signing"
5. Select your team

#### Manual Signing
1. Create App ID in Apple Developer Portal
2. Create Distribution Certificate
3. Create Provisioning Profile
4. Configure in Xcode

### 2.4 Archive and Upload

#### Using Xcode
1. Open `ios/Runner.xcworkspace`
2. Select "Any iOS Device" as target
3. Product → Archive
4. Wait for archive to complete
5. Click "Distribute App"
6. Select "App Store Connect"
7. Follow the wizard

#### Using Command Line
```bash
# Build IPA
flutter build ipa --release

# Upload using Transporter app
# Or use altool (deprecated but still works)
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/*.ipa \
  --username "your@email.com" \
  --password "app-specific-password"
```

### 2.5 App Store Connect Configuration

#### Create App Listing
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in app information:
   - Platform: iOS
   - Name: IronFlow
   - Primary Language: English
   - Bundle ID: com.ironflow.app
   - SKU: IRONFLOW001

#### App Information
- **Name:** IronFlow
- **Subtitle:** Your Personal Fitness Companion
- **Category:** Health & Fitness
- **Content Rights:** Own or have rights to use

#### Pricing and Availability
- **Price:** Free (or set price)
- **Availability:** All countries
- **Pre-orders:** Optional

#### App Privacy
Configure privacy details:
- Data collection practices
- Data usage
- Data linking
- Tracking

#### Screenshots Required
- 6.7" Display (iPhone 15 Pro Max): 1290 x 2796 pixels
- 6.5" Display (iPhone 11 Pro Max): 1242 x 2688 pixels
- 5.5" Display (iPhone 8 Plus): 1242 x 2208 pixels
- iPad Pro (12.9"): 2048 x 2732 pixels

Minimum: 3 screenshots per device size

#### App Preview Video (Optional)
- Duration: 15-30 seconds
- Format: .mov, .m4v, or .mp4
- Resolution: Match screenshot sizes

### 2.6 Submit for Review

1. Select build from TestFlight
2. Fill in "What's New in This Version"
3. Add App Review Information:
   - Contact information
   - Demo account (if required)
   - Notes for reviewer
4. Click "Submit for Review"

#### Review Timeline
- Initial review: 24-48 hours
- Subsequent updates: 24 hours
- Expedited review: Available for critical fixes

---

## Phase 3: Android Deployment (Google Play Store)

### 3.1 Prepare Android Build

#### Update Android Configuration
Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.ironflow.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### Configure Signing
Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=ironflow
storeFile=<path-to-keystore>
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3.2 Generate Signing Key

```bash
# Generate keystore
keytool -genkey -v \
  -keystore ~/ironflow-release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias ironflow

# Verify keystore
keytool -list -v \
  -keystore ~/ironflow-release-key.jks \
  -alias ironflow
```

**IMPORTANT:** Backup your keystore file securely!

### 3.3 Build Android Release

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build APK (for testing)
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 3.4 Google Play Console Configuration

#### Create App
1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details:
   - App name: IronFlow
   - Default language: English (United States)
   - App or game: App
   - Free or paid: Free
   - Declarations: Accept all

#### Store Listing
- **App name:** IronFlow
- **Short description:** (80 characters max)
  "Track workouts, nutrition, and progress with AI-powered coaching"
- **Full description:** (4000 characters max)
  [See STORE_LISTING.md for full description]
- **App icon:** 512 x 512 pixels, PNG
- **Feature graphic:** 1024 x 500 pixels
- **Phone screenshots:** Minimum 2, maximum 8
  - 16:9 or 9:16 aspect ratio
  - Minimum dimension: 320px
  - Maximum dimension: 3840px
- **7-inch tablet screenshots:** Optional
- **10-inch tablet screenshots:** Optional

#### Content Rating
Complete questionnaire:
- Category: Health & Fitness
- Questions about content
- Receive rating (Everyone, Teen, Mature, etc.)

#### App Content
- **Privacy Policy:** URL required
- **Ads:** Declare if app contains ads
- **Target audience:** Age groups
- **Data safety:** Data collection and usage

#### Pricing & Distribution
- **Countries:** Select all or specific countries
- **Pricing:** Free or paid
- **Content guidelines:** Confirm compliance

### 3.5 Upload and Release

#### Internal Testing (Optional)
1. Go to "Testing" → "Internal testing"
2. Create new release
3. Upload AAB file
4. Add release notes
5. Add testers
6. Review and rollout

#### Production Release
1. Go to "Production"
2. Create new release
3. Upload AAB file
4. Add release notes in all languages
5. Review release
6. Click "Start rollout to Production"

#### Staged Rollout (Recommended)
- Start with 5% of users
- Monitor for crashes and issues
- Gradually increase to 10%, 20%, 50%, 100%

#### Review Timeline
- Initial review: 1-7 days
- Subsequent updates: 1-3 days
- Can take longer for first submission

---

## Phase 4: Post-Deployment Monitoring

### 4.1 Crash Reporting

#### Firebase Crashlytics
Already configured in the app. Monitor at:
https://console.firebase.google.com/project/ironflow/crashlytics

#### Key Metrics to Monitor
- Crash-free users percentage (target: >99%)
- Crash-free sessions percentage (target: >99.5%)
- Most common crashes
- Affected versions

### 4.2 Analytics

#### Firebase Analytics
Monitor user behavior:
- Daily active users (DAU)
- Monthly active users (MAU)
- Session duration
- Screen views
- User retention

#### Key Performance Indicators
- User retention (Day 1, Day 7, Day 30)
- Feature adoption rates
- Workout completion rate
- Meal logging frequency
- AI interaction rate

### 4.3 User Feedback

#### App Store Reviews
- Monitor daily
- Respond within 24-48 hours
- Address common issues
- Thank positive reviewers

#### Play Store Reviews
- Monitor daily
- Respond to all reviews
- Update responses as issues are fixed

#### In-App Feedback
- Monitor support email
- Track feature requests
- Prioritize bug reports

### 4.4 Performance Monitoring

#### Firebase Performance Monitoring
Track:
- App startup time
- Screen rendering time
- Network request duration
- Custom traces

#### Targets
- App startup: <2 seconds
- Screen transitions: <200ms
- API requests: <1 second
- 60 FPS maintained

---

## Phase 5: Update Strategy

### 5.1 Version Numbering
- **Patch updates (1.0.X):** Bug fixes, minor improvements
- **Minor updates (1.X.0):** New features, enhancements
- **Major updates (X.0.0):** Breaking changes, major redesigns

### 5.2 Release Cadence
- **Hotfixes:** As needed for critical bugs
- **Patch updates:** Every 1-2 weeks
- **Minor updates:** Every 4-6 weeks
- **Major updates:** Every 6-12 months

### 5.3 Update Process
1. Develop and test features
2. Update version number
3. Update changelog
4. Build release
5. Submit to stores
6. Monitor rollout
7. Respond to feedback

---

## Phase 6: Rollback Procedures

### 6.1 iOS Rollback
1. Go to App Store Connect
2. Select app
3. Go to "App Store" tab
4. Click "+" to add new version
5. Select previous build
6. Submit for review

### 6.2 Android Rollback
1. Go to Google Play Console
2. Select app
3. Go to "Production"
4. Click "Create new release"
5. Select previous bundle
6. Rollout to 100%

### 6.3 Emergency Procedures
For critical issues:
1. Immediately halt staged rollout
2. Prepare hotfix
3. Submit expedited review (iOS)
4. Fast-track release (Android)
5. Communicate with users

---

## Troubleshooting

### Common iOS Issues

#### Build Failed
```bash
# Clean and rebuild
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

#### Signing Issues
- Verify certificates in Keychain
- Check provisioning profiles
- Ensure bundle ID matches

#### Archive Upload Failed
- Check Xcode version
- Verify app-specific password
- Try Transporter app

### Common Android Issues

#### Build Failed
```bash
# Clean Gradle cache
cd android
./gradlew clean
cd ..
flutter clean
flutter build appbundle
```

#### Signing Issues
- Verify keystore path
- Check key.properties file
- Ensure passwords are correct

#### Upload Failed
- Verify AAB file size (<150MB)
- Check version code is incremented
- Ensure signing is configured

---

## Security Checklist

- ✅ API keys not hardcoded
- ✅ Secrets in environment variables
- ✅ ProGuard enabled (Android)
- ✅ Code obfuscation enabled
- ✅ SSL pinning implemented
- ✅ Secure storage for tokens
- ✅ Input validation
- ✅ SQL injection prevention
- ✅ XSS prevention

---

## Compliance Checklist

- ✅ Privacy policy published
- ✅ Terms of service published
- ✅ GDPR compliance
- ✅ CCPA compliance
- ✅ COPPA compliance (if applicable)
- ✅ Data deletion process
- ✅ User consent mechanisms
- ✅ Data export functionality

---

## Support Resources

### Apple
- [App Store Connect](https://appstoreconnect.apple.com)
- [Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Google
- [Google Play Console](https://play.google.com/console)
- [Developer Documentation](https://developer.android.com/docs)
- [Play Store Guidelines](https://play.google.com/about/developer-content-policy/)

### Flutter
- [Flutter Documentation](https://docs.flutter.dev/)
- [Deployment Guide](https://docs.flutter.dev/deployment)
- [Platform Integration](https://docs.flutter.dev/platform-integration)

---

## Conclusion

Following this deployment guide will ensure a smooth release of IronFlow to both app stores. Remember to:

1. Test thoroughly before submission
2. Monitor closely after release
3. Respond quickly to user feedback
4. Iterate based on analytics
5. Maintain regular update schedule

Good luck with your deployment! 🚀
