import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/analyses/viewmodels/analysis_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/service_locator.dart';

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
            Icon(
              PhosphorIcons.chartLine(),
              size: 64,
              color: AppTheme.baseGray400,
            ),
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
                      PhosphorIcons.chartLine(),
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
                      icon: Icon(PhosphorIcons.arrowClockwise()),
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
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth > 900
                          ? constraints.maxWidth
                          : 900,
                      child: DataTable(
                        sortColumnIndex: sortColumn,
                        sortAscending: sortAscending,
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
                              'Fazenda',
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
                              'DMLab',
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
                            .map((a) => _buildRow(a, context))
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

  DataRow _buildRow(SoilAnalysisModel analysis, BuildContext context) {
    final userName = userNames[analysis.userId] ?? analysis.userId;

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.plant(),
                    color: AppTheme.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analysis.farmName.isNotEmpty
                        ? analysis.farmName
                        : analysis.sampleCode,
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
            width: 150,
            child: Text(
              userName,
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                analysis.dmlabNumber,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
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
            width: 80,
            child: Text(
              analysis.sampleNumber,
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              _formatDate(analysis.analysisDate),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: () => onDelete(analysis),
              icon: Icon(PhosphorIcons.trash(), size: 18),
              color: AppTheme.secondaryRed,
              tooltip: 'Excluir',
              style: IconButton.styleFrom(
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
