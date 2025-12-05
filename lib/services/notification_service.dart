import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  /// 1. Initialize Local Channels (Android)
  static Future<void> setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "joybox_default_channel", // Must match Manifest
      "JoyBox Notifications",
      description: "General notifications for JoyBox",
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// 2. Request User Permission
  static Future<bool> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// 3. Get FCM Token
  static Future<String?> getFcmToken() async {
    String? token = await _messaging.getToken();
    print("🔥 FCM TOKEN: $token");
    return token;
  }

  /// 4. Setup Foreground Listeners
  static void setupForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "joybox_default_channel",
              "JoyBox Notifications",
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher', // Ensure you have an icon
            ),
          ),
        );
      }
    });
  }
}
