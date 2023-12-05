import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MostraPage extends StatefulWidget {
  final String id;

  MostraPage({required this.id});

  @override
  _MostraPageState createState() => _MostraPageState();
}

class _MostraPageState extends State<MostraPage> {
  final StreamController<List<String>> _itensController = StreamController<List<String>>();

  String _formatarData(Timestamp? timestamp) {
    final formatoData = DateFormat('dd/MM/yyyy');
    if (timestamp != null) {
      DateTime data = timestamp.toDate();
      return formatoData.format(data);
    } else {
      return 'N/A';
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  void _carregarItens() {
    FirestoreService().getItensViagem(widget.id).listen((itens) {
      _itensController.add(itens);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Viagem'),
      ),
      body: FutureBuilder(
        future: FirestoreService().buscaPorId(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Viagem não encontrada'));
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
                Text('Início: ${_formatarData(viagem['inicio'])}'),
                Text('Fim: ${_formatarData(viagem['fim'])}'),
                StreamBuilder(
                  stream: _itensController.stream,
                  builder: (context, itemSnapshot) {
                    if (itemSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (itemSnapshot.hasError) {
                      return Text('Erro ao carregar itens: ${itemSnapshot.error}');
                    }

                    List<String> itens = itemSnapshot.data as List<String>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Itens:'),
                        for (String item in itens) Text('- $item'),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _itensController.close();
    super.dispose();
  }
}
