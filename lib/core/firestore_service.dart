import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final _firestoreReference = FirebaseFirestore.instance;

   Future<String> gravar(String lugar, String cep, String descricao, {String? id}) async{
    if(id != null) {
      final item = await  _firestoreReference.collection('viagem').doc(id);
    
        item.set({
          'lugar': lugar,
          'cep': cep,
          'descricao': descricao,
        });

        return id;
  
    }else{
     final ref = await _firestoreReference.collection('viagem').add({
        'lugar': lugar,
        'cep': cep,
        'descricao': descricao,
    });
    return ref.id;
    }
  }

 CollectionReference<Map<String, dynamic>> listar(){
    return _firestoreReference.collection('viagem');
  }

  remover(String chave) async {
    final item = await  _firestoreReference.collection('viagem').doc(chave);
    if(item != null){
      item.delete();
    }
  }

 Future< Map<String, dynamic>? > buscaPorId(String id ) async{
  
    final snap = await  _firestoreReference.collection('viagem').doc(id).get();
    return snap.data();

  }

}