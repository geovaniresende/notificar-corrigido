import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({Key? key}) : super(key: key);

  @override
  _MyCarsScreenState createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  String carName = "Carro 1"; // Nome fixo do carro
  String plate = "";
  bool isLoading = true;
  String errorMessage = "";
  List<Map<String, String>> carDetails = []; // Para armazenar os carros

  TextEditingController carNameController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "Usuário não está logado.";
          isLoading = false;
        });
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          plate = userDoc['plate'] ?? "Placa não cadastrada";
          plateController.text = plate; // Carrega a placa no campo de edição
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Dados do carro não encontrados.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao carregar: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _addCarToFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "Usuário não está logado.";
        });
        return;
      }

      // Adiciona ou atualiza os dados do carro no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cars')
          .add({
        'name': carNameController.text,
        'plate': plateController.text,
      });

      // Atualiza a lista de carros após adicionar
      setState(() {
        carDetails.add({
          'name': carNameController.text,
          'plate': plateController.text,
        });
      });

      carNameController.clear();
      plateController.clear();
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao salvar: $e";
      });
    }
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Adicionar Carro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carNameController,
                decoration: const InputDecoration(labelText: "Nome do Carro"),
              ),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(labelText: "Placa"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _addCarToFirebase(); // Adiciona o carro no Firestore
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCarDialog(String carId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Carro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carNameController,
                decoration: const InputDecoration(labelText: "Nome do Carro"),
              ),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(labelText: "Placa"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('cars')
                    .doc(carId)
                    .update({
                  'name': carNameController.text,
                  'plate': plateController.text,
                });
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF303131), // Cor preta alterada
        title: const Text(
          'Meus Carros',
          style: TextStyle(color: Color(0xFFD4A017)), // Cor mostarda
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFFD4A017)), // Cor mostarda
          onPressed: () {
            Navigator.of(context).pop(); // Função de voltar
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Caixa preta com o nome do carro fixo e a placa
                      Card(
                        color: Color(0xFF303131), // Cor preta alterada
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15.0),
                          leading: Image.asset(
                            'assets/images/car_icon2.png',
                            width: 40,
                            height: 40,
                          ),
                          title: Text(
                            carName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017)), // Amarelo mostarda
                          ),
                          subtitle: Text(
                            plate,
                            style: const TextStyle(
                                color: Color(0xFFD4A017)), // Amarelo mostarda
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFFD4A017)), // Amarelo mostarda
                            onPressed:
                                _showAddCarDialog, // Abre o editor de placa
                          ),
                        ),
                      ),

                      // Exibe os carros cadastrados
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('cars')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text("Erro ao carregar dados"));
                            }

                            if (snapshot.hasData && snapshot.data != null) {
                              List<Map<String, String>> cars = [];
                              snapshot.data!.docs.forEach((doc) {
                                cars.add({
                                  'name': doc['name'],
                                  'plate': doc['plate'],
                                  'id': doc.id, // Inclui o ID do carro
                                });
                              });

                              return ListView.builder(
                                itemCount: cars.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color:
                                        Color(0xFF303131), // Cor preta alterada
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(15.0),
                                      leading: Image.asset(
                                        'assets/images/caricon3.png',
                                        width: 40,
                                        height: 40,
                                      ),
                                      title: Text(
                                        cars[index]['name']!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(
                                                0xFFD4A017)), // Amarelo mostarda
                                      ),
                                      subtitle: Text(
                                        cars[index]['plate']!,
                                        style: const TextStyle(
                                            color: Color(
                                                0xFFD4A017)), // Amarelo mostarda
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Color(
                                                0xFFD4A017)), // Amarelo mostarda
                                        onPressed: () {
                                          // Abre o diálogo de edição para o carro específico
                                          _showEditCarDialog(
                                              cars[index]['id']!);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                  child: Text("Nenhum carro encontrado"));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCarDialog,
        backgroundColor: Color(0xFF303131), // Cor preta alterada
        child: Icon(
          Icons.add,
          color: Color(0xFFD4A017), // Cor do "+" em mostarda
          size: 40,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Coloca o botão no canto inferior direito
    );
  }
}
