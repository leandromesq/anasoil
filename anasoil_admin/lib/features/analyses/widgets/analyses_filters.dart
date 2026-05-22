import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class AnalysesFilters extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  const AnalysesFilters({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = searchText.isNotEmpty;

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
          TextFormField(
            initialValue: searchText,
            decoration: InputDecoration(
              labelText: 'Pesquisar por fazenda ou código da amostra',
              prefixIcon: Icon(Symbols.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (searchText.isNotEmpty)
                  Chip(
                    label: Text('Busca: "$searchText"'),
                    onDeleted: () => onSearchChanged(''),
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
}
