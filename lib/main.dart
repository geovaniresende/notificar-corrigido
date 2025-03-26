import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(initialRoute: '/login'));
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

class PlateSearchScreen extends StatefulWidget {
  @override
  _PlateSearchScreenState createState() => _PlateSearchScreenState();
}

class _PlateSearchScreenState extends State<PlateSearchScreen> {
  TextEditingController plateController = TextEditingController();
  String result = "";

  Future<void> searchPlate() async {
    String plate = plateController.text.trim();
    if (plate.isEmpty) {
      setState(() {
        result = "❌ Digite a placa para buscar.";
      });
      return;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('plate', isEqualTo: plate)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          result = "❌ Nenhum usuário encontrado para a placa $plate.";
        });
      } else {
        var userDoc = querySnapshot.docs.first;
        String fcmToken = userDoc['fcm_token'] ?? '';

        if (fcmToken.isEmpty) {
          setState(() {
            result = "❌ Token FCM não encontrado para o usuário.";
          });
        } else {
          setState(() {
            result = "✅ Placa: $plate\nFCM Token: $fcmToken";
          });
          sendNotification(fcmToken);
        }
      }
    } catch (e) {
      setState(() {
        result = "❌ Erro ao buscar a placa: $e";
      });
    }
  }

  Future<void> sendNotification(String fcmToken) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendNotification');

      final result = await callable.call(<String, dynamic>{
        'fcmToken': fcmToken,
        'title': 'Notificação de Placa',
        'body': 'A sua placa foi identificada!',
      });

      if (result.data['success']) {
        print("✅ Notificação enviada com sucesso.");
      } else {
        print("❌ Erro ao enviar notificação: ${result.data['error']}");
      }
    } catch (e) {
      print("❌ Erro ao chamar a função de notificação: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscar Placa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: plateController,
              decoration: InputDecoration(
                labelText: 'Digite a placa',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchPlate,
              child: Text('Buscar'),
            ),
            SizedBox(height: 16),
            Text(
              result,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
