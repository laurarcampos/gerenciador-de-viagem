import 'package:firebase_app/core/auth_service.dart';
import 'package:firebase_app/pages/home_page.dart';
import 'package:firebase_app/pages/nova_conta_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  // classe de logica
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                label: Text('Senha'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                final usuario = await authService.login(
                  _emailController.text,
                  _senhaController.text,
                );
                if(usuario == null){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário ou senha inválido'),
                      backgroundColor:Colors.red,
                      )
                  );
                }else{  
                  Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: 
                  (context) => HomePage()
                  ),
                  );
                }
              },
              child: const Text('Entrar'),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(onPressed: (){
              Navigator.push(context, 
              MaterialPageRoute(builder: (context) => NovaConta()
              )).then((value){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conta criada com sucesso'),
                  ),
                );
              })
              ;
            }, 
            child: const Text('Ainda não possuo uma conta'),
            ),
          ],
        ),
      ),
    );  
  }
}
