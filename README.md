# EstateX - Property Listing App

Cross-platform Flutter app for property listings with filtering, camera integration, and analytics.

## Features

## Features

- Property listings with infinite scroll
- Filter by location, price, status, and tags
- Property details with images and agent info
- Camera/webcam image capture and upload
- Analytics tracking (views, time spent, clicks)
- Push notifications (FCM on mobile)
- Light/dark theme toggle
- Responsive design for all screen sizes

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── property.dart
│   └── property_response.dart
├── services/                 # Business logic services
│   ├── api_service.dart
│   ├── analytics_service.dart
│   ├── image_service.dart
│   └── notification_service.dart
├── providers/                # State management
│   ├── property_provider.dart
│   └── theme_provider.dart
├── screens/                  # UI screens
│   ├── property_list_screen.dart
│   └── property_detail_screen.dart
└── widgets/                 # Reusable widgets
    ├── property_card.dart
    ├── filter_sheet.dart
    └── image_picker_bottom_sheet.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.5.4 or higher)
- Dart SDK (3.5.4 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase project (for push notifications)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd estatex
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup (Optional)**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - The app will work without Firebase, but push notifications won't function

4. **Run the application**
   ```bash
   # For mobile
   flutter run

   # For web
   flutter run -d chrome

   # For Android APK
   flutter build apk --release
   ```

## API Integration

The application connects to the property listing API at:
```
http://147.182.207.192:8003/properties
```

### API Endpoints

**Get Properties**
```
GET /properties?page=1&page_size=20
```

**Filter by Price Range**
```
GET /properties?min_price=100000&max_price=200000
```

**Filter by Location**
```
GET /properties?location=Cityville
```

**Filter by Status**
```
GET /properties?status=Available
```

**Filter by Tags**
```
GET /properties?tags=New&tags=Furnished
```

### API Response Structure

```json
{
  "error": null,
  "filtersApplied": {
    "location": null,
    "max_price": null,
    "min_price": null,
    "status": null,
    "tags": []
  },
  "loading": false,
  "page": 1,
  "pageSize": 20,
  "properties": [...],
  "totalPages": 250,
  "totalProperties": 5000
}
```

## Features Implementation

### 1. API Integration with Large Dataset
- Implemented efficient pagination with infinite scroll
- Optimized query parameters to minimize payload size
- Error handling and retry mechanisms
- Loading states and empty state handling

### 2. Advanced Filtering & Search
- Multi-parameter filtering (price, location, status, tags)
- Real-time filter application
- Active filter indicators with quick removal
- Optimized API queries

### 3. Camera / Webcam Integration
- Mobile: Native camera using `image_picker` and `camera` packages
- Web: Webcam access using `image_picker` with camera source
- Image preview and upload functionality
- Property association with uploaded images

### 4. Push Notification Integration
- Firebase Cloud Messaging for Android/iOS
- Browser notification APIs for web
- Automatic navigation to property details on notification tap
- Notification permission handling

### 5. Page Analytics Tracking
- Property view tracking
- Time spent on each property
- Click/interaction tracking
- Local storage using SharedPreferences
- Analytics data exportable via console logs

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.2.0
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  cached_network_image: ^3.3.1
  intl: ^0.19.0
  flutter_staggered_grid_view: ^0.7.0
  shimmer: ^3.0.0
```

## Build Instructions

### Android APK
```bash
flutter build apk --release
```
The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Web Build
```bash
flutter build web --release
```
The web build will be in: `build/web/`

To host the web build:
1. Upload the contents of `build/web/` to your web server
2. Ensure your server supports SPA routing (configure redirects)

## Platform-Specific Notes

### Android
- Minimum SDK: 21
- Camera permissions are automatically requested
- Firebase configuration required for push notifications

### iOS
- Minimum iOS version: 12.0
- Camera and photo library permissions in Info.plist
- Firebase configuration required for push notifications

### Web
- Webcam access requires HTTPS or localhost
- Browser notification permissions must be granted
- Responsive design optimized for various screen sizes

## Performance Optimizations

- **Image Caching**: Using `cached_network_image` for efficient image loading
- **Lazy Loading**: Properties loaded on-demand with pagination
- **State Management**: Provider pattern for efficient state updates
- **Query Optimization**: Minimal API payloads with targeted filtering

## Future Enhancements

- Map view for property locations
- Favorites/bookmarking functionality
- Advanced search with saved searches
- Property comparison feature
- Social sharing capabilities
- Offline mode with local caching

## Troubleshooting

### Common Issues

**API Connection Errors**
- Verify the API endpoint is accessible
- Check network connectivity
- Ensure CORS is properly configured for web

**Camera Not Working**
- Check device permissions
- For web, ensure HTTPS or localhost
- Verify camera package installation

**Firebase Notifications Not Working**
- Verify Firebase configuration files
- Check notification permissions
- Ensure Firebase project is properly set up

## Architecture

- Provider pattern for state management
- Service layer for API and business logic
- Conditional imports for platform-specific code
- CORS proxy for web API calls

## License

This project is created for interview assessment purposes.

## Contact

For questions or issues, please refer to the project documentation or contact the development team.
