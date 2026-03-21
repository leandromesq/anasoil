import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:flutter/material.dart';

class AnalysisRepository extends ChangeNotifier {
  List<SoilAnalysisModel> _analyses = [];
  List<SoilAnalysisModel> get analyses => _analyses;

  void setAnalyses(List<SoilAnalysisModel> list) {
    _analyses = list;
    notifyListeners();
  }

  void clear() {
    _analyses = [];
    notifyListeners();
  }
}
