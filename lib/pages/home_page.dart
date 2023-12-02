import 'package:firebase_app/core/firestore_service.dart';
import 'package:firebase_app/pages/cadastra_page.dart';
import 'package:firebase_app/pages/mostra_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de viagens'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child:  Column(
          children: [

            StreamBuilder(
              stream: FirestoreService().listar().snapshots(), 
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return CircularProgressIndicator();
                }
                final dados = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: dados.length,
                  itemBuilder: (context, index) {
                    return  ListTile(
                      title: Text(dados[index]['lugar']),
                      subtitle: Text("${dados[index]['cep']} - ${dados[index]['descricao']}"),
                      trailing: _criarBotoes(context, dados[index].id),
                    );
                  },
                );
              },
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CadastraPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
        ),
    );
  }
  
  _criarBotoes(BuildContext context, String chave) {
    return SizedBox(
      width: 100,
      child: Row(
        children: [
          IconButton(onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CadastraPage(id: chave),
              ),
            );
          }, 
          icon: Icon(Icons.edit),
          ),
          IconButton(onPressed: (){
            FirestoreService().remover(chave); 
          }, 
          icon: Icon(Icons.delete),
          ),
          IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MostraPage(id: chave),
              ),
            );
          },
          icon: Icon(Icons.visibility),
        ),

        ],
      ),
    );
  }
} 