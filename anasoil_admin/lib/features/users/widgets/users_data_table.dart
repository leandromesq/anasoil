import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

const double _kTableBreakpoint = 800;

class UsersDataTable extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(UserModel, bool) onStatusChanged;
  final Function(UserModel) onManageRelations;
  final bool isLoading;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

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
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AnaSoilSkeletonTable();
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.group, size: 64, color: AppTheme.baseGray400),
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
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppTheme.baseGray900.withValues(alpha: 0.05),
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
                topLeft: Radius.circular(AnaSoilRadius.md),
                topRight: Radius.circular(AnaSoilRadius.md),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Symbols.group, size: 20, color: AppTheme.baseGray600),
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
                if (isRefreshing)
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.baseGray600,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(Symbols.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Atualizar',
                  ),
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < _kTableBreakpoint;
                if (isMobile) {
                  return _MobileList(
                    users: users,
                    onEdit: onEdit,
                    onStatusChanged: onStatusChanged,
                    onManageRelations: onManageRelations,
                  );
                }
                return _DesktopTable(
                  users: users,
                  onEdit: onEdit,
                  onStatusChanged: onStatusChanged,
                  onManageRelations: onManageRelations,
                  sortColumn: sortColumn,
                  sortAscending: sortAscending,
                  onSort: onSort,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Mobile card list
// ============================================================================

class _MobileList extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(UserModel, bool) onStatusChanged;
  final Function(UserModel) onManageRelations;

  const _MobileList({
    required this.users,
    required this.onEdit,
    required this.onStatusChanged,
    required this.onManageRelations,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getRoleColor(user.role),
                      child: Icon(
                        _getRoleIcon(user.role),
                        color: AppTheme.baseWhite,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: user.active
                                  ? AppTheme.baseGray900
                                  : AppTheme.baseGray400,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.baseGray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getRoleColor(
                            user.role,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _getRoleDisplayName(user.role),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            user.active ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: user.active
                                  ? AppTheme.primaryGreen
                                  : AppTheme.baseGray500,
                            ),
                          ),
                        ),
                        Switch(
                          value: user.active,
                          onChanged: (value) => onStatusChanged(user, value),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (user.userRole.canManageRelations)
                          IconButton(
                            onPressed: () => onManageRelations(user),
                            icon: Icon(Symbols.link, size: 20),
                            color: AppTheme.baseGray600,
                            tooltip: 'Relações',
                          ),
                        IconButton(
                          onPressed: () => onEdit(user),
                          icon: Icon(Symbols.edit, size: 20),
                          color: AppTheme.primaryGreen,
                          tooltip: 'Editar',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (UserRole.parse(role)) {
      case UserRole.admin:
        return AppTheme.secondaryRed;
      case UserRole.consultant:
        return AppTheme.primaryGreenLight;
      case UserRole.farmer:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (UserRole.parse(role)) {
      case UserRole.admin:
        return Symbols.admin_panel_settings;
      case UserRole.consultant:
        return Symbols.account_circle;
      case UserRole.farmer:
        return Symbols.eco;
    }
  }

  String _getRoleDisplayName(String role) => UserRole.parse(role).displayName;
}

// ============================================================================
// Desktop data table
// ============================================================================

class _DesktopTable extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(UserModel, bool) onStatusChanged;
  final Function(UserModel) onManageRelations;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;

  const _DesktopTable({
    required this.users,
    required this.onEdit,
    required this.onStatusChanged,
    required this.onManageRelations,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final margins = 24.0 * 2;
        final spacing = 16.0 * 4;
        final totalCellWidth = availableWidth > margins + spacing + 600
            ? availableWidth - margins - spacing
            : 600.0;

        final colWidths = [
          totalCellWidth * 0.35,
          totalCellWidth * 0.15,
          totalCellWidth * 0.20,
          totalCellWidth * 0.15,
          totalCellWidth * 0.15,
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: availableWidth,
              maxHeight: constraints.maxHeight,
            ),
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
                        ? (columnIndex, ascending) => onSort!(columnIndex)
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
                        ? (columnIndex, ascending) => onSort!(columnIndex)
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
                        ? (columnIndex, ascending) => onSort!(columnIndex)
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
                        ? (columnIndex, ascending) => onSort!(columnIndex)
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
                    .map((user) => _buildUserRow(user, context, colWidths))
                    .toList(),
              ),
            ),
        );
      },
    );
  }

  DataRow _buildUserRow(
    UserModel user,
    BuildContext context,
    List<double> colWidths,
  ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: colWidths[0],
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
            width: colWidths[1],
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
            width: colWidths[2],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    user.active ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      color: user.active
                          ? AppTheme.primaryGreen
                          : AppTheme.baseGray500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
            width: colWidths[3],
            child: Text(
              _formatDate(user.createdAt),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),

        DataCell(
          SizedBox(
            width: colWidths[4],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.userRole.canManageRelations)
                  IconButton(
                    onPressed: () => onManageRelations(user),
                    icon: Icon(Symbols.link, size: 18),
                    color: AppTheme.baseGray600,
                    tooltip: 'Gerenciar Relações',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                IconButton(
                  onPressed: () => onEdit(user),
                  icon: Icon(Symbols.edit, size: 18),
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
    switch (UserRole.parse(role)) {
      case UserRole.admin:
        return AppTheme.secondaryRed;
      case UserRole.consultant:
        return AppTheme.primaryGreenLight;
      case UserRole.farmer:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (UserRole.parse(role)) {
      case UserRole.admin:
        return Symbols.admin_panel_settings;
      case UserRole.consultant:
        return Symbols.account_circle;
      case UserRole.farmer:
        return Symbols.eco;
    }
  }

  String _getRoleDisplayName(String role) => UserRole.parse(role).displayName;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
