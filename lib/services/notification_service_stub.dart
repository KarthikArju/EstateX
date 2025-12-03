// Stub file for web builds to avoid Firebase compilation errors
// This file is only used when building for web via conditional imports

// Stub classes to replace Firebase imports on web
class Firebase {
  static Future<void> initializeApp({dynamic options}) async {
    // Stub - does nothing on web
  }
}

class FirebaseMessaging {
  static FirebaseMessaging get instance => FirebaseMessaging();
  Future<NotificationSettings> requestPermission({
    required bool alert,
    required bool badge,
    required bool sound,
    required bool provisional,
  }) async {
    return NotificationSettings(
        authorizationStatus: AuthorizationStatus.denied);
  }

  Stream<RemoteMessage> get onMessage => const Stream.empty();
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();
  Future<RemoteMessage?> getInitialMessage() async => null;
  Future<String?> getToken() async => null;
  static void onBackgroundMessage(Function(RemoteMessage) handler) {}
}

class RemoteMessage {
  final String? messageId;
  final Notification? notification;
  final Map<String, dynamic> data;
  RemoteMessage({this.messageId, this.notification, this.data = const {}});
}

class Notification {
  final String? title;
  final String? body;
  Notification({this.title, this.body});
}

class NotificationSettings {
  final AuthorizationStatus authorizationStatus;
  NotificationSettings({required this.authorizationStatus});
}

enum AuthorizationStatus { authorized, provisional, denied }

class FlutterLocalNotificationsPlugin {
  Future<void> initialize(dynamic settings,
      {Function? onDidReceiveNotificationResponse}) async {}
  Future<void> show(int id, String title, String body, dynamic details,
      {String? payload}) async {}
  T? resolvePlatformSpecificImplementation<T>() => null;
}

class AndroidInitializationSettings {
  final String icon;
  const AndroidInitializationSettings(this.icon);
}

class DarwinInitializationSettings {
  final bool requestAlertPermission;
  final bool requestBadgePermission;
  final bool requestSoundPermission;
  const DarwinInitializationSettings({
    required this.requestAlertPermission,
    required this.requestBadgePermission,
    required this.requestSoundPermission,
  });
}

class InitializationSettings {
  final dynamic android;
  final dynamic iOS;
  const InitializationSettings({required this.android, required this.iOS});
}

class AndroidNotificationChannel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final bool playSound;
  const AndroidNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
    required this.playSound,
  });
}

enum Importance { high, low }

class AndroidNotificationDetails {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final Importance importance;
  final Priority priority;
  final bool showWhen;
  final bool playSound;
  const AndroidNotificationDetails({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.importance,
    required this.priority,
    required this.showWhen,
    required this.playSound,
  });
}

enum Priority { high, low }

class DarwinNotificationDetails {
  final bool presentAlert;
  final bool presentBadge;
  final bool presentSound;
  const DarwinNotificationDetails({
    required this.presentAlert,
    required this.presentBadge,
    required this.presentSound,
  });
}

class NotificationDetails {
  final dynamic android;
  final dynamic iOS;
  const NotificationDetails({required this.android, required this.iOS});
}

class AndroidFlutterLocalNotificationsPlugin {}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: '',
    );
  }
}

class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
  });
}
