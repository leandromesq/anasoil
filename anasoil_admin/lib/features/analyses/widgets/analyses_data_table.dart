import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/analyses/viewmodels/analysis_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/service_locator.dart';

const double _kTableBreakpoint = 700;

class AnalysesDataTable extends StatelessWidget {
  final List<SoilAnalysisModel> analyses;
  final Map<String, String> userNames;
  final Function(SoilAnalysisModel) onDelete;
  final bool isLoading;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;

  const AnalysesDataTable({
    super.key,
    required this.analyses,
    required this.userNames,
    required this.onDelete,
    this.isLoading = false,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = locator<AnalysisListViewModel>();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analyses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.monitoring, size: 64, color: AppTheme.baseGray400),
            const SizedBox(height: 16),
            Text(
              'Nenhuma análise encontrada',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.baseGray500,
                fontWeight: FontWeight.w500,
              ),
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
                      Symbols.monitoring,
                      size: 20,
                      color: AppTheme.baseGray600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Análises (${analyses.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ],
                ),
                ListenableBuilder(
                  listenable: viewModel.fetchAnalysesCommand,
                  builder: (context, _) {
                    if (viewModel.fetchAnalysesCommand.value.isRunning) {
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
                      icon: Icon(Symbols.refresh),
                      onPressed: viewModel.fetchAnalysesCommand.execute,
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
                final isMobile = constraints.maxWidth < _kTableBreakpoint;
                if (isMobile) {
                  return _MobileList(
                    analyses: analyses,
                    userNames: userNames,
                    onDelete: onDelete,
                  );
                }
                return _DesktopTable(
                  analyses: analyses,
                  userNames: userNames,
                  onDelete: onDelete,
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
  final List<SoilAnalysisModel> analyses;
  final Map<String, String> userNames;
  final Function(SoilAnalysisModel) onDelete;

  const _MobileList({
    required this.analyses,
    required this.userNames,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        final userName = userNames[analysis.userId] ?? analysis.userId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go('/analysis/${analysis.id}'),
            borderRadius: BorderRadius.circular(12),
            hoverColor: AppTheme.primaryGreenLight.withValues(alpha: 0.06),
            mouseCursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Symbols.eco,
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          analysis.propertyName.isNotEmpty
                              ? analysis.propertyName
                              : analysis.labNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view') {
                            context.go('/analysis/${analysis.id}');
                          } else if (value == 'delete') {
                            onDelete(analysis);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('Visualizar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Usuário', userName),
                  _buildInfoRow('Laudo', analysis.labNumber),
                  _buildInfoRow('Data', _formatDate(analysis.analysisDate)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: AppTheme.baseGray500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ============================================================================
// Desktop data table
// ============================================================================

class _DesktopTable extends StatelessWidget {
  final List<SoilAnalysisModel> analyses;
  final Map<String, String> userNames;
  final Function(SoilAnalysisModel) onDelete;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;

  const _DesktopTable({
    required this.analyses,
    required this.userNames,
    required this.onDelete,
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
        final totalCellWidth = availableWidth > margins + spacing + 640
            ? availableWidth - margins - spacing
            : 640.0;

        final colWidths = [
          totalCellWidth * 0.32,
          totalCellWidth * 0.24,
          totalCellWidth * 0.14,
          totalCellWidth * 0.15,
          totalCellWidth * 0.15,
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: availableWidth),
              child: DataTable(
                sortColumnIndex: sortColumn,
                sortAscending: sortAscending,
                showCheckboxColumn: false,
                columnSpacing: 16,
                horizontalMargin: 24,
                headingRowHeight: 56,
                dataRowMaxHeight: 72,
                dataRowMinHeight: 72,
                headingRowColor: const WidgetStatePropertyAll(
                  AppTheme.baseWhite,
                ),
                columns: [
                  DataColumn(
                    label: const Text(
                      'Propriedade',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    onSort: onSort != null
                        ? (columnIndex, _) => onSort!(columnIndex)
                        : null,
                  ),
                  DataColumn(
                    label: const Text(
                      'Usuário',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    onSort: onSort != null
                        ? (columnIndex, _) => onSort!(columnIndex)
                        : null,
                  ),
                  DataColumn(
                    label: const Text(
                      'Amostra',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    onSort: onSort != null
                        ? (columnIndex, _) => onSort!(columnIndex)
                        : null,
                  ),
                  DataColumn(
                    label: const Text(
                      'Data Análise',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    onSort: onSort != null
                        ? (columnIndex, _) => onSort!(columnIndex)
                        : null,
                  ),
                  const DataColumn(
                    label: Text(
                      'Ações',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ),
                ],
                rows: analyses
                    .map((a) => _buildRow(a, context, colWidths))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(
    SoilAnalysisModel analysis,
    BuildContext context,
    List<double> colWidths,
  ) {
    final userName = userNames[analysis.userId] ?? analysis.userId;

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppTheme.primaryGreenLight.withValues(alpha: 0.05);
        }
        return null;
      }),
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      onSelectChanged: (_) => context.go('/analysis/${analysis.id}'),
      cells: [
        DataCell(
          SizedBox(
            width: colWidths[0],
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Symbols.eco,
                    color: AppTheme.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analysis.propertyName.isNotEmpty
                        ? analysis.propertyName
                        : analysis.labNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.baseGray900,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: colWidths[1],
            child: Text(
              userName,
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: colWidths[2],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primaryGreenLight.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  analysis.labNumber,
                  style: const TextStyle(
                    color: AppTheme.primaryGreenDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: colWidths[3],
            child: Text(
              _formatDate(analysis.analysisDate),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: colWidths[4],
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/analysis/${analysis.id}'),
                  icon: Icon(Symbols.visibility, size: 18),
                  color: AppTheme.primaryGreen,
                  tooltip: 'Visualizar',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
                IconButton(
                  onPressed: () => onDelete(analysis),
                  icon: Icon(Symbols.delete, size: 18),
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
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
