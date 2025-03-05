import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // ✅ Salva que o usuário passou pela tela de login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenLogin', true);

      // ✅ Navega para os termos e privacidade
      Navigator.pushReplacementNamed(context, '/terms_and_privacy_screen');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Falha no login, tente novamente.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      }
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFd4a55a)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/icone-notificar.png',
                width: 120, height: 120),
            const SizedBox(height: 40),
            _buildTextField(controller: _emailController, hintText: 'E-mail'),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _passwordController,
                hintText: 'Senha',
                obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 60.0, vertical: 15.0),
              ),
              child: const Text('Entrar',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 30),
            const Text('Ainda não tem uma conta?',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: const Text(
                'Cadastre-se aqui',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white, fontSize: 18),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
