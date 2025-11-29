import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/service_locator.dart';

class UsersDataTable extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(UserModel, bool) onStatusChanged;
  final Function(UserModel) onManageRelations;
  final bool isLoading;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;

  const UsersDataTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onStatusChanged,
    required this.onManageRelations,
    this.isLoading = false,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    var viewModel = locator<UserListViewModel>();
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.users(), size: 64, color: AppTheme.baseGray400),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.users(),
                      size: 20,
                      color: AppTheme.baseGray600,
                    ),
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
                ListenableBuilder(
                  listenable: viewModel.fetchUsersCommand,
                  builder: (context, _) {
                    if (viewModel.fetchUsersCommand.value.isRunning) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.baseGray600,
                          ),
                        ),
                      );
                    }
                    return IconButton(
                      icon: Icon(PhosphorIcons.arrowClockwise()),
                      onPressed: viewModel.fetchUsersCommand.execute,
                      tooltip: 'Atualizar',
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth > 800
                          ? constraints.maxWidth
                          : 800,
                      child: DataTable(
                        sortColumnIndex: sortColumn,
                        sortAscending: sortAscending,
                        columnSpacing: 16,
                        horizontalMargin: 24,
                        headingRowHeight: 56,
                        dataRowMaxHeight: 72,
                        headingRowColor: const WidgetStatePropertyAll(
                          AppTheme.baseWhite,
                        ),
                        dataRowMinHeight: 72,
                        columns: [
                          DataColumn(
                            label: const Text(
                              'Usuário',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.baseGray900,
                              ),
                            ),
                            onSort: onSort != null
                                ? (columnIndex, ascending) =>
                                      onSort!(columnIndex)
                                : null,
                          ),
                          DataColumn(
                            label: const Text(
                              'Função',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.baseGray900,
                              ),
                            ),
                            onSort: onSort != null
                                ? (columnIndex, ascending) =>
                                      onSort!(columnIndex)
                                : null,
                          ),
                          DataColumn(
                            label: const Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.baseGray900,
                              ),
                            ),
                            onSort: onSort != null
                                ? (columnIndex, ascending) =>
                                      onSort!(columnIndex)
                                : null,
                          ),
                          DataColumn(
                            label: const Text(
                              'Criado em',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.baseGray900,
                              ),
                            ),
                            onSort: onSort != null
                                ? (columnIndex, ascending) =>
                                      onSort!(columnIndex)
                                : null,
                          ),
                          DataColumn(
                            label: const Text(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(UserModel user, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 280,
            child: Row(
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
        ),

        DataCell(
          SizedBox(
            width: 120,
            child: Container(
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
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        DataCell(
          SizedBox(
            width: 140,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.active ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: user.active
                        ? AppTheme.primaryGreen
                        : AppTheme.baseGray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: user.active,
                  onChanged: (value) => onStatusChanged(user, value),
                  activeThumbColor: AppTheme.primaryGreen,
                  inactiveThumbColor: AppTheme.baseGray400,
                  inactiveTrackColor: AppTheme.baseGray200,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),

        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              _formatDate(user.createdAt),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),

        DataCell(
          SizedBox(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.role == 'agricultor' || user.role == 'consultor')
                  IconButton(
                    onPressed: () => onManageRelations(user),
                    icon: Icon(PhosphorIcons.link(), size: 18),
                    color: AppTheme.baseGray600,
                    tooltip: 'Gerenciar Relações',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                IconButton(
                  onPressed: () => onEdit(user),
                  icon: Icon(PhosphorIcons.pencilSimple(), size: 18),
                  color: AppTheme.primaryGreen,
                  tooltip: 'Editar',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.secondaryRed;
      case 'consultor':
        return const Color(0xFF3B82F6);
      case 'agricultor':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.baseGray500;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return PhosphorIcons.shieldCheck();
      case 'consultor':
        return PhosphorIcons.userCircle();
      case 'agricultor':
        return PhosphorIcons.plant();
      default:
        return PhosphorIcons.user();
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
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
