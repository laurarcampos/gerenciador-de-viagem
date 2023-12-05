import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> gravar(String lugar, int cep, String descricao, DateTime inicio, DateTime fim, {String? id}) async {
    try {
      if (id != null) {
        final item = _firestore.collection('viagem').doc(id);

        await item.set({
          'lugar': lugar,
          'cep': cep,
          'descricao': descricao,
          'inicio': inicio,
          'fim': fim,
        });

        return id;
      } else {
        final ref = await _firestore.collection('viagem').add({
          'lugar': lugar,
          'cep': cep,
          'descricao': descricao,
          'inicio': inicio,
          'fim': fim,
        });

        return ref.id;
      }
    } catch (e) {
      print('Erro ao gravar no Firestore: $e');
      throw e;
    }
  }

  Future<String> gravarItem(String novoItem, {String? id}) async {
    try {
      if (id != null) {
        final itemDoc = _firestore.collection('itens').doc(id);

        await itemDoc.set({
          'item': novoItem,
        });

        return id;
      } else {
        final ref = await _firestore.collection('itens').add({
          'item': novoItem,
        });

        return ref.id;
      }
    } catch (e) {
      print('Erro ao gravar no Firestore: $e');
      throw e;
    }
  }

  Future<void> adicionarItem(String viagemId, String item) async {
    try {
      await _firestore
          .collection('viagem')
          .doc(viagemId)
          .collection('itens')
          .add({'item': item});
    } catch (e) {
      print('Erro ao adicionar item: $e');
      throw e;
    }
  }

  CollectionReference<Map<String, dynamic>> listar() {
    return _firestore.collection('viagem');
  }

  Future<void> remover(String chave) async {
    try {
      await _firestore.collection('viagem').doc(chave).delete();
    } catch (e) {
      print('Erro ao remover item: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> buscaPorId(String id) async {
    try {
      final snap = await _firestore.collection('viagem').doc(id).get();
      return snap.exists ? snap.data() : null;
    } catch (e) {
      print('Erro ao buscar por ID: $e');
      throw e;
    }
  }

  Stream<List<String>> getItensViagem(String viagemId) {
    try {
      return _firestore
          .collection('viagem')
          .doc(viagemId)
          .collection('itens')
          .snapshots()
          .map(
            (QuerySnapshot snapshot) {
              return snapshot.docs.map((DocumentSnapshot document) {
                return document['item'] as String;
              }).toList();
            },
          );
    } catch (e) {
      print('Erro ao obter itens da viagem: $e');
      throw e;
    }
  }
}
