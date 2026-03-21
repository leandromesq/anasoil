import 'package:flutter/foundation.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/models/user.dart';
import '../../domain/models/soil_analysis.dart';
import '../../utils/result.dart';

/// ViewModel para gerenciar a lista de agricultores e suas análises
class FarmersViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  FarmersViewModel({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  List<User> _farmers = [];
  List<User> get farmers => List.unmodifiable(_farmers);

  List<SoilAnalysis> _farmerAnalyses = [];
  List<SoilAnalysis> get farmerAnalyses => List.unmodifiable(_farmerAnalyses);

  /// Análises recentes de todos os agricultores vinculados
  List<SoilAnalysis> _allFarmersAnalyses = [];
  List<SoilAnalysis> get allFarmersAnalyses =>
      List.unmodifiable(_allFarmersAnalyses);

  /// Mapa de userId -> nome do agricultor para exibição
  final Map<String, String> _farmerNames = {};
  String getFarmerName(String userId) => _farmerNames[userId] ?? '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Carrega os agricultores vinculados ao consultor
  Future<Result<List<User>>> loadFarmers(String consultantId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _firestoreService.getFarmersForConsultant(
      consultantId,
    );

    if (result is Ok<List<User>>) {
      _farmers = result.value;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Carrega as análises de solo de um agricultor específico
  Future<Result<List<SoilAnalysis>>> loadFarmerAnalyses(String farmerId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _firestoreService.getSoilAnalysesByUser(farmerId);

    if (result is Ok<List<SoilAnalysis>>) {
      _farmerAnalyses = result.value;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Carrega análises recentes de todos os agricultores vinculados ao consultor
  Future<void> loadAllFarmersAnalyses(String consultantId) async {
    // Garante que os agricultores já estejam carregados
    if (_farmers.isEmpty) {
      final farmersResult =
          await _firestoreService.getFarmersForConsultant(consultantId);
      if (farmersResult is Ok<List<User>>) {
        _farmers = farmersResult.value;
      } else {
        return;
      }
    }

    final allAnalyses = <SoilAnalysis>[];
    _farmerNames.clear();

    for (final farmer in _farmers) {
      _farmerNames[farmer.id] = farmer.name;
      final result = await _firestoreService.getSoilAnalysesByUser(farmer.id);
      if (result is Ok<List<SoilAnalysis>>) {
        allAnalyses.addAll(result.value);
      }
    }

    allAnalyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _allFarmersAnalyses = allAnalyses;
    notifyListeners();
  }
}
