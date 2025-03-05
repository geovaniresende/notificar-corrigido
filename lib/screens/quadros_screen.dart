import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuadrosScreen extends StatefulWidget {
  @override
  _QuadrosScreenState createState() => _QuadrosScreenState();
}

class _QuadrosScreenState extends State<QuadrosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userPlate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserPlate();
  }

  Future<void> _getUserPlate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userPlate = userDoc['plate']; // Pegando a placa do usuário logado
          isLoading = false;
        });
        print('Placa do usuário: $userPlate'); // Debugging
      } else {
        setState(() {
          userPlate = null; // Se não encontrar o usuário, definir como nulo
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userPlate = null; // Se o usuário não estiver logado, definir como nulo
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:
              const Text('Solicitações', style: TextStyle(color: Colors.amber)),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.amber),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            indicatorColor: Colors.amber,
            tabs: [
              Tab(
                  child: Center(
                      child: Text('Realizadas',
                          style: TextStyle(color: Colors.amber)))),
              Tab(
                  child: Center(
                      child: Text('Recebidas',
                          style: TextStyle(color: Colors.amber)))),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userPlate == null
                ? const Center(child: Text("Erro ao carregar a placa."))
                : TabBarView(
                    children: [
                      _buildRequestList(),
                      _buildReceivedNotifications(),
                    ],
                  ),
      ),
    );
  }

  /// Aba "Realizadas" - solicitações feitas pelo usuário logado
  Widget _buildRequestList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('completedRequests')
          .where('userPlate',
              isEqualTo: userPlate) // Filtrando pela placa do usuário
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar solicitações."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhuma solicitação encontrada."));
        }

        return _buildList(snapshot.data!.docs);
      },
    );
  }

  /// Aba "Recebidas" - solicitações feitas para a placa do usuário logado
  Widget _buildReceivedNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('receivedRequests')
          .doc(userPlate!) // Buscando na coleção da placa do usuário
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar notificações."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhuma notificação recebida."));
        }

        return _buildList(snapshot.data!.docs);
      },
    );
  }

  /// Método genérico para renderizar as listas de solicitações
  Widget _buildList(List<DocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>? ?? {};

        final reason = data['reason'] ?? 'Sem motivo especificado';
        final plate = data['plate'] ?? 'Placa desconhecida';

        return Card(
          color: Colors.black,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset('assets/images/razao.png'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(reason,
                          style: const TextStyle(color: Colors.amber)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset('assets/images/placa.png'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(plate,
                          style: const TextStyle(color: Colors.amber)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
