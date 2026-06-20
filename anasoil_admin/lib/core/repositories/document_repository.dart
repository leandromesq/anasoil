import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';

class DocumentRepository extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AdminSession _session;

  DocumentRepository(this._firestoreService, this._session);

  List<DocumentModel> _documents = [];
  List<DocumentModel> get documents => List.unmodifiable(_documents);

  Future<List<DocumentModel>> getDocuments() async {
    _documents = await _firestoreService.getDocuments().first;
    notifyListeners();
    return _documents;
  }

  Future<void> deleteDocument(String documentId) async {
    _session.ensureCanManageData();

    await _firestoreService.deleteDocument(documentId);
    _documents.removeWhere((document) => document.id == documentId);
    notifyListeners();
  }

  Future<DocumentModel?> getById(String id) async {
    final docs = await _firestoreService.getDocuments().first;
    try {
      return docs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _documents = [];
    notifyListeners();
  }
}
