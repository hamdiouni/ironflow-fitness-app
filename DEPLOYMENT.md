# IronFlow Deployment Guide

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (`flutter test`)
- [ ] No lint warnings (`flutter analyze`)
- [ ] Code formatted (`flutter format .`)
- [ ] No compilation errors (`flutter build apk --release`)

### Version Management
- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md` with new features
- [ ] Update `README.md` if needed
- [ ] Tag release in git

### Testing
- [ ] Integration tests passing
- [ ] Unit tests passing
- [ ] Widget tests passing
- [ ] Manual testing on multiple devices
- [ ] Performance testing completed

### Documentation
- [ ] Code comments updated
- [ ] API documentation complete
- [ ] User guide updated
- [ ] Troubleshooting guide updated

## Android Deployment

### Prerequisites
- Android SDK installed
- Keystore file created
- Google Play Developer account

### Build Steps

1. **Update version**:
```bash
# Edit pubspec.yaml
version: 1.0.0+1
```

2. **Build release APK**:
```bash
flutter build apk --release
```

3. **Build release App Bundle** (recommended for Play Store):
```bash
flutter build appbundle --release
```

4. **Sign the APK** (if not auto-signed):
```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/key.jks build/app/outputs/flutter-apk/app-release.apk \
  alias_name
```

### Google Play Store Submission

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing
3. Fill in app details:
   - App name: IronFlow
   - Category: Health & Fitness
   - Content rating: Complete questionnaire
4. Upload App Bundle:
   - Go to Release > Production
   - Upload `build/app/outputs/bundle/release/app-release.aab`
5. Add release notes
6. Review and submit

### Release Notes Template
```
Version 1.0.0

New Features:
- Workout program generation
- Progression tracking with smart suggestions
- Comprehensive analytics dashboard
- Nutrition management with meal suggestions
- Streak tracking and achievements
- Dark mode support
- Offline functionality

Bug Fixes:
- Fixed weight validation edge cases
- Improved performance with large datasets

Performance:
- Optimized list scrolling
- Faster macro calculations
- Reduced memory usage
```

## iOS Deployment

### Prerequisites
- Xcode installed
- Apple Developer account
- Provisioning profiles configured
- App ID created

### Build Steps

1. **Update version**:
```bash
# Edit pubspec.yaml
version: 1.0.0+1
```

2. **Build release iOS app**:
```bash
flutter build ios --release
```

3. **Archive in Xcode**:
```bash
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive
```

4. **Export IPA**:
```bash
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ios/ipa
```

### App Store Submission

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app or select existing
3. Fill in app information:
   - App name: IronFlow
   - Category: Health & Fitness
   - Privacy policy URL
   - Support URL
4. Add app preview and screenshots
5. Fill in app description and keywords
6. Set pricing and availability
7. Upload build:
   - Go to TestFlight > Builds
   - Upload IPA
   - Wait for processing
8. Submit for review

### App Store Review Guidelines
- Ensure privacy policy is clear
- No misleading health claims
- Proper data handling
- Appropriate content rating

## Post-Deployment

### Monitoring
- Monitor crash reports in Play Console / App Store Connect
- Track user reviews and ratings
- Monitor performance metrics
- Check for reported bugs

### Updates
- Plan regular updates (monthly recommended)
- Fix critical bugs immediately
- Add new features based on user feedback
- Maintain performance standards

### Support
- Respond to user reviews
- Provide support email: support@ironflow.app
- Maintain FAQ and troubleshooting guide
- Track and fix reported issues

## Rollback Procedure

If critical issues are found after release:

1. **Immediate Actions**:
   - Disable app if necessary
   - Post notice on support channels
   - Begin investigation

2. **Rollback Steps**:
   - Revert to previous version in Play Console / App Store Connect
   - Publish hotfix version
   - Notify users of issue and fix

3. **Post-Rollback**:
   - Investigate root cause
   - Add regression tests
   - Plan preventive measures

## Version Numbering

Follow semantic versioning: `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR**: Breaking changes or major features
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes
- **BUILD**: Internal build number

Example: `1.0.0+1` (version 1.0.0, build 1)

## Release Schedule

- **Major releases**: Quarterly (new major features)
- **Minor releases**: Monthly (new features, improvements)
- **Patch releases**: As needed (bug fixes)
- **Hotfixes**: Immediate (critical bugs)

## Continuous Integration/Deployment

### GitHub Actions Example
```yaml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v2
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Build Issues
- Clear build cache: `flutter clean`
- Update dependencies: `flutter pub upgrade`
- Check Flutter version: `flutter --version`

### Submission Issues
- Check app size (< 100MB recommended)
- Verify all required fields filled
- Check content rating questionnaire
- Review app store guidelines

### Performance Issues
- Profile app: `flutter run --profile`
- Check for memory leaks
- Optimize images and assets
- Review database queries

## Support

For deployment issues, contact:
- Email: deploy@ironflow.app
- GitHub Issues: https://github.com/ironflow/issues
