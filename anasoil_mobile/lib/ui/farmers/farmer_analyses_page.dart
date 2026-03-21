import 'package:flutter/material.dart';
import '../../core/dependency_injection.dart';
import '../../domain/models/user.dart';
import '../../domain/models/soil_analysis.dart';
import '../../utils/result.dart';
import 'farmers_viewmodel.dart';

/// Página de histórico de análises de um agricultor específico
class FarmerAnalysesPage extends StatefulWidget {
  final User farmer;

  const FarmerAnalysesPage({super.key, required this.farmer});

  @override
  State<FarmerAnalysesPage> createState() => _FarmerAnalysesPageState();
}

class _FarmerAnalysesPageState extends State<FarmerAnalysesPage> {
  late final FarmersViewModel _viewModel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FarmersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAnalyses());
  }

  Future<void> _loadAnalyses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _viewModel.loadFarmerAnalyses(widget.farmer.id);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result is Error<List<SoilAnalysis>>) {
        _error = result.error.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.farmer.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return _buildErrorState();
          }

          final analyses = _viewModel.farmerAnalyses;

          if (analyses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadAnalyses,
            color: Colors.green[700],
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: analyses.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFarmerHeader();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnalysisCard(analyses[index - 1]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmerHeader() {
    final farmer = widget.farmer;
    final hasAvatar = farmer.avatarUrl != null && farmer.avatarUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green[100],
            backgroundImage: hasAvatar ? NetworkImage(farmer.avatarUrl!) : null,
            child: !hasAvatar
                ? Icon(Icons.person, color: Colors.green[700], size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  farmer.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                if (farmer.phone != null && farmer.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    farmer.phone!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma análise encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este agricultor ainda não possui análises',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar análises',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAnalyses,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(SoilAnalysis analysis) {
    final d = analysis.analysisDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.grass, color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.farmName.isNotEmpty
                          ? analysis.farmName
                          : 'Análise ${analysis.sampleCode}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (analysis.solicitante != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    analysis.solicitante!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTag('DMLab ${analysis.dmlabNumber}', Colors.blue),
              const SizedBox(width: 8),
              _buildTag('Amostra ${analysis.sampleNumber}', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color[700],
        ),
      ),
    );
  }
}
