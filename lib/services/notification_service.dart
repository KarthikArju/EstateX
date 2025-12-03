import 'package:flutter/foundation.dart';

// Conditional imports for Firebase (only on mobile)
// On web, these imports are replaced with stub classes
import 'package:firebase_core/firebase_core.dart'
    if (dart.library.html) 'notification_service_stub.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.html) 'notification_service_stub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'notification_service_stub.dart';
import '../firebase_options.dart'
    if (dart.library.html) 'notification_service_stub.dart';

// Top-level function for background message handling (mobile only)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Handling background message: ${message.messageId}');
  }
}

// Notification service - handles FCM on mobile, stubbed on web
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  FlutterLocalNotificationsPlugin? _localNotifications;
  Function(String propertyId)? onNotificationTapped;

  Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWebNotifications();
    } else {
      await _initializeMobileNotifications();
    }
  }

  Future<void> _initializeMobileNotifications() async {
    try {
      // Initialize Firebase if not already initialized
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('Firebase initialized successfully');
      } catch (e) {
        // Firebase might already be initialized, ignore
        print('Firebase initialization: $e');
      }

      // Initialize Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User declined or has not accepted notification permission');
      }

      // Initialize local notifications for foreground messages
      await _initializeLocalNotifications();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification opened app: ${message.messageId}');
        _handleNotificationTap(message);
      });

      // Handle notification tap when app was terminated
      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from terminated state via notification');
        _handleNotificationTap(initialMessage);
      }

      // Get FCM token
      final token = await _firebaseMessaging!.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('Error initializing mobile notifications: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return; // Not needed on web

    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          onNotificationTapped?.call(details.payload!);
        }
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'property_updates',
      'Property Updates',
      description: 'Notifications for property updates',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kIsWeb) return;

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'New Update',
        body: notification.body ?? 'You have a new property update',
        propertyId: data['propertyId'] as String?,
      );
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? propertyId,
  }) async {
    if (kIsWeb) {
      // Web: Just log (no browser notifications per requirements)
      print('Web notification: $title - $body');
      if (propertyId != null && onNotificationTapped != null) {
        onNotificationTapped!(propertyId);
      }
      return;
    }

    // Mobile: Show local notification
    const androidDetails = AndroidNotificationDetails(
      'property_updates',
      'Property Updates',
      channelDescription: 'Notifications for property updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications?.show(
      propertyId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: propertyId,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kIsWeb) return;

    final propertyId = message.data['propertyId'] as String?;
    if (propertyId != null && onNotificationTapped != null) {
      onNotificationTapped!(propertyId);
    }
  }

  Future<void> _initializeWebNotifications() async {
    try {
      if (kIsWeb) {
        final permission = await _requestWebNotificationPermission();
        if (permission == 'granted') {
          print('Web notifications permission granted');
        }
      }
    } catch (e) {
      print('Error initializing web notifications: $e');
    }
  }

  Future<String> _requestWebNotificationPermission() async {
    if (kIsWeb) {
      // Web notifications are stubbed per requirements
      // In production, you could use browser Notification API here
      return 'granted';
    }
    return 'denied';
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? propertyId,
  }) async {
    if (kIsWeb) {
      _showLocalNotification(title: title, body: body, propertyId: propertyId);
    } else {
      await _showLocalNotification(
          title: title, body: body, propertyId: propertyId);
    }
  }
}
