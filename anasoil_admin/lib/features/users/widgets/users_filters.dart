import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
          // Header
          Row(
            children: [
              Icon(
                PhosphorIcons.funnel(),
                color: AppTheme.baseGray600,
                size: 20,
              ),
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
                  icon: Icon(PhosphorIcons.x(), size: 16),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: searchText,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome ou email',
                    prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 16),

              // Status Filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(PhosphorIcons.toggleLeft()),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'todos',
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: 'ativo',
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.checkCircle(),
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
                            PhosphorIcons.xCircle(),
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
                ),
              ),
              const SizedBox(width: 16),

              // Role Filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: roleFilter,
                  decoration: InputDecoration(
                    labelText: 'Função',
                    prefixIcon: Icon(PhosphorIcons.briefcase()),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'todos',
                      child: Text('Todas'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.shieldCheck(),
                            color: AppTheme.secondaryRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Administrador'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'consultor',
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.userCircle(),
                            color: const Color(0xFF3B82F6),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Consultor'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'agricultor',
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.plant(),
                            color: AppTheme.primaryGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Agricultor'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => onRoleFilterChanged(value ?? 'todos'),
                ),
              ),
            ],
          ),

          // Active filters indicator
          if (hasActiveFilters) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (searchText.isNotEmpty)
                  Chip(
                    label: Text('Nome: "$searchText"'),
                    onDeleted: () => onSearchChanged(''),
                    deleteIcon: Icon(PhosphorIcons.x(), size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
                if (statusFilter != 'todos')
                  Chip(
                    label: Text(
                      'Status: ${_getStatusDisplayName(statusFilter)}',
                    ),
                    onDeleted: () => onStatusFilterChanged('todos'),
                    deleteIcon: Icon(PhosphorIcons.x(), size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
                if (roleFilter != 'todos')
                  Chip(
                    label: Text('Função: ${_getRoleDisplayName(roleFilter)}'),
                    onDeleted: () => onRoleFilterChanged('todos'),
                    deleteIcon: Icon(PhosphorIcons.x(), size: 16),
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
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'consultor':
        return 'Consultor';
      case 'agricultor':
        return 'Agricultor';
      default:
        return 'Todas';
    }
  }
}
