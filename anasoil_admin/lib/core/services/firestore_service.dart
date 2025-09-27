import 'dart:developer';

import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<UserModel> _usersRef;

  FirestoreService() {
    _usersRef = _db
        .collection('users')
        .withConverter<UserModel>(
          fromFirestore: (snapshots, _) => UserModel.fromFirestore(snapshots),
          toFirestore: (user, _) => user.toFirestore(),
        );
  }

  Stream<List<UserModel>> getUsers() {
    return _usersRef
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<UserModel?> getUserById(String userId) {
    return _usersRef.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  Future<void> addUser(UserModel user) {
    return _usersRef.add(user);
  }

  Future<void> updateUser(String userId, UserModel user) {
    return _usersRef.doc(userId).set(user, SetOptions(merge: true));
  }

  Future<void> deleteUser(String userId) {
    return _usersRef.doc(userId).update({'active': false});
  }

  Future<void> linkFarmerToConsultant(
    String farmerId,
    String consultantId,
  ) async {
    final farmerRef = _usersRef.doc(farmerId);
    final consultantRef = _usersRef.doc(consultantId);

    try {
      await _db.runTransaction((transaction) async {
        final farmerDoc = await transaction.get(farmerRef);
        final consultantDoc = await transaction.get(consultantRef);

        if (!farmerDoc.exists || !consultantDoc.exists) {
          throw Exception("Usuário (agricultor ou consultor) não encontrado.");
        }

        transaction.update(farmerRef, {
          'consultorIds': FieldValue.arrayUnion([consultantId]),
        });

        transaction.update(consultantRef, {
          'agricultorIds': FieldValue.arrayUnion([farmerId]),
        });
      });

      log("Vínculo entre agricultor e consultor realizado com sucesso!");
    } catch (e) {
      log("Erro ao tentar vincular usuários: $e");
      rethrow;
    }
  }

  Future<void> unlinkFarmerFromConsultant(
    String farmerId,
    String consultantId,
  ) async {
    final farmerRef = _usersRef.doc(farmerId);
    final consultantRef = _usersRef.doc(consultantId);

    try {
      await _db.runTransaction((transaction) async {
        final farmerDoc = await transaction.get(farmerRef);
        final consultantDoc = await transaction.get(consultantRef);

        if (!farmerDoc.exists || !consultantDoc.exists) {
          throw Exception("Usuário (agricultor ou consultor) não encontrado.");
        }

        transaction.update(farmerRef, {
          'consultorIds': FieldValue.arrayRemove([consultantId]),
        });

        transaction.update(consultantRef, {
          'agricultorIds': FieldValue.arrayRemove([farmerId]),
        });
      });

      log("Vínculo entre agricultor e consultor removido com sucesso!");
    } catch (e) {
      log("Erro ao tentar desvincular usuários: $e");
      rethrow;
    }
  }
}
