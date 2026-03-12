import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/document/document_repository.dart';
import '../../../data/repositories/soil_analysis/soil_analysis_repository.dart';
import '../../../domain/models/document.dart';
import '../../../domain/models/soil_analysis.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel para gerenciar a importação de documentos, extração e análise
class AnalysisViewModel extends ChangeNotifier {
  final DocumentRepository _documentRepository;
  final SoilAnalysisRepository _soilAnalysisRepository;

  AnalysisViewModel({
    required DocumentRepository documentRepository,
    required SoilAnalysisRepository soilAnalysisRepository,
  }) : _documentRepository = documentRepository,
       _soilAnalysisRepository = soilAnalysisRepository {
    _documentRepository.addListener(notifyListeners);
    _soilAnalysisRepository.addListener(notifyListeners);

    uploadDocumentCommand = Command1(_uploadDocument);
    loadDocumentsCommand = Command0(_documentRepository.getDocuments);
    deleteDocumentCommand = Command1(_documentRepository.deleteDocument);
    extractPdfCommand = Command1(_extractFromPdf);
    saveAnalysisCommand = Command1(_saveAnalysis);
    loadAnalysesCommand = Command0(_soilAnalysisRepository.getAnalyses);
  }

  // Commands
  late final Command1<SoilDocument, File> uploadDocumentCommand;
  late final Command0<List<SoilDocument>> loadDocumentsCommand;
  late final Command1<void, String> deleteDocumentCommand;
  late final Command1<List<SoilAnalysis>, File> extractPdfCommand;
  late final Command1<SoilAnalysis, SoilAnalysis> saveAnalysisCommand;
  late final Command0<List<SoilAnalysis>> loadAnalysesCommand;

  /// Documento selecionado para análise
  SoilDocument? _selectedDocument;
  SoilDocument? get selectedDocument => _selectedDocument;

  /// Nome do arquivo selecionado localmente (antes do upload)
  String? _selectedFileName;
  String? get selectedFileName => _selectedFileName;

  /// Lista de documentos do usuário
  List<SoilDocument> get documents => _documentRepository.documents;

  /// ID do documento salvo no Firestore (obtido após upload)
  String? _uploadedDocumentId;
  String? get uploadedDocumentId => _uploadedDocumentId;

  /// Lista de análises extraídas (antes de salvar)
  List<SoilAnalysis> _extractedAnalyses = [];
  List<SoilAnalysis> get extractedAnalyses =>
      List.unmodifiable(_extractedAnalyses);

  /// Lista de análises salvas do usuário
  List<SoilAnalysis> get savedAnalyses => _soilAnalysisRepository.analyses;

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
    _uploadedDocumentId = null;
    _extractedAnalyses = [];
    notifyListeners();
  }

  /// Limpa as análises extraídas
  void clearExtractedAnalyses() {
    _extractedAnalyses = [];
    notifyListeners();
  }

  Future<Result<SoilDocument>> _uploadDocument(File file) async {
    final fileName =
        _selectedFileName ?? file.path.split('/').last.split('\\').last;
    final result = await _documentRepository.uploadDocument(file, fileName);

    if (result is Ok<SoilDocument>) {
      _uploadedDocumentId = result.value.id;
    }

    return result;
  }

  Future<Result<List<SoilAnalysis>>> _extractFromPdf(File file) async {
    final result = await _soilAnalysisRepository.extractFromPdf(
      file,
      documentId: _uploadedDocumentId,
    );

    if (result is Ok<List<SoilAnalysis>>) {
      _extractedAnalyses = result.value;
      notifyListeners();
    }

    return result;
  }

  Future<Result<SoilAnalysis>> _saveAnalysis(SoilAnalysis analysis) async {
    final result = await _soilAnalysisRepository.saveAnalysis(analysis);

    if (result is Ok<SoilAnalysis>) {
      _extractedAnalyses.removeWhere(
        (a) => a.sampleCode == analysis.sampleCode,
      );
      notifyListeners();
    }

    return result;
  }

  /// Salva todas as análises extraídas de uma vez
  Future<Result<int>> saveAllExtractedAnalyses() async {
    int savedCount = 0;

    for (final analysis in List.of(_extractedAnalyses)) {
      final result = await _soilAnalysisRepository.saveAnalysis(analysis);
      if (result is Ok<SoilAnalysis>) {
        savedCount++;
      } else {
        return Result.error(
          Exception('Erro ao salvar análise ${analysis.sampleCode}'),
        );
      }
    }

    _extractedAnalyses = [];
    notifyListeners();

    return Result.ok(savedCount);
  }

  /// Deleta uma análise pelo ID
  Future<Result<void>> deleteAnalysis(String analysisId) async {
    return _soilAnalysisRepository.deleteAnalysis(analysisId);
  }

  @override
  void dispose() {
    _documentRepository.removeListener(notifyListeners);
    _soilAnalysisRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
