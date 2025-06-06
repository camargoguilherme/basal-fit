import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../../models/tmb_record.dart';
import '../../services/firebase_service.dart';

class TMBHistoryScreen extends StatelessWidget {
  const TMBHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Modular.get<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de TMB'),
      ),
      body: StreamBuilder<List<TMBRecord>>(
        stream: firebaseService.getTMBRecords(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar histórico: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final records = snapshot.data!;
          if (records.isEmpty) {
            return const Center(
              child: Text('Nenhum registro encontrado'),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(record.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TMB: ${record.tmb.toStringAsFixed(2)} calorias/dia',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Peso: ${record.weight.toStringAsFixed(1)} kg'),
                      Text('Altura: ${record.height.toStringAsFixed(1)} cm'),
                      Text('Idade: ${record.age} anos'),
                      Text('Sexo: ${record.gender}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
