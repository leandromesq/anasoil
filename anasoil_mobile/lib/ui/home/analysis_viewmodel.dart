import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/document/document_repository.dart';
import '../../../domain/models/document.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel para gerenciar a importação de documentos e análise
class AnalysisViewModel extends ChangeNotifier {
  final DocumentRepository _documentRepository;

  AnalysisViewModel({required DocumentRepository documentRepository})
    : _documentRepository = documentRepository {
    _documentRepository.addListener(notifyListeners);

    uploadDocumentCommand = Command1(_uploadDocument);
    loadDocumentsCommand = Command0(_documentRepository.getDocuments);
    deleteDocumentCommand = Command1(_documentRepository.deleteDocument);
  }

  // Commands
  late final Command1<SoilDocument, File> uploadDocumentCommand;
  late final Command0<List<SoilDocument>> loadDocumentsCommand;
  late final Command1<void, String> deleteDocumentCommand;

  /// Documento selecionado para análise
  SoilDocument? _selectedDocument;
  SoilDocument? get selectedDocument => _selectedDocument;

  /// Nome do arquivo selecionado localmente (antes do upload)
  String? _selectedFileName;
  String? get selectedFileName => _selectedFileName;

  /// Lista de documentos do usuário
  List<SoilDocument> get documents => _documentRepository.documents;

  /// Define o nome do arquivo selecionado localmente
  void setSelectedFileName(String? name) {
    _selectedFileName = name;
    notifyListeners();
  }

  /// Define o documento selecionado
  void setSelectedDocument(SoilDocument? doc) {
    _selectedDocument = doc;
    notifyListeners();
  }

  /// Limpa a seleção atual
  void clearSelection() {
    _selectedDocument = null;
    _selectedFileName = null;
    notifyListeners();
  }

  Future<Result<SoilDocument>> _uploadDocument(File file) async {
    final fileName =
        _selectedFileName ?? file.path.split('/').last.split('\\').last;
    return _documentRepository.uploadDocument(file, fileName);
  }

  @override
  void dispose() {
    _documentRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
