import 'package:firebase_app/core/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NovaConta extends StatefulWidget {
  const NovaConta({super.key});

  @override
  State<NovaConta> createState() => _NovaContaState();
}

class _NovaContaState extends State<NovaConta> {
  final txtEmail = TextEditingController();
  final txtSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
             TextField(
              controller: txtEmail,
              decoration: const InputDecoration(
              label: Text('Informe seu email'),
             )
            ),
             TextField(
              controller: txtSenha,
              decoration:const InputDecoration(
              label: Text('Informe sua senha'),
             )
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async{
              try {
              
              final usuario = await AuthService().novaConta(txtEmail.text, txtSenha.text);
              
              if(usuario != null){
                Navigator.of(context).pop(
                  {
                  'email': txtEmail.text,
                  'senha': txtSenha.text
                  }
                );
              }
              } on FirebaseAuthException catch(ex){
                var message = '';
                if(ex.code == 'email-already-in-use'){
                  message = 'O endereço de email já exite';
                }else if(ex.code =='invalid-email'){
                  message = 'Formato de email inválido';
                }else if(ex.code =='weak-password' || ex.code =='missing-password'){
                  message = 'A senha precisa de no mínimo 6 dígitos';
                }
                final snackBar = SnackBar(
                  content: Text(message),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                print(ex.code);

              }
            }, 
            child: const Text('Gravar')
            )
          ],
        ),
      ),
    );
  }
}