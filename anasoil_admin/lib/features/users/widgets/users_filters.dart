import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class UsersFilters extends StatelessWidget {
  final String searchText;
  final String statusFilter;
  final String roleFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final ValueChanged<String> onRoleFilterChanged;
  final VoidCallback onClearFilters;

  const UsersFilters({
    super.key,
    required this.searchText,
    required this.statusFilter,
    required this.roleFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onRoleFilterChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        searchText.isNotEmpty ||
        statusFilter != 'todos' ||
        roleFilter != 'todos';

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.filter_list, color: AppTheme.baseGray600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.baseGray900,
                ),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: Icon(Symbols.close, size: 16),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;

              final searchField = TextFormField(
                initialValue: searchText,
                decoration: InputDecoration(
                  labelText: 'Pesquisar por nome ou email',
                  prefixIcon: Icon(Symbols.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: onSearchChanged,
              );

              final statusDropdown = DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: statusFilter,
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Symbols.toggle_off),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                  DropdownMenuItem(
                    value: 'ativo',
                    child: Row(
                      children: [
                        Icon(
                          Symbols.check_circle,
                          color: AppTheme.primaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('Ativos'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'inativo',
                    child: Row(
                      children: [
                        Icon(
                          Symbols.cancel,
                          color: AppTheme.secondaryRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('Inativos'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => onStatusFilterChanged(value ?? 'todos'),
              );

              final roleDropdown = DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: roleFilter,
                decoration: InputDecoration(
                  labelText: 'Função',
                  prefixIcon: Icon(Symbols.work),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'todos', child: Text('Todas')),
                  ...UserRole.assignable.map(
                    (role) => DropdownMenuItem(
                      value: role.firestoreValue,
                      child: Row(
                        children: [
                          Icon(
                            _getRoleIcon(role),
                            color: _getRoleColor(role),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(role.displayName),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => onRoleFilterChanged(value ?? 'todos'),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    statusDropdown,
                    const SizedBox(height: 12),
                    roleDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: searchField),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: statusDropdown),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: roleDropdown),
                ],
              );
            },
          ),

          if (hasActiveFilters) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (searchText.isNotEmpty)
                  Chip(
                    label: Text('Nome: "$searchText"'),
                    onDeleted: () => onSearchChanged(''),
                    deleteIcon: Icon(Symbols.close, size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
                if (statusFilter != 'todos')
                  Chip(
                    label: Text(
                      'Status: ${_getStatusDisplayName(statusFilter)}',
                    ),
                    onDeleted: () => onStatusFilterChanged('todos'),
                    deleteIcon: Icon(Symbols.close, size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
                if (roleFilter != 'todos')
                  Chip(
                    label: Text('Função: ${_getRoleDisplayName(roleFilter)}'),
                    onDeleted: () => onRoleFilterChanged('todos'),
                    deleteIcon: Icon(Symbols.close, size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'ativo':
        return 'Ativos';
      case 'inativo':
        return 'Inativos';
      default:
        return 'Todos';
    }
  }

  String _getRoleDisplayName(String role) {
    if (role == 'todos') return 'Todas';
    return UserRole.parse(role).displayName;
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Symbols.admin_panel_settings;
      case UserRole.consultant:
        return Symbols.account_circle;
      case UserRole.farmer:
        return Symbols.eco;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.secondaryRed;
      case UserRole.consultant:
        return AppTheme.primaryGreenLight;
      case UserRole.farmer:
        return AppTheme.primaryGreen;
    }
  }
}
