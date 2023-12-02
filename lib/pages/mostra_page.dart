import 'package:flutter/material.dart';
import '../core/firestore_service.dart';

class MostraPage extends StatelessWidget {
  final String id;

  MostraPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Viagem'),
      ),
      body: FutureBuilder(
        future: FirestoreService().buscaPorId(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Text('Viagem não encontrada');
          }

          Map<String, dynamic> viagem = snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lugar: ${viagem['lugar']}'),
                Text('CEP: ${viagem['cep']}'),
                Text('Descrição: ${viagem['descricao']}'),
                // Adicione mais informações conforme necessário
              ],
            ),
          );
        },
      ),
    );
  }
}
