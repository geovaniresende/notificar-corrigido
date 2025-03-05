import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> sendPushNotification(
      String token, String title, String body) async {
    await _messaging.sendMessage(
      to: token,
      data: {
        'title': title,
        'body': body,
      },
    );
  }
}
