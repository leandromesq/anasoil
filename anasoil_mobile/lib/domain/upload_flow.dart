import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/repositories/document/document_repository.dart';
import '../data/repositories/soil_analysis/soil_analysis_repository.dart';
import '../utils/result.dart';
import 'models/analysis_intake_state.dart';
import 'models/document.dart';
import 'models/soil_analysis.dart';

/// Owns the Import → Extraction → Save state machine for the Upload Flow.
///
/// The ViewModel delegates Upload Flow operations here and observes the
/// intake state and extracted analyses for UI rendering.
class UploadFlow extends ChangeNotifier {
  final DocumentRepository _documentRepository;
  final SoilAnalysisRepository _soilAnalysisRepository;

  UploadFlow({
    required DocumentRepository documentRepository,
    required SoilAnalysisRepository soilAnalysisRepository,
  }) : _documentRepository = documentRepository,
       _soilAnalysisRepository = soilAnalysisRepository;

  AnalysisIntakeState _intakeState = const AnalysisIntakeState();
  AnalysisIntakeState get intakeState => _intakeState;

  String? _selectedFileName;
  String? get selectedFileName => _selectedFileName;

  String? _uploadedDocumentId;
  String? get uploadedDocumentId => _uploadedDocumentId;

  List<SoilAnalysis> _extractedAnalyses = [];
  List<SoilAnalysis> get extractedAnalyses =>
      List.unmodifiable(_extractedAnalyses);

  List<SoilAnalysis> _lastSavedAnalyses = [];
  List<SoilAnalysis> get lastSavedAnalyses =>
      List.unmodifiable(_lastSavedAnalyses);

  void setSelectedFile(String name) {
    _selectedFileName = name;
    _intakeState = AnalysisIntakeState(
      step: AnalysisIntakeStep.fileSelected,
      fileName: name,
    );
    notifyListeners();
  }

  void clearAll() {
    _selectedFileName = null;
    _uploadedDocumentId = null;
    _extractedAnalyses = [];
    _lastSavedAnalyses = [];
    _intakeState = const AnalysisIntakeState();
    notifyListeners();
  }

  void clearExtracted() {
    _extractedAnalyses = [];
    _lastSavedAnalyses = [];
    _intakeState = _intakeState.copyWith(
      step: AnalysisIntakeStep.documentUploaded,
      extractedCount: 0,
      clearError: true,
    );
    notifyListeners();
  }

  Future<Result<SoilDocument>> upload(File file) async {
    final fileName =
        _selectedFileName ?? file.path.split('/').last.split('\\').last;
    _intakeState = _intakeState.copyWith(
      step: AnalysisIntakeStep.uploadingDocument,
      fileName: fileName,
      clearError: true,
    );
    notifyListeners();

    final result = await _documentRepository.uploadDocument(file, fileName);

    if (result is Ok<SoilDocument>) {
      _uploadedDocumentId = result.value.id;
      _intakeState = _intakeState.copyWith(
        step: AnalysisIntakeStep.documentUploaded,
        documentId: result.value.id,
      );
    } else if (result is Error<SoilDocument>) {
      _intakeState = _intakeState.copyWith(
        step: AnalysisIntakeStep.failed,
        errorMessage: result.error.toString(),
      );
    }

    notifyListeners();
    return result;
  }

  Future<Result<List<SoilAnalysis>>> extract(File file) async {
    if (_uploadedDocumentId == null) {
      final error = Exception(
        'Documento precisa ser enviado antes da extração.',
      );
      _intakeState = _intakeState.copyWith(
        step: AnalysisIntakeStep.failed,
        errorMessage: error.toString(),
      );
      notifyListeners();
      return Result.error(error);
    }

    _intakeState = _intakeState.copyWith(
      step: AnalysisIntakeStep.extracting,
      clearError: true,
    );
    notifyListeners();

    final result = await _soilAnalysisRepository.extractFromPdf(
      file,
      documentId: _uploadedDocumentId,
    );

    if (result is Ok<List<SoilAnalysis>>) {
      _extractedAnalyses = result.value;
      _intakeState = _intakeState.copyWith(
        step: AnalysisIntakeStep.extracted,
        extractedCount: result.value.length,
      );
    } else if (result is Error<List<SoilAnalysis>>) {
      _intakeState = _intakeState.copyWith(
        step: AnalysisIntakeStep.failed,
        errorMessage: result.error.toString(),
      );
    }

    notifyListeners();
    return result;
  }

  Future<Result<SoilAnalysis>> saveSingle(SoilAnalysis analysis) async {
    final result = await _soilAnalysisRepository.saveAnalysis(analysis);

    if (result is Ok<SoilAnalysis>) {
      _extractedAnalyses.removeWhere((a) => a.labNumber == analysis.labNumber);
      notifyListeners();
    }

    return result;
  }

  Future<Result<int>> saveAll() async {
    if (!_intakeState.canSave) {
      return Result.error(
        Exception('Extraia análises de um documento enviado antes de salvar.'),
      );
    }

    _intakeState = _intakeState.copyWith(
      step: AnalysisIntakeStep.saving,
      clearError: true,
    );
    notifyListeners();

    final savedAnalyses = <SoilAnalysis>[];

    for (final analysis in List.of(_extractedAnalyses)) {
      final result = await _soilAnalysisRepository.saveAnalysis(analysis);
      if (result is Ok<SoilAnalysis>) {
        savedAnalyses.add(result.value);
      } else {
        return Result.error(
          Exception('Erro ao salvar análise ${analysis.labNumber}'),
        );
      }
    }

    _extractedAnalyses = [];
    _lastSavedAnalyses = savedAnalyses;
    _intakeState = _intakeState.copyWith(
      step: AnalysisIntakeStep.complete,
      extractedCount: 0,
    );
    notifyListeners();

    return Result.ok(savedAnalyses.length);
  }
}
