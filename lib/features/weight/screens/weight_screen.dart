import 'package:fit_track_pro/features/weight/models/weight_model.dart';
import 'package:fit_track_pro/features/weight/screens/add_weight_screen.dart';
import 'package:flutter/material.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  List<WeightModel> registros = [];

  Future<void> _navigateToAddWeightScreen() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWeightScreen()),
    );

    if (resultado != null && resultado is WeightModel) {
      setState(() {
        registros.add(resultado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Peso'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: registros.isEmpty
          ? Center(child: Text('No hay registros'))
          : ListView.builder(
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.monitor_weight)),
                    title: Text(
                      '${registro.pesoKilos} kg',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(registro.fecha),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWeightScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
