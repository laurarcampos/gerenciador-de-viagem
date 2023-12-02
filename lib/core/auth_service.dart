import 'package:firebase_app/pages/nova_conta_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final _authInstance = FirebaseAuth.instance;

  Future<UserCredential?> login(String email, String senha) async {
    try {
      UserCredential usuario = await _authInstance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return usuario;
    } on FirebaseAuthException catch (ex) {
      print(ex);
    }
  }

  Future<UserCredential> novaConta(String email, String senha) {
    return _authInstance.createUserWithEmailAndPassword(email: email, password: senha);
  }

}
