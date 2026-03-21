import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/repositories/document_repository.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class DocumentListViewModel extends ChangeNotifier {
  final DocumentRepository _repository;
  final FirestoreService _firestoreService;

  List<DocumentModel> get documents => _repository.documents;

  late final fetchDocumentsCommand = Command0(_fetchDocuments);
  late final deleteDocumentCommand = Command1(_deleteDocument);

  DocumentListViewModel(this._repository, this._firestoreService) {
    _repository.addListener(notifyListeners);
  }

  Future<Result<void>> _fetchDocuments() async {
    final list = await _firestoreService.getDocuments().first;
    _repository.setDocuments(list);
    return Result.ok(null);
  }

  Future<Result<void>> _deleteDocument(String documentId) async {
    try {
      await _firestoreService.deleteDocument(documentId);
      await fetchDocumentsCommand.execute();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
