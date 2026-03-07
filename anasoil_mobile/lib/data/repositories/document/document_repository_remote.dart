import 'dart:io';
import '../../../domain/models/document.dart';
import '../../../utils/result.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/firestore_service.dart';
import 'document_repository.dart';

/// Implementação do repositório de documentos usando Firebase
class DocumentRepositoryRemote extends DocumentRepository {
  final FirebaseAuthService _authService;
  final FirebaseStorageService _storageService;
  final FirestoreService _firestoreService;

  List<SoilDocument> _documents = [];

  DocumentRepositoryRemote({
    required FirebaseAuthService authService,
    required FirebaseStorageService storageService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _storageService = storageService,
       _firestoreService = firestoreService;

  @override
  List<SoilDocument> get documents => List.unmodifiable(_documents);

  @override
  Future<Result<SoilDocument>> uploadDocument(
    File file,
    String fileName,
  ) async {
    try {
      final user = _authService.currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final userId = user.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'documents/$userId/${timestamp}_$fileName';

      // Upload do arquivo para Firebase Storage
      final uploadResult = await _storageService.uploadFile(storagePath, file);
      if (uploadResult is Error<String>) {
        return Result.error(uploadResult.error);
      }

      final fileUrl = (uploadResult as Ok<String>).value;
      final fileSize = await file.length();

      // Salva metadados no Firestore
      final doc = SoilDocument(
        id: '',
        userId: userId,
        fileName: fileName,
        fileUrl: fileUrl,
        fileSize: fileSize,
        mimeType: 'application/pdf',
        createdAt: DateTime.now(),
      );

      final createResult = await _firestoreService.createDocument(doc);
      if (createResult is Error<SoilDocument>) {
        return Result.error(createResult.error);
      }

      final createdDoc = (createResult as Ok<SoilDocument>).value;
      _documents.insert(0, createdDoc);
      notifyListeners();

      return Result.ok(createdDoc);
    } catch (e) {
      return Result.error(Exception('Erro ao fazer upload do documento: $e'));
    }
  }

  @override
  Future<Result<List<SoilDocument>>> getDocuments() async {
    try {
      final user = _authService.currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final result = await _firestoreService.getDocumentsByUser(user.uid);
      if (result is Error<List<SoilDocument>>) {
        return Result.error(result.error);
      }

      _documents = (result as Ok<List<SoilDocument>>).value;
      notifyListeners();

      return Result.ok(_documents);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar documentos: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDocument(String docId) async {
    try {
      // Busca o documento local para obter a URL do Storage
      final doc = _documents.where((d) => d.id == docId).firstOrNull;
      if (doc != null && doc.fileUrl.isNotEmpty) {
        await _storageService.deleteFileByUrl(doc.fileUrl);
      }

      final result = await _firestoreService.deleteDocument(docId);
      if (result is Error<void>) {
        return Result.error(result.error);
      }

      _documents.removeWhere((d) => d.id == docId);
      notifyListeners();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar documento: $e'));
    }
  }
}
