import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:anasoil_admin/features/documents/viewmodels/document_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/service_locator.dart';

const double _kTableBreakpoint = 700;

class DocumentsDataTable extends StatelessWidget {
  final List<DocumentModel> documents;
  final Map<String, String> userNames;
  final Function(DocumentModel) onDelete;
  final bool isLoading;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;

  const DocumentsDataTable({
    super.key,
    required this.documents,
    required this.userNames,
    required this.onDelete,
    this.isLoading = false,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = locator<DocumentListViewModel>();

    if (isLoading) {
      return const AnaSoilSkeletonTable();
    }

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.folder, size: 64, color: AppTheme.baseGray400),
            const SizedBox(height: 16),
            Text(
              'Nenhum documento encontrado',
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
                    Icon(Symbols.folder, size: 20, color: AppTheme.baseGray600),
                    const SizedBox(width: 8),
                    Text(
                      'Documentos (${documents.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                  ],
                ),
                ListenableBuilder(
                  listenable: viewModel.fetchDocumentsCommand,
                  builder: (context, _) {
                    if (viewModel.fetchDocumentsCommand.value.isRunning) {
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
                      onPressed: viewModel.fetchDocumentsCommand.execute,
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
                    documents: documents,
                    userNames: userNames,
                    onDelete: onDelete,
                  );
                }
                return _DesktopTable(
                  documents: documents,
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
  final List<DocumentModel> documents;
  final Map<String, String> userNames;
  final Function(DocumentModel) onDelete;

  const _MobileList({
    required this.documents,
    required this.userNames,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final userName = userNames[doc.userId] ?? doc.userId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go('/document/${doc.id}'),
            borderRadius: BorderRadius.circular(AnaSoilRadius.md),
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
                          color: AppTheme.primaryGreenSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Symbols.picture_as_pdf,
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          doc.fileName,
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
                            context.go('/document/${doc.id}');
                          } else if (value == 'delete') {
                            onDelete(doc);
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
                  _buildInfoRow('Tamanho', _formatFileSize(doc.fileSize)),
                  _buildInfoRow('Criado em', _formatDate(doc.createdAt)),
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ============================================================================
// Desktop data table
// ============================================================================

class _DesktopTable extends StatelessWidget {
  final List<DocumentModel> documents;
  final Map<String, String> userNames;
  final Function(DocumentModel) onDelete;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int)? onSort;

  const _DesktopTable({
    required this.documents,
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
        final totalCellWidth = availableWidth > margins + spacing + 620
            ? availableWidth - margins - spacing
            : 620.0;

        final colWidths = [
          totalCellWidth * 0.36,
          totalCellWidth * 0.24,
          totalCellWidth * 0.12,
          totalCellWidth * 0.13,
          totalCellWidth * 0.15,
        ];

        return SingleChildScrollView(
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
                      'Arquivo',
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
                      'Tamanho',
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
                      'Criado em',
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
                rows: documents
                    .map((doc) => _buildRow(doc, context, colWidths))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(
    DocumentModel doc,
    BuildContext context,
    List<double> colWidths,
  ) {
    final userName = userNames[doc.userId] ?? doc.userId;

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppTheme.primaryGreenLight.withValues(alpha: 0.05);
        }
        return null;
      }),
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      onSelectChanged: (_) => context.go('/document/${doc.id}'),
      cells: [
        DataCell(
          SizedBox(
            width: colWidths[0],
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Symbols.picture_as_pdf,
                    color: AppTheme.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    doc.fileName,
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
            child: Text(
              _formatFileSize(doc.fileSize),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: colWidths[3],
            child: Text(
              _formatDate(doc.createdAt),
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
                  onPressed: () => context.go('/document/${doc.id}'),
                  icon: Icon(Symbols.visibility, size: 18),
                  color: AppTheme.primaryGreen,
                  tooltip: 'Visualizar',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
                IconButton(
                  onPressed: () => onDelete(doc),
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
