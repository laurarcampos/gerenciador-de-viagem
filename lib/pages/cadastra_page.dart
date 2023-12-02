import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/firestore_service.dart';

class CadastraPage extends StatefulWidget {
  String? id;
  CadastraPage({super.key, this.id});

  @override
  State<CadastraPage> createState() => _CadastraPageState();
}

class _CadastraPageState extends State<CadastraPage> {
  final txtLugar = TextEditingController();
  final txtcep = TextEditingController();
  final txtDescricao = TextEditingController();
  String apiKey = '4056057b4a664cfabbc224552233008';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    if (widget.id != null) {
      final dados = await FirestoreService().buscaPorId(widget.id!);
      txtLugar.text = dados?['lugar'];
      txtcep.text = dados?['cep'];
      txtDescricao.text = dados?['descricao'];
    }
  }

  Future<void> _consultarEnderecoPorCep() async {
    final cep = txtcep.text;
    if (cep.isNotEmpty) {
      final url = Uri.parse('http://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final lugar = jsonResponse['localidade']; 
        setState(() {
          txtLugar.text = lugar;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao consultar o CEP')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastre uma nova viagem'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: txtcep,
              decoration: const InputDecoration(labelText: 'CEP:'),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: txtLugar,
              decoration: const InputDecoration(labelText: 'Lugar:'),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: txtDescricao,
              decoration: const InputDecoration(labelText: 'Descrição:'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await _consultarEnderecoPorCep(); 
                final idGerado = await FirestoreService().gravar(
                  txtLugar.text,
                  txtcep.text,
                  txtDescricao.text,
                  id: widget.id,
                );
                widget.id = idGerado;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cadastrado com sucesso')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
