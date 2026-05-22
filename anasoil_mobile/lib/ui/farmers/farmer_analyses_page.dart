import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/user.dart';
import '../../domain/models/soil_analysis.dart';
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
      backgroundColor: AppTheme.baseGray50,
      appBar: AppBar(
        title: Text(widget.farmer.name),
        backgroundColor: AppTheme.baseWhite,
        foregroundColor: AppTheme.baseGray900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_isLoading) {
            return const AnaSoilLoadingState(message: 'Carregando análises...');
          }

          if (_error != null) {
            return AnaSoilEmptyState(
              icon: Icons.error_outline,
              title: 'Erro ao carregar análises',
              message: 'Verifique a conexão e tente buscar novamente.',
              actionLabel: 'Tentar novamente',
              onAction: _loadAnalyses,
            );
          }

          final analyses = _viewModel.farmerAnalyses;
          if (analyses.isEmpty) {
            return const AnaSoilEmptyState(
              icon: Icons.history,
              title: 'Nenhuma análise encontrada',
              message:
                  'Este agricultor ainda não possui análises de solo registradas.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAnalyses,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AnaSoilSpacing.lg),
              itemCount: analyses.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FarmerHeader(farmer: widget.farmer);
                }
                final analysisIndex = index - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AnaSoilSpacing.md),
                  child: _FarmerAnalysisCard(
                    analysis: analyses[analysisIndex],
                    onTap: () => context.push(
                      '/analysis/detail',
                      extra: analyses[analysisIndex],
                    ),
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

class _FarmerHeader extends StatelessWidget {
  final User farmer;

  const _FarmerHeader({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = farmer.avatarUrl != null && farmer.avatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AnaSoilSpacing.lg),
      child: AnaSoilSurface(
        padding: const EdgeInsets.all(AnaSoilSpacing.lg),
        radius: AnaSoilRadius.lg,
        backgroundColor: AppTheme.primaryGreenSoft,
        borderColor: AppTheme.primaryGreenLight.withValues(alpha: 0.25),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryGreenLight,
              backgroundImage: hasAvatar
                  ? NetworkImage(farmer.avatarUrl!)
                  : null,
              child: !hasAvatar
                  ? const Icon(
                      Icons.person,
                      color: AppTheme.baseWhite,
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(width: AnaSoilSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.baseGray900,
                    ),
                  ),
                  const SizedBox(height: AnaSoilSpacing.xs),
                  Text(
                    farmer.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.baseGray600,
                    ),
                  ),
                  if (farmer.phone != null && farmer.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      farmer.phone!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.baseGray500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerAnalysisCard extends StatelessWidget {
  final SoilAnalysis analysis;
  final VoidCallback onTap;

  const _FarmerAnalysisCard({required this.analysis, required this.onTap});

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
        onTap: onTap,
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
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.baseGray400,
                    size: 16,
                  ),
                ],
              ),
              if (analysis.requester != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 14,
                      color: AppTheme.baseGray500,
                    ),
                    const SizedBox(width: AnaSoilSpacing.xs),
                    Expanded(
                      child: Text(
                        analysis.requester!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.baseGray600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
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
