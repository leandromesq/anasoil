import 'dart:async';

import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';

class AnalysisRepository extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AdminSession _session;

  AnalysisRepository(this._firestoreService, this._session);

  List<SoilAnalysisModel> _analyses = [];
  StreamSubscription<List<SoilAnalysisModel>>? _analysesSubscription;

  List<SoilAnalysisModel> get analyses => List.unmodifiable(_analyses);

  Future<List<SoilAnalysisModel>> getAnalyses() async {
    final firstEmission = Completer<List<SoilAnalysisModel>>();

    await _analysesSubscription?.cancel();
    _analysesSubscription = _firestoreService.getAnalyses().listen(
      (analyses) {
        _analyses = analyses;
        notifyListeners();
        if (!firstEmission.isCompleted) {
          firstEmission.complete(_analyses);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!firstEmission.isCompleted) {
          firstEmission.completeError(error, stackTrace);
        }
      },
    );

    return firstEmission.future;
  }

  Future<void> deleteAnalysis(String analysisId) async {
    _session.ensureCanManageData();

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

  @override
  void dispose() {
    _analysesSubscription?.cancel();
    super.dispose();
  }
}
