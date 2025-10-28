import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';

class UsersDataTable extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(UserModel) onDelete;
  final Function(UserModel) onManageRelations;
  final bool isLoading;

  const UsersDataTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
    required this.onManageRelations,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.baseGray400),
            const SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.baseGray500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Novo Usuário" para adicionar o primeiro usuário',
              style: TextStyle(fontSize: 14, color: AppTheme.baseGray400),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.baseWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.baseGray50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.people, size: 20, color: AppTheme.baseGray600),
                const SizedBox(width: 8),
                Text(
                  'Usuários (${users.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.baseGray900,
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 32,
                horizontalMargin: 24,
                headingRowHeight: 56,
                dataRowMaxHeight: 72,
                headingRowColor: const WidgetStatePropertyAll(
                  AppTheme.baseWhite,
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Usuário',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Função',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Criado em',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ações',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ),
                ],
                rows: users
                    .map((user) => _buildUserRow(user, context))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(UserModel user, BuildContext context) {
    return DataRow(
      cells: [
        // User Info
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _getRoleColor(user.role),
                child: Icon(
                  _getRoleIcon(user.role),
                  color: AppTheme.baseWhite,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: user.active
                            ? AppTheme.baseGray900
                            : AppTheme.baseGray400,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: user.active
                            ? AppTheme.baseGray600
                            : AppTheme.baseGray400,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Role
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getRoleColor(user.role).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Status
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.active
                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                  : AppTheme.secondaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: user.active
                    ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                    : AppTheme.secondaryRed.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: user.active
                        ? AppTheme.primaryGreen
                        : AppTheme.secondaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.active ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: user.active
                        ? AppTheme.primaryGreen
                        : AppTheme.secondaryRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Created Date
        DataCell(
          Text(
            _formatDate(user.createdAt),
            style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
          ),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.role == 'agricultor' || user.role == 'consultor')
                IconButton(
                  onPressed: () => onManageRelations(user),
                  icon: const Icon(Icons.link, size: 18),
                  color: AppTheme.baseGray600,
                  tooltip: 'Gerenciar Relações',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              IconButton(
                onPressed: () => onEdit(user),
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppTheme.primaryGreen,
                tooltip: 'Editar',
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
              IconButton(
                onPressed: () => onDelete(user),
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppTheme.secondaryRed,
                tooltip: 'Excluir',
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return AppTheme.secondaryRed;
      case 'consultor':
        return const Color(0xFF3B82F6); // Azul
      case 'agricultor':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.baseGray500;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings;
      case 'consultor':
        return Icons.person_search;
      case 'agricultor':
        return Icons.agriculture;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return 'Administrador';
      case 'consultor':
        return 'Consultor';
      case 'agricultor':
        return 'Agricultor';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
