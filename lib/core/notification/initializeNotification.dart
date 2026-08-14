import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> initializeNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // طلب صلاحية الإشعارات
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print(
    'Notification permission: ${settings.authorizationStatus}',
  );

  // الحصول على FCM Token
  final token = await messaging.getToken();

  print('FCM TOKEN: $token');

  // استقبال الإشعار عندما يكون التطبيق مفتوحًا
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('========== NOTIFICATION RECEIVED ==========');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    print('============================================');
  });

  // عندما يضغط المستخدم على الإشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification opened');
    print('Data: ${message.data}');
  });
}