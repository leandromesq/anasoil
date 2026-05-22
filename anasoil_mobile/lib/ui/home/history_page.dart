import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/soil_analysis.dart';
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
  String? _inlineMessage;
  AnaSoilStatusTone _inlineTone = AnaSoilStatusTone.neutral;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AnalysisViewModel>();
    _viewModel.deleteAnalysisCommand.addListener(_onDeleteChanged);
    _loadAnalyses();
  }

  @override
  void dispose() {
    _viewModel.deleteAnalysisCommand.removeListener(_onDeleteChanged);
    super.dispose();
  }

  Future<void> _loadAnalyses() async {
    setState(() => _isLoading = true);
    await _viewModel.loadAnalysesCommand.execute();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onDeleteChanged() {
    if (!mounted) return;

    if (_viewModel.deleteAnalysisCommand.completed) {
      setState(() {
        _inlineMessage = null;
      });
    } else if (_viewModel.deleteAnalysisCommand.error) {
      setState(() {
        _inlineTone = AnaSoilStatusTone.danger;
        _inlineMessage =
            'Erro ao excluir: ${_viewModel.deleteAnalysisCommand.getCachedFailure()}';
      });
    }
  }

  Future<void> _deleteAnalysis(SoilAnalysis analysis) async {
    final displayName = analysis.propertyName.isNotEmpty
        ? analysis.propertyName
        : analysis.labNumber;
    final confirmed = await AnaSoilConfirmDialog.show(
      context,
      title: 'Excluir análise?',
      message: 'Deseja realmente excluir a análise "$displayName"?',
      confirmLabel: 'Excluir',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    _viewModel.deleteAnalysisCommand.execute(analysis.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_isLoading) {
            return const AnaSoilSkeletonList(itemCount: 5);
          }

          final analyses = _viewModel.savedAnalyses;

          if (analyses.isEmpty) {
            return const AnaSoilEmptyState(
              icon: Icons.history,
              title: 'Nenhuma análise encontrada',
              message:
                  'Importe um PDF na aba Análise para começar seu histórico.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAnalyses,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AnaSoilSpacing.lg),
              itemCount: analyses.length + (_inlineMessage == null ? 0 : 1),
              itemBuilder: (context, index) {
                if (_inlineMessage != null && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AnaSoilSpacing.md),
                    child: AnaSoilInlineMessage(
                      message: _inlineMessage!,
                      icon: _inlineTone == AnaSoilStatusTone.danger
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      tone: _inlineTone,
                    ),
                  );
                }

                final analysisIndex = _inlineMessage == null
                    ? index
                    : index - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AnaSoilSpacing.md),
                  child: _AnalysisHistoryCard(
                    analysis: analyses[analysisIndex],
                    onOpen: () => context.push(
                      '/analysis/detail',
                      extra: analyses[analysisIndex],
                    ),
                    onDelete: () => _deleteAnalysis(analyses[analysisIndex]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnalysisHistoryCard extends StatelessWidget {
  final SoilAnalysis analysis;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _AnalysisHistoryCard({
    required this.analysis,
    required this.onOpen,
    required this.onDelete,
  });

  String get _dateStr {
    final d = analysis.analysisDate;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AnaSoilRadius.lg),
        child: AnaSoilSurface(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          radius: AnaSoilRadius.lg,
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreenSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.grass,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AnaSoilSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.propertyName.isNotEmpty
                              ? analysis.propertyName
                              : 'Análise ${analysis.labNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.baseGray900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.baseGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.secondaryRed,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (analysis.requester != null ||
                  analysis.stakeholder != null) ...[
                const SizedBox(height: 10),
                if (analysis.requester != null)
                  _InfoRow(Icons.business, analysis.requester!),
              ],
              const SizedBox(height: 10),
              AnaSoilStatusChip(
                label: 'Amostra ${analysis.labNumber}',
                tone: AnaSoilStatusTone.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.baseGray500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppTheme.baseGray600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
