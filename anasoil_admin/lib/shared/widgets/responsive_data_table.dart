import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

/// Reusable responsive data table that handles:
/// - First-frame ready delay
/// - Loading / empty states
/// - Desktop table vs mobile card switch
/// - Sort and hover
class ResponsiveDataTable extends StatelessWidget {
  final List<ResponsiveColumn> columns;
  final List<ResponsiveRow> rows;
  final String title;
  final IconData titleIcon;
  final bool isLoading;
  final bool tableReady;
  final String emptyMessage;
  final Widget? emptyIcon;
  final int? sortColumn;
  final bool sortAscending;
  final ValueChanged<int>? onSort;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final double mobileBreakpoint;

  const ResponsiveDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.title,
    required this.titleIcon,
    this.isLoading = false,
    this.tableReady = true,
    this.emptyMessage = 'Nenhum registro encontrado',
    this.emptyIcon,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
    this.onRefresh,
    this.isRefreshing = false,
    this.mobileBreakpoint = AnaSoilBreakpoints.mobile,
  });

  @override
  Widget build(BuildContext context) {
    if (!tableReady || isLoading) {
      return const AnaSoilLoadingState(message: 'Carregando registros...');
    }

    if (rows.isEmpty) {
      return AnaSoilEmptyState(
        icon: emptyIcon is Icon
            ? (emptyIcon as Icon).icon ?? Icons.inbox_outlined
            : Icons.inbox_outlined,
        title: emptyMessage,
        message: 'Ajuste os filtros ou atualize a lista para buscar novamente.',
        actionLabel: onRefresh == null ? null : 'Atualizar',
        onAction: onRefresh,
      );
    }

    return AnaSoilSurface(
      width: double.infinity,
      padding: EdgeInsets.zero,
      radius: AnaSoilRadius.md,
      elevated: true,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < mobileBreakpoint;
                if (isMobile) {
                  return _MobileCardList(rows: rows);
                }
                return _DesktopTable(
                  columns: columns,
                  rows: rows,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AnaSoilSpacing.xl),
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
              Icon(titleIcon, size: 20, color: AppTheme.baseGray600),
              const SizedBox(width: AnaSoilSpacing.sm),
              Text(
                '$title (${rows.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.baseGray900,
                ),
              ),
            ],
          ),
          if (onRefresh != null)
            isRefreshing
                ? Container(
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
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Atualizar',
                  ),
        ],
      ),
    );
  }
}

class _MobileCardList extends StatelessWidget {
  final List<ResponsiveRow> rows;

  const _MobileCardList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        return rows[index].mobileCardBuilder(context);
      },
    );
  }
}

class _DesktopTable extends StatelessWidget {
  final List<ResponsiveColumn> columns;
  final List<ResponsiveRow> rows;
  final int? sortColumn;
  final bool sortAscending;
  final ValueChanged<int>? onSort;

  const _DesktopTable({
    required this.columns,
    required this.rows,
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
        final spacing = 16.0 * (columns.length - 1);
        final totalCellWidth = availableWidth > margins + spacing + 500
            ? availableWidth - margins - spacing
            : 500.0;

        final colWidths = columns
            .map((c) => totalCellWidth * c.fraction)
            .toList();

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
                  for (var i = 0; i < columns.length; i++)
                    DataColumn(
                      label: Text(
                        columns[i].title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.baseGray900,
                        ),
                      ),
                      onSort: onSort != null && columns[i].sortable
                          ? (_, _) => onSort!(i)
                          : null,
                    ),
                ],
                rows: [
                  for (var i = 0; i < rows.length; i++)
                    rows[i].desktopRowBuilder(context, colWidths, i),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveColumn {
  final String title;
  final double fraction;
  final bool sortable;

  const ResponsiveColumn({
    required this.title,
    this.fraction = 0.2,
    this.sortable = true,
  });
}

class ResponsiveRow {
  final DataRow Function(
    BuildContext context,
    List<double> colWidths,
    int index,
  )
  desktopRowBuilder;
  final Widget Function(BuildContext context) mobileCardBuilder;

  const ResponsiveRow({
    required this.desktopRowBuilder,
    required this.mobileCardBuilder,
  });
}
