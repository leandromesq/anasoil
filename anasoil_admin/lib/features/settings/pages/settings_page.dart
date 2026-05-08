import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();

    return AppLayout(
      title: 'Configurações',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildSectionTitle(context, 'Conta'),
              _buildCard(
                context,
                child: ListTile(
                  leading: Icon(
                    PhosphorIcons.signOut(),
                    color: AppTheme.secondaryRed,
                  ),
                  title: const Text('Sair'),
                  subtitle: Text(
                    authService.currentUser?.email ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar saída'),
                        content: const Text(
                          'Deseja realmente sair do sistema?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Sair',
                              style: TextStyle(color: AppTheme.secondaryRed),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await authService.signOut();
                      if (context.mounted) context.go('/login');
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Sobre'),
              _buildCard(
                context,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        PhosphorIcons.info(),
                        color: AppTheme.primaryGreen,
                      ),
                      title: Text('AnaSoil Admin'),
                      subtitle: Text('Versão 1.0.0'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        PhosphorIcons.leaf(),
                        color: AppTheme.primaryGreen,
                      ),
                      title: Text('Sistema de Análise de Solo'),
                      subtitle: Text(
                        'Gestão de usuários, documentos e análises',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.baseGray500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      child: child,
    );
  }
}
