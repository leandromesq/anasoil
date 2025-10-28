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

  Future<void> addUser(UserModel user) async {
    // Validação de email único
    final existingUsers = await _usersRef
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (existingUsers.docs.isNotEmpty) {
      throw Exception('Este email já está em uso por outro usuário.');
    }

    await _usersRef.add(user);
  }

  Future<void> updateUser(String userId, UserModel user) async {
    // Validação de email único (excluindo o próprio usuário)
    final existingUsers = await _usersRef
        .where('email', isEqualTo: user.email)
        .limit(2)
        .get();

    final otherUsers = existingUsers.docs
        .where((doc) => doc.id != userId)
        .toList();
    if (otherUsers.isNotEmpty) {
      throw Exception('Este email já está em uso por outro usuário.');
    }

    await _usersRef.doc(userId).set(user, SetOptions(merge: true));
  }

  Future<void> deleteUser(String userId) async {
    await _usersRef.doc(userId).update({'active': false});
  }

  /// Método para verificar se um email já existe no sistema
  Future<bool> emailExists(String email, {String? excludeUserId}) async {
    final query = await _usersRef
        .where('email', isEqualTo: email)
        .limit(2)
        .get();

    if (excludeUserId != null) {
      return query.docs.any((doc) => doc.id != excludeUserId);
    }

    return query.docs.isNotEmpty;
  }

  /// Método para verificar se o usuário pode ser excluído (não é o próprio usuário)
  /// TODO: Implementar autenticação real para obter o ID do usuário atual
  Future<bool> canDeleteUser(String userId) async {
    // Por enquanto, como não temos autenticação implementada,
    // vamos simular verificando se o usuário é administrador
    final userDoc = await _usersRef.doc(userId).get();
    if (userDoc.exists) {
      final user = userDoc.data()!;
      // Se for administrador, não pode ser excluído (simulação)
      // Na implementação real, seria: return userId != currentUserId;
      return user.role != 'administrador';
    }
    return false;
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
