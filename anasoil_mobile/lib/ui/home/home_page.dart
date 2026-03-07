import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_viewmodel.dart';

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
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bem-vindo
            const Text(
              'Bem-vindo de volta!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Card principal - Iniciar Nova Análise
            _buildMainAnalysisCard(context),
            const SizedBox(height: 16),

            // Cards menores - Histórico e Documentos
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.bar_chart,
                    title: 'Histórico',
                    subtitle: '',
                    color: Colors.green[700]!,
                    onTap: () {
                      // TODO: Navegar para histórico
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.folder,
                    title: 'Documentos',
                    subtitle: '',
                    color: Colors.green[700]!,
                    onTap: () {
                      context.push('/documents');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meus Agricultores (somente para consultores)
            ListenableBuilder(
              listenable: authViewModel,
              builder: (context, _) {
                final user = authViewModel.currentUser;
                if (user?.profileType.name == 'consultant') {
                  return Column(
                    children: [
                      _buildFarmersCard(context),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox(height: 24);
              },
            ),

            // Atividade Recente
            const Text(
              'Atividade Recente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAnalysisCard(BuildContext context) {
    return GestureDetector(
      onTap: () => onNavigateToTab(1),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Iniciar Nova Análise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFarmersCard(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navegar para lista de agricultores
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline, color: Colors.green[700], size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meus Agricultores',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Meus clientes',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _buildActivityItem(
          title: 'Análise Solo - Fazenda Norte',
          subtitle: 'Há 2 horas',
          icon: Icons.description,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          title: 'Relatório Nutrientes - Lote 15',
          subtitle: 'Ontem',
          icon: Icons.description,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          title: 'Análise pH - Setor A',
          subtitle: '3 dias atrás',
          icon: Icons.description,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.red[700], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }
}
