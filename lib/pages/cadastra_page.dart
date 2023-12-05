import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  final txtInicio = TextEditingController();
  final txtFim = TextEditingController();

  String apiKey = '4056057b4a664cfabbc224552233008';
  final cepFocusNode = FocusNode(); 


  @override
  void initState() {
    super.initState();
    _carregarDados();
    cepFocusNode.addListener(() {
      if (!cepFocusNode.hasFocus) {
        _consultarEnderecoPorCep();
      }
      });
  }

  void _carregarDados() async {
  try {
    final dados = await FirestoreService().buscaPorId(widget.id!);

    if (dados != null) {
      txtLugar.text = dados['lugar'];
      txtcep.text = dados['cep'].toString();
      txtDescricao.text = dados['descricao'];
      if (dados['inicio'] != null) {
        txtInicio.text = DateFormat('dd/MM/yyyy').format(dados['inicio'].toDate());
      }
      if (dados['fim'] != null) {
        txtFim.text = DateFormat('dd/MM/yyyy').format(dados['fim'].toDate());
      }
    }
  } catch (e) {
    print('Erro ao carregar dados para edição: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao carregar dados para edição')),
    );
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

  Future<void> _mostrarDatePicker(TextEditingController controller) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (dataEscolhida != null && dataEscolhida != DateTime.now()) {
      controller.text = DateFormat('dd/MM/yyyy').format(dataEscolhida);
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
              focusNode: cepFocusNode, 
              onEditingComplete: () => FocusScope.of(context).nextFocus(), 
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
              TextField(
              controller: txtInicio,
              readOnly: true, 
              onTap: () => _mostrarDatePicker(txtInicio),
              decoration: const InputDecoration(labelText: 'Início:'),
              ),
            const SizedBox(
              height: 20,
            ),  
            TextField(
              controller: txtFim,
              readOnly: true, 
              onTap: () => _mostrarDatePicker(txtFim),
              decoration: const InputDecoration(labelText: 'Fim:'),
            ),
            const SizedBox(
              height: 20,
            ),
           ElevatedButton(
            onPressed: () async {
              try {
                await _consultarEnderecoPorCep();
                final inicioDateTime = DateFormat('dd/MM/yyyy').parse(txtInicio.text);
                final fimDateTime = DateFormat('dd/MM/yyyy').parse(txtFim.text);

                final idGerado = await FirestoreService().gravar(
                  txtLugar.text,
                  int.parse(txtcep.text), 
                  txtDescricao.text,
                  inicioDateTime,
                  fimDateTime,
                  id: widget.id,
                );
                widget.id = idGerado;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cadastrado com sucesso')),
                );

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              } catch (e) {
                print('Erro ao salvar: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao salvar')),
                );
              }
            },
            child: const Text('Salvar'),
          ),

          ],
        ),
      ),
    );
  }
}
