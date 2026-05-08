import 'package:anasoil_admin/core/theme/app_theme.dart';
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
    this.mobileBreakpoint = 700,
  });

  @override
  Widget build(BuildContext context) {
    if (!tableReady || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emptyIcon ??
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppTheme.baseGray400,
                ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
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
              Icon(titleIcon, size: 20, color: AppTheme.baseGray600),
              const SizedBox(width: 8),
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
