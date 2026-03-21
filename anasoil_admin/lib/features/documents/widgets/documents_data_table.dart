import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/documents/viewmodels/document_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/service_locator.dart';

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
      return const Center(child: CircularProgressIndicator());
    }

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.folder(), size: 64, color: AppTheme.baseGray400),
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
                      PhosphorIcons.folder(),
                      size: 20,
                      color: AppTheme.baseGray600,
                    ),
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
                      icon: Icon(PhosphorIcons.arrowClockwise()),
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
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth > 800
                          ? constraints.maxWidth
                          : 800,
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
                            .map((doc) => _buildRow(doc, context))
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

  DataRow _buildRow(DocumentModel doc, BuildContext context) {
    final userName = userNames[doc.userId] ?? doc.userId;

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 280,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.filePdf(),
                    color: const Color(0xFF3B82F6),
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
            width: 180,
            child: Text(
              userName,
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              _formatFileSize(doc.fileSize),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              _formatDate(doc.createdAt),
              style: const TextStyle(color: AppTheme.baseGray600, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: () => onDelete(doc),
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
