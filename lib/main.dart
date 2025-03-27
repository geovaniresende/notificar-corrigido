import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Solicitar permissão para notificações (Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  print('Permissão concedida: ${settings.authorizationStatus}');

  // Obter o token FCM
  String? token = await messaging.getToken();
  print("Token FCM: $token");

  // Verificar se o token já está armazenado no Firestore
  if (token != null) {
    await _checkAndSaveToken(token);
  }

  // Configurar notificações locais
  var initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Configurar notificações em primeiro plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Mensagem recebida em primeiro plano: ${message.notification?.title}');
    print('Mensagem recebida em primeiro plano: ${message.notification?.body}');
    _showNotification(flutterLocalNotificationsPlugin, message);
  });

  // Configurar notificações em segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp(initialRoute: '/login'));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem recebida em segundo plano: ${message.notification?.title}');
  print('Mensagem recebida em segundo plano: ${message.notification?.body}');
}

void _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? '',
    message.notification?.body ?? '',
    platformDetails,
  );
}

// Função para verificar e salvar o token FCM
Future<void> _checkAndSaveToken(String token) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userId =
      'user_unique_id'; // Substitua isso pelo identificador do usuário ou use autenticação Firebase

  DocumentReference tokenRef = firestore.collection('users').doc(userId);

  // Verificar se o token já existe
  DocumentSnapshot doc = await tokenRef.get();
  if (doc.exists) {
    // Token já existe, não faz nada
    print('Token já existe no Firestore, não será substituído.');
  } else {
    // Se não existir, salvar o novo token
    await tokenRef.set({
      'fcm_token': token,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Token FCM salvo com sucesso no Firestore.');
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
