import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:flutter/material.dart';

class DocumentRepository extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  List<DocumentModel> get documents => _documents;

  void setDocuments(List<DocumentModel> list) {
    _documents = list;
    notifyListeners();
  }

  void clear() {
    _documents = [];
    notifyListeners();
  }
}
