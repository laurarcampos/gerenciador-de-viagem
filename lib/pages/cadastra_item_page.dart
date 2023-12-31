import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../core/firestore_service.dart';

class CadastraItem extends StatefulWidget {
  String? id;
  CadastraItem({super.key, this.id});

  @override
  State<CadastraItem> createState() => _CadastraItemState();
}

class _CadastraItemState extends State<CadastraItem> {
  final txtItem = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    if (widget.id != null) {
      final dados = await FirestoreService().buscaPorId(widget.id!);
      txtItem.text = dados?['itens'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastre um novo item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: txtItem,
              decoration: const InputDecoration(labelText: 'Item:'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirestoreService().adicionarItem(
                    widget.id!,
                    txtItem.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item cadastrado com sucesso')),
                  );

                  Navigator.of(context).pop(); 
                } catch (e) {
                  print('Erro ao salvar item: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao salvar o item')),
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
