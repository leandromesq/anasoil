import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/profile_type.dart';
import '../../../domain/models/document.dart';
import '../../../utils/result.dart';

/// Serviço de acesso ao Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Referência da coleção de usuários
  late final CollectionReference<Map<String, dynamic>> _usersRef;

  /// Referência da coleção de documentos
  late final CollectionReference<Map<String, dynamic>> _documentsRef;

  FirestoreService() {
    _usersRef = _db.collection('users');
    _documentsRef = _db.collection('documents');
  }

  /// Busca usuário por ID do Firebase Auth
  Future<Result<User?>> getUserById(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();

      if (!doc.exists) {
        return Result.ok(null);
      }

      final data = doc.data();
      if (data == null) {
        return Result.ok(null);
      }

      return Result.ok(_userFromFirestore(doc.id, data));
    } catch (e) {
      return Result.error(Exception('Erro ao buscar usuário: $e'));
    }
  }

  /// Busca usuário por email
  Future<Result<User?>> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _usersRef
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Result.ok(null);
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      return Result.ok(_userFromFirestore(doc.id, data));
    } catch (e) {
      return Result.error(Exception('Erro ao buscar usuário por email: $e'));
    }
  }

  /// Stream de usuário por ID
  Stream<User?> getUserStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null) return null;

      return _userFromFirestore(snapshot.id, data);
    });
  }

  /// Atualiza dados do usuário
  Future<Result<void>> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _usersRef.doc(userId).update(data);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao atualizar usuário: $e'));
    }
  }

  /// Cria novo usuário no Firestore
  /// Nota: Geralmente chamado após criar usuário no Firebase Auth
  Future<Result<void>> createUser(String userId, User user) async {
    try {
      await _usersRef.doc(userId).set(_userToFirestore(user));
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao criar usuário: $e'));
    }
  }

  /// Verifica se usuário está ativo
  Future<Result<bool>> isUserActive(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();

      if (!doc.exists) {
        return Result.ok(false);
      }

      final data = doc.data();
      return Result.ok(data?['active'] == true);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar status do usuário: $e'));
    }
  }

  /// Converte documento Firestore para User
  User _userFromFirestore(String id, Map<String, dynamic> data) {
    // Mapeia 'role' do Firestore para 'profileType' do app
    final roleStr = data['role'] as String? ?? 'farmer';
    ProfileType profileType;

    switch (roleStr.toLowerCase()) {
      case 'consultant':
      case 'consultor':
        profileType = ProfileType.consultant;
        break;
      case 'farmer':
      case 'agricultor':
      default:
        profileType = ProfileType.farmer;
    }

    return User(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      profileType: profileType,
      phone: data['phone'] as String?,
    );
  }

  /// Converte User para Map do Firestore
  Map<String, dynamic> _userToFirestore(User user) {
    // Mapeia 'profileType' do app para 'role' do Firestore
    String role;
    switch (user.profileType) {
      case ProfileType.consultant:
        role = 'consultant';
        break;
      case ProfileType.farmer:
        role = 'farmer';
        break;
    }

    return {
      'name': user.name,
      'email': user.email,
      'role': role,
      'phone': user.phone,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'consultorIds': [],
      'agricultorIds': [],
    };
  }

  /// Lista usuários por tipo de perfil
  Future<Result<List<User>>> getUsersByProfileType(
    ProfileType profileType,
  ) async {
    try {
      String role;
      switch (profileType) {
        case ProfileType.consultant:
          role = 'consultant';
          break;
        case ProfileType.farmer:
          role = 'farmer';
          break;
      }

      final querySnapshot = await _usersRef
          .where('role', isEqualTo: role)
          .where('active', isEqualTo: true)
          .get();

      final users = querySnapshot.docs
          .map((doc) => _userFromFirestore(doc.id, doc.data()))
          .toList();

      return Result.ok(users);
    } catch (e) {
      return Result.error(Exception('Erro ao listar usuários: $e'));
    }
  }

  /// Busca consultores vinculados ao agricultor
  Future<Result<List<User>>> getConsultantsForFarmer(String farmerId) async {
    try {
      final farmerDoc = await _usersRef.doc(farmerId).get();

      if (!farmerDoc.exists) {
        return Result.error(Exception('Agricultor não encontrado'));
      }

      final data = farmerDoc.data();
      final consultorIds = List<String>.from(data?['consultorIds'] ?? []);

      if (consultorIds.isEmpty) {
        return Result.ok([]);
      }

      final consultants = <User>[];
      for (final consultorId in consultorIds) {
        final result = await getUserById(consultorId);
        if (result is Ok<User?>) {
          final user = result.value;
          if (user != null) {
            consultants.add(user);
          }
        }
      }

      return Result.ok(consultants);
    } catch (e) {
      return Result.error(
        Exception('Erro ao buscar consultores do agricultor: $e'),
      );
    }
  }

  /// Busca agricultores vinculados ao consultor
  Future<Result<List<User>>> getFarmersForConsultant(
    String consultantId,
  ) async {
    try {
      final consultantDoc = await _usersRef.doc(consultantId).get();

      if (!consultantDoc.exists) {
        return Result.error(Exception('Consultor não encontrado'));
      }

      final data = consultantDoc.data();
      final agricultorIds = List<String>.from(data?['agricultorIds'] ?? []);

      if (agricultorIds.isEmpty) {
        return Result.ok([]);
      }

      final farmers = <User>[];
      for (final agricultorId in agricultorIds) {
        final result = await getUserById(agricultorId);
        if (result is Ok<User?>) {
          final user = result.value;
          if (user != null) {
            farmers.add(user);
          }
        }
      }

      return Result.ok(farmers);
    } catch (e) {
      return Result.error(
        Exception('Erro ao buscar agricultores do consultor: $e'),
      );
    }
  }

  // ==================== Documentos ====================

  /// Cria um documento na coleção documents
  Future<Result<SoilDocument>> createDocument(SoilDocument doc) async {
    try {
      final docRef = await _documentsRef.add(doc.toFirestore());
      final created = doc.copyWith(id: docRef.id);
      return Result.ok(created);
    } catch (e) {
      return Result.error(Exception('Erro ao criar documento: $e'));
    }
  }

  /// Busca documentos de um usuário
  Future<Result<List<SoilDocument>>> getDocumentsByUser(String userId) async {
    try {
      final querySnapshot = await _documentsRef
          .where('userId', isEqualTo: userId)
          .get();

      final documents = querySnapshot.docs
          .map((doc) => SoilDocument.fromFirestore(doc.id, doc.data()))
          .toList();

      // Ordena localmente para evitar necessidade de índice composto
      documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Result.ok(documents);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar documentos: $e'));
    }
  }

  /// Deleta um documento da coleção
  Future<Result<void>> deleteDocument(String docId) async {
    try {
      await _documentsRef.doc(docId).delete();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar documento: $e'));
    }
  }
}
