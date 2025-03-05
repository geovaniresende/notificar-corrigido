import 'package:flutter/material.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({Key? key}) : super(key: key);

  @override
  _MyCarsScreenState createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  List<Map<String, String>> cars = [
    {
      'carName': 'Meu Carro',
      'plate': 'ABC-1234',
      'carImagePath': 'assets/images/car_icon2.png',
      'plateImagePath': 'assets/images/plate_icon.png',
    },
  ];

  TextEditingController _carNameController = TextEditingController();
  TextEditingController _plateController = TextEditingController();

  void _addNewCar() {
    setState(() {
      cars.add({
        'carName': 'Novo Carro',
        'plate': 'XYZ-5678',
        'carImagePath': 'assets/images/car_icon2.png',
        'plateImagePath': 'assets/images/plate_icon.png',
      });
    });
  }

  void _editCar(int index) {
    _carNameController.text = cars[index]['carName']!;
    _plateController.text = cars[index]['plate']!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Carro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _carNameController,
                decoration: const InputDecoration(labelText: 'Nome do Carro'),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Image.asset(
                    'assets/images/plate_icon.png',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Placa'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  cars[index]['carName'] = _carNameController.text;
                  cars[index]['plate'] = _plateController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
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
        backgroundColor: Colors.black,
        title: const Text(
          'Meus Carros',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewCar,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15.0),
              leading: Image.asset(
                cars[index]['carImagePath']!,
                width: 40,
                height: 40,
              ),
              title: Text(
                cars[index]['carName']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(cars[index]['plate']!),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCar(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
