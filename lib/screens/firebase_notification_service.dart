import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseNotificationService {
  final String _serverKey = "SEU_SERVER_KEY_DO_FCM"; // Substitua pela sua chave

  Future<void> sendPushNotification(
      String token, String title, String message) async {
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'to': token,
            'notification': {
              'title': title,
              'body': message,
              'sound': 'default',
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
            },
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Notificação enviada com sucesso!");
      } else {
        print("❌ Falha ao enviar notificação: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Erro ao enviar notificação: $e");
    }
  }
}
