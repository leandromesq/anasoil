import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/soil_analysis.dart';
import '../../domain/models/user.dart';
import '../auth/auth_viewmodel.dart';
import '../farmers/farmers_viewmodel.dart';
import '../../domain/models/profile_type.dart';
import 'analysis_viewmodel.dart';

/// Tela principal do app (Home)
class HomePage extends StatelessWidget {
  final AuthViewModel authViewModel;
  final ValueChanged<int> onNavigateToTab;

  const HomePage({
    super.key,
    required this.authViewModel,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      body: ListenableBuilder(
        listenable: authViewModel,
        builder: (context, _) {
          final user = authViewModel.currentUser;
          return _buildContent(context, user);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AnaSoilSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.baseGray900,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.xs),
              if (user != null)
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.baseGray500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AnaSoilSpacing.xl),
          _buildMainAnalysisCard(context),
          const SizedBox(height: AnaSoilSpacing.lg),
          _buildQuickActions(context),
          if (user?.profileType == ProfileType.consultant) ...[
            const SizedBox(height: AnaSoilSpacing.lg),
            _buildFarmersCard(context),
          ],
          const SizedBox(height: AnaSoilSpacing.xl),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildMainAnalysisCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNavigateToTab(1),
        borderRadius: BorderRadius.circular(AnaSoilRadius.lg),
        child: AnaSoilSurface(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          radius: AnaSoilRadius.lg,
          borderColor: AppTheme.primaryGreenLight.withValues(alpha: 0.35),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AnaSoilSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.baseWhite,
                  size: 40,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.lg),
              const Text(
                'Iniciar Nova Análise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.baseGray900,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.xs),
              const Text(
                'Importe um PDF com análise de solo para extrair e salvar amostras.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.baseGray600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.bar_chart,
            title: 'Histórico',
            subtitle: 'Análises salvas',
            onTap: () => onNavigateToTab(2),
          ),
        ),
        const SizedBox(width: AnaSoilSpacing.md),
        Expanded(
          child: _buildActionCard(
            icon: Icons.folder,
            title: 'Documentos',
            subtitle: 'PDFs importados',
            onTap: () => context.push('/documents'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        child: AnaSoilSurface(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          radius: AnaSoilRadius.md,
          backgroundColor: AppTheme.primaryGreenSoft,
          borderColor: AppTheme.primaryGreenLight.withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 32),
              const SizedBox(height: AnaSoilSpacing.md),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.baseGray900,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.xs),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.baseGray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmersCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/farmers'),
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        child: AnaSoilSurface(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          radius: AnaSoilRadius.md,
          backgroundColor: AppTheme.primaryGreenSoft,
          borderColor: AppTheme.primaryGreenLight.withValues(alpha: 0.25),
          child: Row(
            children: [
              const Icon(Icons.people, color: AppTheme.primaryGreen, size: 32),
              const SizedBox(width: AnaSoilSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus Agricultores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    SizedBox(height: AnaSoilSpacing.xs),
                    Text(
                      'Análises dos seus clientes',
                      style: TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final viewModel = getIt<AnalysisViewModel>();
    final farmersViewModel = getIt<FarmersViewModel>();
    final isConsultant =
        authViewModel.currentUser?.profileType.name == 'consultant';

    if (isConsultant) {
      final userId = authViewModel.currentUser?.id;
      if (userId != null && farmersViewModel.allFarmersAnalyses.isEmpty) {
        farmersViewModel.loadAllFarmersAnalyses(userId);
      }
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: farmersViewModel,
          builder: (context, _) {
            final userAnalyses = viewModel.savedAnalyses;
            final farmerAnalyses = isConsultant
                ? farmersViewModel.allFarmersAnalyses
                : <SoilAnalysis>[];

            final allAnalyses = [...userAnalyses, ...farmerAnalyses];
            allAnalyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atividade Recente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.baseGray900,
                  ),
                ),
                const SizedBox(height: AnaSoilSpacing.md),
                if (allAnalyses.isEmpty)
                  AnaSoilEmptyState(
                    icon: Icons.history,
                    title: 'Nenhuma análise realizada',
                    message:
                        'Importe um PDF de análise de solo na aba Análise para começar seu histórico.',
                    actionLabel: 'Ir para nova análise',
                    onAction: () => onNavigateToTab(1),
                  )
                else
                  _buildActivityList(
                    context,
                    allAnalyses.take(5).toList(),
                    viewModel,
                    farmersViewModel,
                    isConsultant,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    List<SoilAnalysis> recent,
    AnalysisViewModel viewModel,
    FarmersViewModel farmersViewModel,
    bool isConsultant,
  ) {
    final currentUserId = authViewModel.currentUser?.id;

    return Column(
      children: [
        for (var i = 0; i < recent.length; i++) ...[
          if (i > 0) const SizedBox(height: AnaSoilSpacing.sm),
          _ActivityItem(
            analysis: recent[i],
            onTap: () => context.push('/analysis/detail', extra: recent[i]),
            subtitle: _buildActivitySubtitle(
              recent[i],
              currentUserId,
              isConsultant,
              farmersViewModel,
            ),
          ),
        ],
      ],
    );
  }

  String _buildActivitySubtitle(
    SoilAnalysis analysis,
    String? currentUserId,
    bool isConsultant,
    FarmersViewModel farmersViewModel,
  ) {
    final timeStr = _timeAgo(analysis.createdAt);
    if (isConsultant && analysis.userId != currentUserId) {
      final farmerName = farmersViewModel.getFarmerName(analysis.userId);
      if (farmerName.isNotEmpty) {
        return '$timeStr · $farmerName';
      }
    }
    return timeStr;
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? 'Há 1 hora' : 'Há ${diff.inHours} horas';
    }
    if (diff.inDays < 7) {
      return diff.inDays == 1 ? 'Ontem' : 'Há ${diff.inDays} dias';
    }
    if (diff.inDays < 30) {
      final weeks = diff.inDays ~/ 7;
      return weeks == 1 ? 'Há 1 semana' : 'Há $weeks semanas';
    }
    final months = diff.inDays ~/ 30;
    return months == 1 ? 'Há 1 mês' : 'Há $months meses';
  }
}

class _ActivityItem extends StatelessWidget {
  final SoilAnalysis analysis;
  final VoidCallback onTap;
  final String subtitle;

  const _ActivityItem({
    required this.analysis,
    required this.onTap,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        child: AnaSoilSurface(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          radius: AnaSoilRadius.md,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AnaSoilSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
        ),
      ),
    );
  }
}
