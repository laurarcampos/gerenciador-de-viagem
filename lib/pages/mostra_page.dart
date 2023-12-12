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

  String _formatarData(Timestamp? timestamp, {int dias = 0}) {
    final formatoData = DateFormat('dd/MM/yyyy');
    if (timestamp != null) {
      DateTime data = timestamp.toDate().add(Duration(days: dias));
      return formatoData.format(data);
    } else {
      return 'N/A';
    }
  }

  Future<Map<String, dynamic>> obterCoordenadasDoCEP(String cep) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&postalcode=$cep'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final Map<String, dynamic> coordenadas = {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };

        //print('Coordenadas para o CEP $cep: $coordenadas');

        return coordenadas;
      } else {
        throw Exception('Coordenadas não encontradas para o CEP $cep');
      }
    } else {
      throw Exception(
          'Erro ao obter coordenadas - Código: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> obterPrevisaoTempo(
      String apiKey, double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=5&lang=pt',
      ),
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
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Future<void> _removerItem(String itemChave) async {
    try {
      await FirestoreService().removerItem(widget.id, itemChave);
      _carregarItens();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removido com sucesso!')),
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
        title: const Text('Detalhes da Viagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: FirestoreService().buscaPorId(widget.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Viagem não encontrada'));
                }

                Map<String, dynamic> viagem =
                    snapshot.data as Map<String, dynamic>;

                return FutureBuilder(
                  future: obterCoordenadasDoCEP(viagem['cep'].toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'Erro ao obter coordenadas: ${_getErrorMessage(snapshot.error)}',
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text('Não foi possível obter coordenadas');
                    }

                    double latitude = snapshot.data!['latitude'];
                    double longitude = snapshot.data!['longitude'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lugar: ${viagem['lugar'] ?? 'N/A'}'),
                        Text('Descrição: ${viagem['descricao'] ?? 'N/A'}'),
                        Text('Início: ${_formatarData(viagem['inicio'])}'),
                        Text('Fim: ${_formatarData(viagem['fim'])}'),
                        FutureBuilder(
                          future: obterPrevisaoTempo(
                            '4056057b4a664cfabbc224552233008',
                            latitude,
                            longitude,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (snapshot.hasError) {
                              return Text(
                                'Erro ao obter a previsão do tempo: ${_getErrorMessage(snapshot.error)}',
                              );
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Text(
                                  'Não foi possível obter a previsão do tempo'
                                  );
                            }

                            List<dynamic> forecastList =
                                snapshot.data!['forecast']['forecastday'];

                            double temperaturaAtual =
                                forecastList[0]['day']['avgtemp_c'];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Temperatura Atual: $temperaturaAtual °C',
                                ),
                                for (int i = 0; i < forecastList.length; i++)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Temperatura Máxima (${_formatarData(Timestamp.now(), dias: i)}): ${forecastList[i]['day']['maxtemp_c']} °C',
                                      ),
                                      Text(
                                        'Temperatura Mínima (${_formatarData(Timestamp.now(), dias: i)}): ${forecastList[i]['day']['mintemp_c']} °C',
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            StreamBuilder(
              stream: _itensController.stream,
              builder: (context, itemSnapshot) {
                if (itemSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (itemSnapshot.hasError) {
                  return Text('Erro ao carregar itens: ${itemSnapshot.error}');
                }

                List<String> itens = itemSnapshot.data as List<String>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Itens:'),
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
