import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/vehicle_registration_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/quadros_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/mycars_screen.dart';
import 'screens/terms_and_privacy_screen.dart';
import 'screens/recuperacao_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔥 Firebase inicializado com sucesso");

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await messaging.setAutoInitEnabled(true);

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    await _saveFCMToken(user.uid);
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenLogin = prefs.getBool('hasSeenLogin') ?? false;
  bool hasSeenTerms = prefs.getBool('hasSeenTerms') ?? false;

  String initialRoute = hasSeenLogin
      ? (hasSeenTerms ? '/notification' : '/terms_and_privacy_screen')
      : '/login';

  runApp(MyApp(initialRoute: initialRoute));
}

Future<void> _saveFCMToken(String userId) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    String? newToken = await messaging.getToken();
    if (newToken == null) {
      print("❌ Token FCM não foi gerado!");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', newToken);
    print("✅ Token FCM salvo localmente");

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('users').doc(userId);
    DocumentSnapshot userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'fcm_token': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("✅ Token FCM criado no Firestore!");
    } else {
      String? savedToken = userDoc.data() is Map &&
              (userDoc.data() as Map).containsKey('fcm_token')
          ? userDoc.get('fcm_token')
          : null;

      if (savedToken != newToken) {
        await userRef.update({
          'fcm_token': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print("✅ Token FCM atualizado no Firestore!");
      }
    }
  } catch (e) {
    print("❌ Erro ao salvar o token FCM: $e");
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
      "🔔 Mensagem recebida em segundo plano: ${message.notification?.title}");
}

class FirebaseNotificationService {
  // Utilizando o FirebaseMessaging para enviar notificações sem a necessidade de server-key
  Future<void> sendPushNotification(
      String userId, String title, String message) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("❌ Usuário não encontrado!");
        return;
      }

      String? token = userDoc.data() is Map &&
              (userDoc.data() as Map).containsKey('fcm_token')
          ? userDoc.get('fcm_token')
          : null;

      if (token == null) {
        print("❌ Token FCM não encontrado!");
        return;
      }

      // Envio de notificação via FCM sem server-key
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
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
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notificação enviada!");
      } else {
        print("❌ Falha ao enviar: ${response.body}");
      }
    } catch (e) {
      print("❌ Erro ao enviar notificação: $e");
    }
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notificar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF3C343),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          hintStyle: const TextStyle(color: Colors.black45),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/vehicle': (context) => const VehicleRegistrationScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/sobre_screen': (context) => const SobreScreen(),
        '/quadros_screen': (context) => QuadrosScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/mycars_screen': (context) => const MyCarsScreen(),
        '/terms_and_privacy_screen': (context) => TermsAndPrivacyScreen(),
        '/recuperacao_screen': (context) => const RecuperacaoScreen(),
      },
    );
  }
}
