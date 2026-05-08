import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';

class AnalysisRepository extends ChangeNotifier {
  final FirestoreService _firestoreService;

  AnalysisRepository(this._firestoreService);

  List<SoilAnalysisModel> _analyses = [];
  List<SoilAnalysisModel> get analyses => List.unmodifiable(_analyses);

  Future<List<SoilAnalysisModel>> getAnalyses() async {
    _analyses = await _firestoreService.getAnalyses().first;
    notifyListeners();
    return _analyses;
  }

  Future<void> deleteAnalysis(String analysisId) async {
    await _firestoreService.deleteAnalysis(analysisId);
    _analyses.removeWhere((analysis) => analysis.id == analysisId);
    notifyListeners();
  }

  Future<SoilAnalysisModel?> getById(String id) async {
    final analyses = await _firestoreService.getAnalyses().first;
    try {
      return analyses.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _analyses = [];
    notifyListeners();
  }
}
