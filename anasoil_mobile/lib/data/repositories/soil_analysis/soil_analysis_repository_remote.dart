import 'dart:io';
import '../../../domain/models/soil_analysis.dart';
import '../../../utils/result.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/pdf_extraction_service.dart';
import 'soil_analysis_repository.dart';

/// Implementação remota do repositório de análises de solo
class SoilAnalysisRepositoryRemote extends SoilAnalysisRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final PdfExtractionService _pdfExtractionService;

  List<SoilAnalysis> _analyses = [];

  SoilAnalysisRepositoryRemote({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required PdfExtractionService pdfExtractionService,
  }) : _authService = authService,
       _firestoreService = firestoreService,
       _pdfExtractionService = pdfExtractionService;

  @override
  List<SoilAnalysis> get analyses => List.unmodifiable(_analyses);

  @override
  Future<Result<List<SoilAnalysis>>> extractFromPdf(
    File pdfFile, {
    String? documentId,
  }) async {
    try {
      final user = _authService.currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final result = await _pdfExtractionService.extractFromFile(
        pdfFile,
        userId: user.uid,
        documentId: documentId,
      );

      if (result is Error<List<SoilAnalysis>>) {
        return Result.error((result).error);
      }

      final extracted = (result as Ok<List<SoilAnalysis>>).value;

      for (final analysis in extracted) {
        final errors = _pdfExtractionService.validate(analysis);
        if (errors.isNotEmpty) {
          return Result.error(
            Exception('Erros de validação: ${errors.join(', ')}'),
          );
        }
      }

      return Result.ok(extracted);
    } catch (e) {
      return Result.error(Exception('Erro ao extrair dados do PDF: $e'));
    }
  }

  @override
  Future<Result<SoilAnalysis>> saveAnalysis(SoilAnalysis analysis) async {
    try {
      final user = _authService.currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      if (analysis.documentId == null || analysis.documentId!.isEmpty) {
        return Result.error(
          Exception('Análise precisa estar vinculada a um documento.'),
        );
      }

      final duplicateResult = await _firestoreService
          .soilAnalysisExistsForDocumentSample(
            userId: user.uid,
            documentId: analysis.documentId!,
            labNumber: analysis.labNumber,
          );

      if (duplicateResult is Error<bool>) {
        return Result.error(duplicateResult.error);
      }
      if (duplicateResult is Ok<bool> && duplicateResult.value) {
        return Result.error(
          Exception(
            'Análise ${analysis.labNumber} já foi salva para este documento.',
          ),
        );
      }

      final toSave = analysis.copyWith(userId: user.uid);
      final result = await _firestoreService.createSoilAnalysis(toSave);

      if (result is Error<SoilAnalysis>) {
        return Result.error((result).error);
      }

      final saved = (result as Ok<SoilAnalysis>).value;
      _analyses.insert(0, saved);
      notifyListeners();

      return Result.ok(saved);
    } catch (e) {
      return Result.error(Exception('Erro ao salvar análise: $e'));
    }
  }

  @override
  Future<Result<List<SoilAnalysis>>> getAnalyses() async {
    try {
      final user = _authService.currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final result = await _firestoreService.getSoilAnalysesByUser(user.uid);

      if (result is Error<List<SoilAnalysis>>) {
        return Result.error((result).error);
      }

      _analyses = (result as Ok<List<SoilAnalysis>>).value;
      notifyListeners();

      return Result.ok(_analyses);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar análises: $e'));
    }
  }

  @override
  Future<Result<SoilAnalysis?>> getAnalysisById(String id) async {
    try {
      final result = await _firestoreService.getSoilAnalysisById(id);

      if (result is Error<SoilAnalysis?>) {
        return Result.error((result).error);
      }

      return Result.ok((result as Ok<SoilAnalysis?>).value);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar análise: $e'));
    }
  }

  @override
  Future<Result<List<SoilAnalysis>>> getAnalysesByDocument(
    String documentId,
  ) async {
    try {
      final result = await _firestoreService.getSoilAnalysesByDocument(
        documentId,
      );

      if (result is Error<List<SoilAnalysis>>) {
        return Result.error((result).error);
      }

      return Result.ok((result as Ok<List<SoilAnalysis>>).value);
    } catch (e) {
      return Result.error(
        Exception('Erro ao buscar análises do documento: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAnalysis(String analysisId) async {
    try {
      final result = await _firestoreService.deleteSoilAnalysis(analysisId);

      if (result is Error<void>) {
        return Result.error((result).error);
      }

      _analyses.removeWhere((a) => a.id == analysisId);
      notifyListeners();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar análise: $e'));
    }
  }
}
