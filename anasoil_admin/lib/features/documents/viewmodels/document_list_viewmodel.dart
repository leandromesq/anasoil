import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/repositories/document_repository.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class DocumentListViewModel extends ChangeNotifier {
  final DocumentRepository _repository;

  List<DocumentModel> get documents => _repository.documents;

  late final fetchDocumentsCommand = Command0(_fetchDocuments);
  late final deleteDocumentCommand = Command1(_deleteDocument);

  DocumentListViewModel(this._repository) {
    _repository.addListener(notifyListeners);
  }

  Future<Result<void>> _fetchDocuments() async {
    try {
      await _repository.getDocuments();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _deleteDocument(String documentId) async {
    try {
      await _repository.deleteDocument(documentId);
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
