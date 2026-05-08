import 'dart:developer';

import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<UserModel> _usersRef;
  late final CollectionReference<DocumentModel> _documentsRef;
  late final CollectionReference<SoilAnalysisModel> _analysesRef;

  FirestoreService() {
    _usersRef = _db
        .collection(AnaSoilCollections.users)
        .withConverter<UserModel>(
          fromFirestore: (snapshots, _) => UserModel.fromFirestore(snapshots),
          toFirestore: (user, _) => user.toFirestore(),
        );

    _documentsRef = _db
        .collection(AnaSoilCollections.documents)
        .withConverter<DocumentModel>(
          fromFirestore: (snapshots, _) =>
              DocumentModel.fromFirestore(snapshots),
          toFirestore: (doc, _) => doc.toFirestore(),
        );

    _analysesRef = _db
        .collection(AnaSoilCollections.analyses)
        .withConverter<SoilAnalysisModel>(
          fromFirestore: (snapshots, _) =>
              SoilAnalysisModel.fromFirestore(snapshots),
          toFirestore: (analysis, _) => analysis.toFirestore(),
        );
  }

  Stream<List<UserModel>> getUsers() {
    return _usersRef.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Stream<UserModel?> getUserById(String userId) {
    return _usersRef.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _usersRef
        .where(UserFields.email, isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  Future<void> addUser(String uid, UserModel user) async {
    // validação de email único
    final normalizedEmail = user.email.trim().toLowerCase();
    final existingUsers = await _usersRef
        .where(UserFields.email, isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (existingUsers.docs.isNotEmpty) {
      throw Exception('Este email já está em uso por outro usuário.');
    }

    await _usersRef.doc(uid).set(user);
  }

  Future<void> updateUser(String userId, UserModel user) async {
    // validação de email único
    await _ensureCanChangeAdminRole(userId, user.userRole);

    final normalizedEmail = user.email.trim().toLowerCase();
    final existingUsers = await _usersRef
        .where(UserFields.email, isEqualTo: normalizedEmail)
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

  Future<void> updateUserStatus(String userId, bool active) async {
    if (!active) {
      await _ensureCanDeactivateUser(userId);
    }

    await _usersRef.doc(userId).update({UserFields.active: active});
  }

  Future<void> deleteUser(String userId) async {
    await _ensureCanDeactivateUser(userId);
    await _usersRef.doc(userId).update({UserFields.active: false});
  }

  /// Método para verificar se um email já existe no sistema
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

  Future<bool> canDeleteUser(String userId) async {
    try {
      await _ensureCanDeactivateUser(userId);
      return true;
    } catch (_) {
      return false;
    }
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

  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    return doc.data();
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _ensureCanDeactivateUser(String userId) async {
    final userDoc = await _usersRef.doc(userId).get();
    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception('Usuário não encontrado.');
    }

    final user = userDoc.data()!;
    if (user.userRole == UserRole.admin) {
      final activeAdmins = await _activeAdminCount();
      if (activeAdmins <= 1) {
        throw Exception(
          'Não é possível desativar o último administrador ativo.',
        );
      }
    }
  }

  Future<void> _ensureCanChangeAdminRole(
    String userId,
    UserRole nextRole,
  ) async {
    final userDoc = await _usersRef.doc(userId).get();
    if (!userDoc.exists || userDoc.data() == null) return;

    final current = userDoc.data()!;
    if (current.userRole == UserRole.admin && nextRole != UserRole.admin) {
      final activeAdmins = await _activeAdminCount();
      if (activeAdmins <= 1) {
        throw Exception(
          'Não é possível remover o papel do último administrador ativo.',
        );
      }
    }
  }

  Future<int> _activeAdminCount() async {
    final snapshot = await _usersRef
        .where(UserFields.role, isEqualTo: UserRole.admin.firestoreValue)
        .where(UserFields.active, isEqualTo: true)
        .get();
    return snapshot.docs.length;
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

  // ==================== DOCUMENTS ====================

  Stream<List<DocumentModel>> getDocuments() {
    return _documentsRef.snapshots().map((snapshot) {
      final documents = snapshot.docs
          .map((doc) => doc.data())
          .where((doc) => doc.active)
          .toList();

      documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return documents;
    });
  }

  Future<void> deleteDocument(String documentId) async {
    await _documentsRef.doc(documentId).update({'active': false});
  }

  // ==================== SOIL ANALYSES ====================

  Stream<List<SoilAnalysisModel>> getAnalyses() {
    return _analysesRef.snapshots().map((snapshot) {
      final analyses = snapshot.docs
          .map((doc) => doc.data())
          .where((analysis) => analysis.active)
          .toList();

      analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return analyses;
    });
  }

  Future<void> deleteAnalysis(String analysisId) async {
    await _analysesRef.doc(analysisId).update({'active': false});
  }
}
