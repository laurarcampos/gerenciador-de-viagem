import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/firestore_service.dart';
import 'cadastra_item_page.dart';

class MostraPage extends StatefulWidget {
  final String id;

  MostraPage({required this.id});

  @override
  _MostraPageState createState() => _MostraPageState();
}

class _MostraPageState extends State<MostraPage> {
  final StreamController<List<String>> _itensController =
      StreamController<List<String>>();

  String _formatarData(Timestamp? timestamp) {
    final formatoData = DateFormat('dd/MM/yyyy');
    if (timestamp != null) {
      DateTime data = timestamp.toDate();
      return formatoData.format(data);
    } else {
      return 'N/A';
    }
  }

  Future<Map<String, dynamic>> obterPrevisaoTempo(
      String apiKey, String lugar) async {
    final response = await http.get(
      Uri.parse(
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lugar'),
    );

    try {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erro ao obter a previsão do tempo - Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro durante a solicitação HTTP: $e');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is http.ClientException) {
      return 'Erro de conexão: ${error.message}';
    } else {
      return 'Erro desconhecido: $error';
    }
  }

  Widget _criarBotoes(BuildContext context, String itemChave) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            await _removerItem(itemChave);
          },
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }

  Future<void> _removerItem(String itemChave) async {
    try {
      await FirestoreService().removerItem(widget.id, itemChave);

      // Atualiza a lista de itens após a remoção
      _carregarItens();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removido com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover o item: $e')),
      );
    }
  }

  void _carregarItens() {
    FirestoreService().getItensViagem(widget.id).listen((List<String> itens) {
      _itensController.add(itens);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarItens();
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

          Map<String, dynamic> viagem =
              snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lugar: ${viagem['lugar'] ?? 'N/A'}'),
                Text('Descrição: ${viagem['descricao'] ?? 'N/A'}'),
                Text('Início: ${_formatarData(viagem['inicio'])}'),
                Text('Fim: ${_formatarData(viagem['fim'])}'),
                FutureBuilder(
                  future: obterPrevisaoTempo(
                      '4056057b4a664cfabbc224552233008',
                      viagem['lugar'] as String),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text(
                          'Erro ao obter a previsão do tempo: ${_getErrorMessage(snapshot.error)}');
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('Não foi possível obter a previsão do tempo');
                    }

                    Map<String, dynamic> previsaoTempo =
                        snapshot.data as Map<String, dynamic>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Condição do Tempo: ${previsaoTempo['current']['condition']['text']}'),
                        Text(
                            'Temperatura: ${previsaoTempo['current']['temp_c']} °C'),
                      ],
                    );
                  },
                ),
                StreamBuilder(
                  stream: _itensController.stream,
                  builder: (context, itemSnapshot) {
                    if (itemSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (itemSnapshot.hasError) {
                      return Text(
                          'Erro ao carregar itens: ${itemSnapshot.error}');
                    }

                    List<String> itens =
                        itemSnapshot.data as List<String>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Itens:'),
                        for (String item in itens)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('- $item'),
                              _criarBotoes(context, item),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CadastraItem(id: widget.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _itensController.close();
    super.dispose();
  }
}
