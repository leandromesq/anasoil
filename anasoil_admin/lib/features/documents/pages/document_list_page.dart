import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/documents/viewmodels/document_list_viewmodel.dart';
import 'package:anasoil_admin/features/documents/widgets/documents_data_table.dart';
import 'package:anasoil_admin/features/documents/widgets/documents_filters.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_admin/shared/widgets/deferred_table.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

class DocumentListPage extends StatefulWidget {
  final DocumentListViewModel viewModel;
  const DocumentListPage({super.key, required this.viewModel});

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  String? searchQuery;
  int? sortColumn;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Map<String, String> _buildUserNameMap() {
    final userRepo = locator<UserRepository>();
    final map = <String, String>{};
    for (final user in userRepo.users) {
      map[user.id] = user.name;
    }
    return map;
  }

  List<DocumentModel> _applyFilters(List<DocumentModel> docs) {
    var filtered = docs;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered = filtered.where((doc) {
        return doc.fileName.toLowerCase().contains(searchQuery!.toLowerCase());
      }).toList();
    }

    if (sortColumn != null) {
      filtered.sort((a, b) {
        dynamic aValue, bValue;
        switch (sortColumn) {
          case 0:
            aValue = a.fileName;
            bValue = b.fileName;
            break;
          case 1:
            aValue = a.userId;
            bValue = b.userId;
            break;
          case 2:
            aValue = a.fileSize;
            bValue = b.fileSize;
            break;
          case 3:
            aValue = a.createdAt;
            bValue = b.createdAt;
            break;
          default:
            return 0;
        }
        int result;
        if (aValue is DateTime && bValue is DateTime) {
          result = aValue.compareTo(bValue);
        } else if (aValue is int && bValue is int) {
          result = aValue.compareTo(bValue);
        } else {
          result = aValue.toString().compareTo(bValue.toString());
        }
        return sortAscending ? result : -result;
      });
    }

    return filtered;
  }

  void _handleDelete(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Documento'),
        content: Text('Deseja realmente excluir "${doc.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppTheme.secondaryRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.viewModel.deleteDocumentCommand.execute(doc.id);
      if (mounted) {
        AnaSoilToast.success(context, 'Documento excluído com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AnaSoilToast.error(context, 'Erro ao excluir: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Documentos',
      body: Column(
        children: [
          DocumentsFilters(
            searchText: searchQuery ?? '',
            onSearchChanged: (value) {
              setState(() {
                searchQuery = value.isEmpty ? null : value;
              });
            },
            onClearFilters: () {
              setState(() {
                searchQuery = null;
              });
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([
                widget.viewModel,
                widget.viewModel.fetchDocumentsCommand,
                widget.viewModel.deleteDocumentCommand,
              ]),
              builder: (context, _) {
                return DeferredTable(
                  onReady: widget.viewModel.documents.isEmpty
                      ? () => widget.viewModel.fetchDocumentsCommand.execute()
                      : null,
                  builder: () {
                    final isLoading =
                        widget
                            .viewModel
                            .fetchDocumentsCommand
                            .value
                            .isRunning &&
                        widget.viewModel.documents.isEmpty;

                    final filtered = _applyFilters(widget.viewModel.documents);

                    return DocumentsDataTable(
                      documents: filtered,
                      userNames: _buildUserNameMap(),
                      isLoading: isLoading,
                      sortColumn: sortColumn,
                      sortAscending: sortAscending,
                      onSort: (columnIndex) {
                        setState(() {
                          if (sortColumn == columnIndex) {
                            sortAscending = !sortAscending;
                          } else {
                            sortColumn = columnIndex;
                            sortAscending = true;
                          }
                        });
                      },
                      onDelete: _handleDelete,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
