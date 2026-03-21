import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/repositories/analysis_repository.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class AnalysisListViewModel extends ChangeNotifier {
  final AnalysisRepository _repository;
  final FirestoreService _firestoreService;

  List<SoilAnalysisModel> get analyses => _repository.analyses;

  late final fetchAnalysesCommand = Command0(_fetchAnalyses);
  late final deleteAnalysisCommand = Command1(_deleteAnalysis);

  AnalysisListViewModel(this._repository, this._firestoreService) {
    _repository.addListener(notifyListeners);
  }

  Future<Result<void>> _fetchAnalyses() async {
    final list = await _firestoreService.getAnalyses().first;
    _repository.setAnalyses(list);
    return Result.ok(null);
  }

  Future<Result<void>> _deleteAnalysis(String analysisId) async {
    try {
      await _firestoreService.deleteAnalysis(analysisId);
      await fetchAnalysesCommand.execute();
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
