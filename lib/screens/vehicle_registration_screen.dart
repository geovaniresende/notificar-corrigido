import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notificar/screens/firebase_notification_service.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({Key? key}) : super(key: key);

  @override
  _VehicleRegistrationScreenState createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final TextEditingController _plateController = TextEditingController();
  String? _selectedReason;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  final Map<String, String> notificationMessages = {
    'Carro preso':
        "Olá! Seu carro está bloqueando o meu veículo. Já estou de saída! 😊🚗",
    'Farol ligado':
        "Ei, amigo! Os faróis do seu carro estão ligados. Para evitar a descarga da bateria, que tal dar uma conferida? 💡🔋",
    'Vidro aberto':
        "Atenção! Um dos vidros do seu carro está aberto. Melhor fechar para evitar surpresas. 😉🚘",
    'Estacionamento irregular':
        "Ops! Seu carro está estacionado de forma irregular. Sugiro que ajuste a posição para evitar transtornos. 🚗🅿",
    'Outro':
        "Notificação importante sobre seu veículo! Por favor, vá até o seu carro dar uma conferida. 🔔",
  };

  void _sendNotification(String plate, String reason) async {
    String message =
        notificationMessages[reason] ?? "Notificação sobre seu veículo.";
    String senderId = FirebaseAuth.instance.currentUser?.uid ?? "desconhecido";

    try {
      // Criando notificação para quem enviou
      await _firestore.collection('completedRequests').add({
        'plate': plate,
        'reason': reason,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': senderId, // Quem enviou a notificação
      });

      // Criando notificação para quem vai receber
      await _firestore
          .collection('receivedRequests')
          .doc(plate)
          .collection('notifications')
          .add({
        'reason': reason,
        'plate': plate,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': senderId, // Quem enviou
      });

      // Verifica se o dono do veículo tem um token de notificação
      var userDoc = await _firestore.collection('users').doc(plate).get();
      if (userDoc.exists) {
        String? token = userDoc.data()?['fcmToken'];
        if (token != null) {
          _notificationService.sendPushNotification(
              token, "Alerta de Veículo", message);
        }
      }
    } catch (e) {
      print("Erro ao enviar notificação: $e");
    }
  }

  void _onNotifyPressed(BuildContext context) async {
    if (_plateController.text.trim().isNotEmpty && _selectedReason != null) {
      _sendNotification(_plateController.text.trim(), _selectedReason!);
      if (mounted) {
        Navigator.pushNamed(context, '/quadros_screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Notificação',
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: 'Placa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRadioOption('Carro preso'),
            _buildRadioOption('Farol ligado'),
            _buildRadioOption('Vidro aberto'),
            _buildRadioOption('Estacionamento irregular'),
            _buildRadioOption('Outro'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _onNotifyPressed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Notificar',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedReason,
      onChanged: (value) {
        setState(() {
          _selectedReason = value;
        });
      },
      title: Text(value),
    );
  }
}
