import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/repositories/analysis_repository.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class AnalysisListViewModel extends ChangeNotifier {
  final AnalysisRepository _repository;

  List<SoilAnalysisModel> get analyses => _repository.analyses;

  late final fetchAnalysesCommand = Command0(_fetchAnalyses);
  late final deleteAnalysisCommand = Command1(_deleteAnalysis);

  AnalysisListViewModel(this._repository) {
    _repository.addListener(notifyListeners);
  }

  Future<Result<void>> _fetchAnalyses() async {
    try {
      await _repository.getAnalyses();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _deleteAnalysis(String analysisId) async {
    try {
      await _repository.deleteAnalysis(analysisId);
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
