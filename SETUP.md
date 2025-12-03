# Quick Setup Guide

## Prerequisites
- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher

## Installation Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   # For mobile (Android/iOS)
   flutter run

   # For web
   flutter run -d chrome
   ```

3. **Build for Production**

   **Android APK:**
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

   **Web:**
   ```bash
   flutter build web --release
   ```
   Output: `build/web/`

## Firebase Setup (Optional)

For push notifications to work:

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app:
   - Download `google-services.json`
   - Place in `android/app/`
3. Add iOS app:
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/`
4. The app will work without Firebase, but notifications won't function

## Testing Features

### API Integration
- The app connects to: `http://147.182.207.192:8003/properties`
- Test pagination by scrolling down
- Test filters using the filter button in the app bar

### Camera/Image Upload
- Tap the camera icon on property detail screen
- On mobile: Uses device camera
- On web: Uses webcam (requires HTTPS or localhost)

### Analytics
- View analytics in console logs
- Tracks: property views, time spent, click events

### Notifications
- Mobile: Requires Firebase setup
- Web: Browser will prompt for notification permission

## Troubleshooting

**API Connection Issues:**
- Verify API endpoint is accessible
- Check network connectivity
- For web, ensure CORS is configured

**Camera Not Working:**
- Check device permissions
- Web requires HTTPS or localhost
- Verify camera package installation

**Build Errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version: `flutter --version`

