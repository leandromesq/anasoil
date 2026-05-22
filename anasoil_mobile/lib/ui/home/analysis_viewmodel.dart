import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/repositories/document/document_repository.dart';
import '../../data/repositories/soil_analysis/soil_analysis_repository.dart';
import '../../domain/models/analysis_intake_state.dart';
import '../../domain/models/document.dart';
import '../../domain/models/soil_analysis.dart';
import '../../domain/upload_flow.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// ViewModel for the analysis page.
///
/// Delegates the Upload Flow to a dedicated [UploadFlow] module and keeps
/// ownership of the document and saved-analysis lists.
class AnalysisViewModel extends ChangeNotifier {
  final DocumentRepository _documentRepository;
  final SoilAnalysisRepository _soilAnalysisRepository;
  late final UploadFlow _uploadFlow;

  AnalysisViewModel({
    required DocumentRepository documentRepository,
    required SoilAnalysisRepository soilAnalysisRepository,
  }) : _documentRepository = documentRepository,
       _soilAnalysisRepository = soilAnalysisRepository {
    _documentRepository.addListener(notifyListeners);
    _soilAnalysisRepository.addListener(notifyListeners);

    _uploadFlow = UploadFlow(
      documentRepository: documentRepository,
      soilAnalysisRepository: soilAnalysisRepository,
    );
    _uploadFlow.addListener(notifyListeners);

    uploadDocumentCommand = Command1(_uploadDocument);
    loadDocumentsCommand = Command0(_documentRepository.getDocuments);
    deleteDocumentCommand = Command1(_documentRepository.deleteDocument);
    extractPdfCommand = Command1(_extractFromPdf);
    saveAnalysisCommand = Command1(_uploadFlow.saveSingle);
    loadAnalysesCommand = Command0(_soilAnalysisRepository.getAnalyses);
    deleteAnalysisCommand = Command1(_soilAnalysisRepository.deleteAnalysis);
  }

  // Commands
  late final Command1<SoilDocument, File> uploadDocumentCommand;
  late final Command0<List<SoilDocument>> loadDocumentsCommand;
  late final Command1<void, String> deleteDocumentCommand;
  late final Command1<List<SoilAnalysis>, File> extractPdfCommand;
  late final Command1<SoilAnalysis, SoilAnalysis> saveAnalysisCommand;
  late final Command0<List<SoilAnalysis>> loadAnalysesCommand;
  late final Command1<void, String> deleteAnalysisCommand;

  // --- Upload Flow delegation ---

  AnalysisIntakeState get intakeState => _uploadFlow.intakeState;

  SoilDocument? _selectedDocument;
  SoilDocument? get selectedDocument => _selectedDocument;

  String? get selectedFileName => _uploadFlow.selectedFileName;
  String? get uploadedDocumentId => _uploadFlow.uploadedDocumentId;

  List<SoilAnalysis> get extractedAnalyses => _uploadFlow.extractedAnalyses;
  List<SoilAnalysis> get lastSavedAnalyses => _uploadFlow.lastSavedAnalyses;

  // --- Document list ---

  List<SoilDocument> get documents => _documentRepository.documents;

  void setSelectedDocument(SoilDocument? doc) {
    _selectedDocument = doc;
    notifyListeners();
  }

  // --- Saved analysis list ---

  List<SoilAnalysis> get savedAnalyses => _soilAnalysisRepository.analyses;

  // --- Upload Flow operations ---

  void setSelectedFileName(String? name) {
    if (name != null) {
      _uploadFlow.setSelectedFile(name);
    }
  }

  void clearSelection() {
    _selectedDocument = null;
    _uploadFlow.clearAll();
    uploadDocumentCommand.clear();
    extractPdfCommand.clear();
    saveAnalysisCommand.clear();
    notifyListeners();
  }

  void clearExtractedAnalyses() {
    _uploadFlow.clearExtracted();
  }

  Future<Result<SoilDocument>> _uploadDocument(File file) async {
    final result = await _uploadFlow.upload(file);
    // Notify is handled by UploadFlow's listener; the command triggers notifyListeners
    // via the ChangeNotifier chain. But we need to propagate result for Command.
    return result;
  }

  Future<Result<List<SoilAnalysis>>> _extractFromPdf(File file) async {
    return _uploadFlow.extract(file);
  }

  Future<Result<int>> saveAllExtractedAnalyses() async {
    return _uploadFlow.saveAll();
  }

  @override
  void dispose() {
    _documentRepository.removeListener(notifyListeners);
    _soilAnalysisRepository.removeListener(notifyListeners);
    _uploadFlow.removeListener(notifyListeners);
    super.dispose();
  }
}
