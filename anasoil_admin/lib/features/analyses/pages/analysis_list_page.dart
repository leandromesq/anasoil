import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/analyses/viewmodels/analysis_list_viewmodel.dart';
import 'package:anasoil_admin/features/analyses/widgets/analyses_data_table.dart';
import 'package:anasoil_admin/features/analyses/widgets/analyses_filters.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_admin/shared/widgets/deferred_table.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

class AnalysisListPage extends StatefulWidget {
  final AnalysisListViewModel viewModel;
  const AnalysisListPage({super.key, required this.viewModel});

  @override
  State<AnalysisListPage> createState() => _AnalysisListPageState();
}

class _AnalysisListPageState extends State<AnalysisListPage> {
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

  List<SoilAnalysisModel> _applyFilters(List<SoilAnalysisModel> analyses) {
    var filtered = analyses;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered = filtered.where((a) {
        return a.propertyName.toLowerCase().contains(
              searchQuery!.toLowerCase(),
            ) ||
            a.labNumber.toLowerCase().contains(searchQuery!.toLowerCase()) ||
            a.labNumber.toLowerCase().contains(searchQuery!.toLowerCase());
      }).toList();
    }

    if (sortColumn != null) {
      filtered.sort((a, b) {
        dynamic aValue, bValue;
        switch (sortColumn) {
          case 0:
            aValue = a.propertyName;
            bValue = b.propertyName;
            break;
          case 1:
            aValue = a.userId;
            bValue = b.userId;
            break;
          case 2:
            aValue = a.labNumber;
            bValue = b.labNumber;
            break;
          case 4:
            aValue = a.analysisDate;
            bValue = b.analysisDate;
            break;
          default:
            return 0;
        }
        int result;
        if (aValue is DateTime && bValue is DateTime) {
          result = aValue.compareTo(bValue);
        } else {
          result = aValue.toString().compareTo(bValue.toString());
        }
        return sortAscending ? result : -result;
      });
    }

    return filtered;
  }

  void _handleDelete(SoilAnalysisModel analysis) async {
    final displayName = analysis.propertyName.isNotEmpty
        ? analysis.propertyName
        : analysis.labNumber;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Análise'),
        content: Text('Deseja realmente excluir a análise "$displayName"?'),
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
      await widget.viewModel.deleteAnalysisCommand.execute(analysis.id);
      if (mounted) {
        AnaSoilToast.success(context, 'Análise excluída com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AnaSoilToast.error(context, 'Erro ao excluir: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = locator<AdminSession>();

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => AppLayout(
        title: 'Análises',
        body: Column(
          children: [
            AnalysesFilters(
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
                  widget.viewModel.fetchAnalysesCommand,
                  widget.viewModel.deleteAnalysisCommand,
                ]),
                builder: (context, _) {
                  return DeferredTable(
                    onReady: widget.viewModel.analyses.isEmpty
                        ? () => widget.viewModel.fetchAnalysesCommand.execute()
                        : null,
                    builder: () {
                      final isLoading =
                          widget
                              .viewModel
                              .fetchAnalysesCommand
                              .value
                              .isRunning &&
                          widget.viewModel.analyses.isEmpty;

                      final filtered = _applyFilters(widget.viewModel.analyses);

                      return AnalysesDataTable(
                        analyses: filtered,
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
                        canDelete: session.canManageData,
                        onDelete: session.canManageData ? _handleDelete : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
