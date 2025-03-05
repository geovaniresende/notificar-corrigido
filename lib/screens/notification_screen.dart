import 'package:flutter/material.dart';
import 'mycars_screen.dart'; // Importando a tela MyCarsScreen
import 'vehicle_registration_screen.dart'; // Importando a tela VehicleRegistrationScreen

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color(0xFFD4A017),
          ),
          onPressed: () {
            _showMenu(context); // Abrir menu ao clicar no ícone de menu
          },
        ),
        title: const Text(
          'Notificar',
          style: TextStyle(
            color: Color(0xFFD4A017),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'O que você precisa notificar?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const VehicleRegistrationScreen(), // Navegar para a tela VehicleRegistrationScreen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 40), // Tamanho maior do botão
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/car_icon.png',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Faça sua solicitação', // Texto alterado
                    style: TextStyle(
                      color: Color(0xFFD4A017),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset(
                'assets/images/request_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Solicitações',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/quadros_screen');
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/car_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Meus Carros',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MyCarsScreen()), // Navegar para MyCarsScreen
                );
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/profile_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Editar Perfil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/images/about_icon.png',
                width: 24,
                height: 24,
              ),
              title: const Text(
                'Sobre esse app',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/sobre_screen');
              },
            ),
          ],
        );
      },
    );
  }
}
