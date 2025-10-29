import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';

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
              const Icon(
                Icons.filter_list,
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
                  icon: const Icon(Icons.clear_all, size: 16),
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
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar por nome ou email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.toggle_on),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'ativo',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryGreen,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('Ativos'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'inativo',
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: AppTheme.secondaryRed,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('Inativos'),
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
                  decoration: const InputDecoration(
                    labelText: 'Função',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todas')),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: AppTheme.secondaryRed,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('Administrador'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'consultor',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_search,
                            color: Color(0xFF3B82F6),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('Consultor'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'agricultor',
                      child: Row(
                        children: [
                          Icon(
                            Icons.agriculture,
                            color: AppTheme.primaryGreen,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('Agricultor'),
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
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
                if (statusFilter != 'todos')
                  Chip(
                    label: Text(
                      'Status: ${_getStatusDisplayName(statusFilter)}',
                    ),
                    onDeleted: () => onStatusFilterChanged('todos'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: AppTheme.baseGray100,
                  ),
                if (roleFilter != 'todos')
                  Chip(
                    label: Text('Função: ${_getRoleDisplayName(roleFilter)}'),
                    onDeleted: () => onRoleFilterChanged('todos'),
                    deleteIcon: const Icon(Icons.close, size: 16),
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
