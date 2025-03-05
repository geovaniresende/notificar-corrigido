import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configuração do Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Solicitar permissão para notificações no iOS
  await messaging.requestPermission();

  // Obter o token de notificação
  String? token = await messaging.getToken();
  print("Firebase Messaging Token: $token");

  // Configurar o que acontece ao clicar na notificação
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Recebeu mensagem: ${message.notification?.title}, ${message.notification?.body}');
    _showNotification(message); // Exibe a notificação local
  });

  // Compartilhando a configuração de inicialização
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenLogin = prefs.getBool('hasSeenLogin') ?? false;
  bool hasSeenTerms = prefs.getBool('hasSeenTerms') ?? false;

  String initialRoute = '/login';
  if (hasSeenLogin && hasSeenTerms) {
    initialRoute = '/notification';
  } else if (hasSeenLogin) {
    initialRoute = '/terms_and_privacy_screen';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

// Função para exibir a notificação local
Future<void> _showNotification(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Configuração para exibir a notificação
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // Id do canal
    'your_channel_name', // Nome do canal
    channelDescription: 'Descrição do canal',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Id da notificação
    message.notification?.title, // Título
    message.notification?.body, // Corpo da mensagem
    platformChannelSpecifics, // Detalhes da notificação
    payload: 'item x', // Opcional: Payload de dados
  );
}

// Função para tratar notificações quando o app estiver em segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensagem recebida em segundo plano: ${message.notification?.title}");
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 223, 172, 19),
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
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/vehicle': (context) => const VehicleRegistrationScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/sobre_screen': (context) => const SobreScreen(),
        '/quadros_screen': (context) => QuadrosScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/mycars_screen': (context) => const MyCarsScreen(),
        '/terms_and_privacy_screen': (context) => TermsAndPrivacyScreen(),
      },
    );
  }
}
