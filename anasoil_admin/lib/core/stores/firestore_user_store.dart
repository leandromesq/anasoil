import 'dart:developer';

import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/stores/user_store.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserStore implements UserStore {
  final FirebaseFirestore _db;
  late final CollectionReference<UserModel> _usersRef;

  FirestoreUserStore({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance {
    _usersRef = _db
        .collection(AnaSoilCollections.users)
        .withConverter<UserModel>(
          fromFirestore: (snapshots, _) => UserModel.fromFirestore(snapshots),
          toFirestore: (user, _) => user.toFirestore(),
        );
  }

  @override
  Stream<List<UserModel>> getUsers() {
    return _usersRef.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  @override
  Stream<UserModel?> getUserById(String userId) {
    return _usersRef.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _usersRef
        .where(UserFields.email, isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  @override
  Future<void> addUser(String uid, UserModel user) async {
    await _usersRef.doc(uid).set(user);
  }

  @override
  Future<void> updateUser(String userId, UserModel user) async {
    await _usersRef.doc(userId).set(user, SetOptions(merge: true));
  }

  @override
  Future<void> updateUserStatus(String userId, bool active) async {
    await _usersRef.doc(userId).update({UserFields.active: active});
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _usersRef.doc(userId).update({UserFields.active: false});
  }

  @override
  Future<bool> emailExists(String email, {String? excludeUserId}) async {
    final query = await _usersRef
        .where(UserFields.email, isEqualTo: email.trim().toLowerCase())
        .limit(2)
        .get();

    if (excludeUserId != null) {
      return query.docs.any((doc) => doc.id != excludeUserId);
    }

    return query.docs.isNotEmpty;
  }

  @override
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
          throw Exception('Usuário (agricultor ou consultor) não encontrado.');
        }

        _ensureRelationRoles(farmerDoc.data(), consultantDoc.data());

        transaction.update(farmerRef, {
          UserFields.consultorIds: FieldValue.arrayUnion([consultantId]),
        });

        transaction.update(consultantRef, {
          UserFields.agricultorIds: FieldValue.arrayUnion([farmerId]),
        });
      });

      log('Vínculo entre agricultor e consultor realizado com sucesso!');
    } catch (e) {
      log('Erro ao tentar vincular usuários: $e');
      rethrow;
    }
  }

  @override
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
          throw Exception('Usuário (agricultor ou consultor) não encontrado.');
        }

        _ensureRelationRoles(farmerDoc.data(), consultantDoc.data());

        transaction.update(farmerRef, {
          UserFields.consultorIds: FieldValue.arrayRemove([consultantId]),
        });

        transaction.update(consultantRef, {
          UserFields.agricultorIds: FieldValue.arrayRemove([farmerId]),
        });
      });

      log('Vínculo entre agricultor e consultor removido com sucesso!');
    } catch (e) {
      log('Erro ao tentar desvincular usuários: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    return doc.data();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  void _ensureRelationRoles(UserModel? farmer, UserModel? consultant) {
    if (farmer == null || consultant == null) {
      throw Exception('Usuário (agricultor ou consultor) não encontrado.');
    }
    if (!farmer.active || !consultant.active) {
      throw Exception('Não é possível vincular usuários inativos.');
    }
    if (farmer.userRole != UserRole.farmer ||
        consultant.userRole != UserRole.consultant) {
      throw Exception('Vínculo deve ser entre Agricultor e Consultor.');
    }
  }
}
