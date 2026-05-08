import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/profile_type.dart';
import '../../../domain/models/document.dart';
import '../../../domain/models/soil_analysis.dart';

/// Serviço de acesso ao Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Referência da coleção de usuários
  late final CollectionReference<Map<String, dynamic>> _usersRef;

  /// Referência da coleção de documentos
  late final CollectionReference<Map<String, dynamic>> _documentsRef;

  /// Referência da coleção de análises de solo
  late final CollectionReference<Map<String, dynamic>> _soilAnalysesRef;

  FirestoreService() {
    _usersRef = _db.collection(AnaSoilCollections.users);
    _documentsRef = _db.collection(AnaSoilCollections.documents);
    _soilAnalysesRef = _db.collection(AnaSoilCollections.analyses);
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
          .where(UserFields.email, isEqualTo: email.trim().toLowerCase())
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
      return Result.ok(data?[UserFields.active] == true);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar status do usuário: $e'));
    }
  }

  /// Converte documento Firestore para User
  User _userFromFirestore(String id, Map<String, dynamic> data) {
    final profileType = ProfileType.fromRole(
      UserRole.parse(data[UserFields.role] as String?),
    );

    return User(
      id: id,
      name: data[UserFields.name] as String? ?? '',
      email: data[UserFields.email] as String? ?? '',
      profileType: profileType,
      phone: data[UserFields.phone] as String?,
      avatarUrl: data[UserFields.avatarUrl] as String?,
    );
  }

  /// Converte User para Map do Firestore
  Map<String, dynamic> _userToFirestore(User user) {
    return {
      UserFields.name: user.name,
      UserFields.email: user.email.trim().toLowerCase(),
      UserFields.role: user.profileType.firestoreValue,
      UserFields.phone: user.phone,
      UserFields.active: true,
      UserFields.createdAt: FieldValue.serverTimestamp(),
      UserFields.consultorIds: [],
      UserFields.agricultorIds: [],
    };
  }

  /// Lista usuários por tipo de perfil
  Future<Result<List<User>>> getUsersByProfileType(
    ProfileType profileType,
  ) async {
    try {
      final querySnapshot = await _usersRef
          .where(UserFields.role, isEqualTo: profileType.firestoreValue)
          .where(UserFields.active, isEqualTo: true)
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
      final consultorIds = List<String>.from(
        data?[UserFields.consultorIds] ?? [],
      );

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
      final agricultorIds = List<String>.from(
        data?[UserFields.agricultorIds] ?? [],
      );

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

  /// Busca documentos de um usuário (apenas ativos)
  Future<Result<List<SoilDocument>>> getDocumentsByUser(String userId) async {
    try {
      final querySnapshot = await _documentsRef
          .where(DocumentFields.userId, isEqualTo: userId)
          .where(DocumentFields.active, isEqualTo: true)
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

  /// Soft-deleta um documento (marca como inativo)
  Future<Result<void>> deleteDocument(String docId) async {
    try {
      await _documentsRef.doc(docId).update({DocumentFields.active: false});
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar documento: $e'));
    }
  }

  // ==================== Análises de Solo ====================

  /// Cria uma análise de solo na coleção soilAnalyses
  Future<Result<SoilAnalysis>> createSoilAnalysis(SoilAnalysis analysis) async {
    try {
      final docRef = await _soilAnalysesRef.add(analysis.toFirestore());
      final created = analysis.copyWith(id: docRef.id);
      return Result.ok(created);
    } catch (e) {
      return Result.error(Exception('Erro ao criar análise de solo: $e'));
    }
  }

  /// Busca análises de solo de um usuário (apenas ativas)
  Future<Result<List<SoilAnalysis>>> getSoilAnalysesByUser(
    String userId,
  ) async {
    try {
      final querySnapshot = await _soilAnalysesRef
          .where(AnalysisFields.userId, isEqualTo: userId)
          .where(AnalysisFields.active, isEqualTo: true)
          .get();

      final analyses = querySnapshot.docs
          .map((doc) => SoilAnalysis.fromFirestore(doc.id, doc.data()))
          .toList();

      analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Result.ok(analyses);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar análises: $e'));
    }
  }

  /// Busca uma análise de solo pelo ID
  Future<Result<SoilAnalysis?>> getSoilAnalysisById(String id) async {
    try {
      final doc = await _soilAnalysesRef.doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return Result.ok(null);
      }

      return Result.ok(SoilAnalysis.fromFirestore(doc.id, doc.data()!));
    } catch (e) {
      return Result.error(Exception('Erro ao buscar análise: $e'));
    }
  }

  /// Busca análises vinculadas a um documento (apenas ativas)
  Future<Result<List<SoilAnalysis>>> getSoilAnalysesByDocument(
    String documentId,
  ) async {
    try {
      final querySnapshot = await _soilAnalysesRef
          .where(AnalysisFields.documentId, isEqualTo: documentId)
          .where(AnalysisFields.active, isEqualTo: true)
          .get();

      final analyses = querySnapshot.docs
          .map((doc) => SoilAnalysis.fromFirestore(doc.id, doc.data()))
          .toList();

      analyses.sort((a, b) => b.analysisDate.compareTo(a.analysisDate));

      return Result.ok(analyses);
    } catch (e) {
      return Result.error(
        Exception('Erro ao buscar análises do documento: $e'),
      );
    }
  }

  Future<Result<bool>> soilAnalysisExistsForDocumentSample({
    required String userId,
    required String documentId,
    required String labNumber,
  }) async {
    try {
      final querySnapshot = await _soilAnalysesRef
          .where(AnalysisFields.userId, isEqualTo: userId)
          .where(AnalysisFields.documentId, isEqualTo: documentId)
          .where(AnalysisFields.labNumber, isEqualTo: labNumber)
          .limit(1)
          .get();

      return Result.ok(querySnapshot.docs.isNotEmpty);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar análise duplicada: $e'));
    }
  }

  /// Soft-deleta uma análise de solo (marca como inativa)
  Future<Result<void>> deleteSoilAnalysis(String analysisId) async {
    try {
      await _soilAnalysesRef.doc(analysisId).update({
        AnalysisFields.active: false,
      });
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar análise: $e'));
    }
  }
}
