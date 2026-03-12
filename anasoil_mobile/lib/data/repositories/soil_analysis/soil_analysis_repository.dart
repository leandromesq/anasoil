import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../domain/models/soil_analysis.dart';
import '../../../utils/result.dart';

/// Interface do repositório de análises de solo
abstract class SoilAnalysisRepository extends ChangeNotifier {
  /// Lista de análises do usuário
  List<SoilAnalysis> get analyses;

  /// Extrai análises de um arquivo PDF
  Future<Result<List<SoilAnalysis>>> extractFromPdf(
    File pdfFile, {
    String? documentId,
  });

  /// Salva uma análise no Firestore
  Future<Result<SoilAnalysis>> saveAnalysis(SoilAnalysis analysis);

  /// Carrega todas as análises do usuário
  Future<Result<List<SoilAnalysis>>> getAnalyses();

  /// Busca uma análise pelo ID
  Future<Result<SoilAnalysis?>> getAnalysisById(String id);

  /// Busca análises por documento de origem
  Future<Result<List<SoilAnalysis>>> getAnalysesByDocument(String documentId);

  /// Deleta uma análise
  Future<Result<void>> deleteAnalysis(String analysisId);
}
