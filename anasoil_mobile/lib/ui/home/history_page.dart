import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/dependency_injection.dart';
import '../../domain/models/soil_analysis.dart';
import '../../utils/result.dart';
import 'analysis_viewmodel.dart';

/// Página de histórico de análises
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final AnalysisViewModel _viewModel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AnalysisViewModel>();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    setState(() => _isLoading = true);
    await _viewModel.loadAnalysesCommand.execute();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteAnalysis(SoilAnalysis analysis) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Análise'),
        content: Text(
          'Deseja realmente excluir a análise '
          '${analysis.farmName.isNotEmpty ? analysis.farmName : analysis.sampleCode}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleteResult = await _viewModel.deleteAnalysis(analysis.id);

    if (!mounted) return;

    if (deleteResult is Ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análise excluída'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      _loadAnalyses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: ${(deleteResult as Error).error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final analyses = _viewModel.savedAnalyses;

          if (analyses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadAnalyses,
            color: Colors.green[700],
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnalysisCard(analyses[index]),
                );
              },
            ),
          );
        },
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
            'Importe um PDF na aba Análise para começar',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(SoilAnalysis analysis) {
    final d = analysis.analysisDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return GestureDetector(
      onTap: () => context.push('/analysis/detail', extra: analysis),
      child: Container(
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
          // Header
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
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _deleteAnalysis(analysis),
              ),
            ],
          ),
          // const SizedBox(height: 12),

          // Info rows
          // _buildInfoChips(analysis),

          // Document info
          if (analysis.solicitante != null || analysis.interessado != null) ...[
            const SizedBox(height: 10),
            if (analysis.solicitante != null)
              _buildInfoRow(Icons.business, analysis.solicitante!),
          ],

          const SizedBox(height: 10),

          // DMLab + Amostra
          Row(
            children: [
              _buildTag('DMLab ${analysis.dmlabNumber}', Colors.blue),
              const SizedBox(width: 8),
              _buildTag('Amostra ${analysis.sampleNumber}', Colors.grey),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
