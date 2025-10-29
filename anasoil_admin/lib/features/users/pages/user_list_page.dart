import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:anasoil_admin/features/users/widgets/users_data_table.dart';
import 'package:anasoil_admin/features/users/widgets/users_filters.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserListPage extends StatefulWidget {
  final UserListViewModel viewModel;
  const UserListPage({super.key, required this.viewModel});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String? searchQuery;
  String? statusFilter;
  String? roleFilter;
  int? sortColumn;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchUsersCommand.execute();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  List<UserModel> _applyFilters(List<UserModel> users) {
    var filteredUsers = users;

    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return user.name.toLowerCase().contains(searchQuery!.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery!.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (statusFilter != null && statusFilter != 'todos') {
      filteredUsers = filteredUsers.where((user) {
        return statusFilter == 'ativo' ? user.active : !user.active;
      }).toList();
    }

    // Apply role filter
    if (roleFilter != null && roleFilter != 'todos') {
      filteredUsers = filteredUsers.where((user) {
        return user.role == roleFilter;
      }).toList();
    }

    // Apply sorting
    if (sortColumn != null) {
      filteredUsers.sort((a, b) {
        dynamic aValue, bValue;

        switch (sortColumn) {
          case 0: // Name
            aValue = a.name;
            bValue = b.name;
            break;
          case 1: // Role
            aValue = a.role;
            bValue = b.role;
            break;
          case 2: // Status
            aValue = a.active;
            bValue = b.active;
            break;
          case 3: // Created at
            aValue = a.createdAt;
            bValue = b.createdAt;
            break;
          default:
            return 0;
        }

        int result;
        if (aValue is DateTime && bValue is DateTime) {
          result = aValue.compareTo(bValue);
        } else if (aValue is bool && bValue is bool) {
          result = aValue == bValue ? 0 : (aValue ? 1 : -1);
        } else {
          result = aValue.toString().compareTo(bValue.toString());
        }

        return sortAscending ? result : -result;
      });
    }

    return filteredUsers;
  }

  void _handleStatusChange(UserModel user, bool newStatus) async {
    try {
      // Usar o comando de atualização de status do ViewModel
      await widget.viewModel.updateUserStatusCommand.execute(
        user.id,
        newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status do usuário ${newStatus ? 'ativado' : 'desativado'} com sucesso!',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao alterar status: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: AppTheme.secondaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Usuários',
      actions: [
        ElevatedButton.icon(
          onPressed: () => context.go('/user/add'),
          icon: Icon(PhosphorIcons.plus(), size: 18),
          label: const Text('Novo Usuário'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.baseWhite,
          ),
        ),
      ],
      body: Column(
        children: [
          // Filters
          UsersFilters(
            searchText: searchQuery ?? '',
            statusFilter: statusFilter ?? 'todos',
            roleFilter: roleFilter ?? 'todos',
            onSearchChanged: (value) {
              setState(() {
                searchQuery = value.isEmpty ? null : value;
              });
            },
            onStatusFilterChanged: (value) {
              setState(() {
                statusFilter = value;
              });
            },
            onRoleFilterChanged: (value) {
              setState(() {
                roleFilter = value;
              });
            },
            onClearFilters: () {
              setState(() {
                searchQuery = null;
                statusFilter = null;
                roleFilter = null;
              });
            },
          ),
          const SizedBox(height: 24),

          // Table
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([
                widget.viewModel,
                widget.viewModel.deleteUserCommand,
              ]),
              builder: (context, _) {
                final isLoading =
                    widget.viewModel.fetchUsersCommand.value.isRunning &&
                    widget.viewModel.users.isEmpty;

                // Apply filters
                final filteredUsers = _applyFilters(widget.viewModel.users);

                return UsersDataTable(
                  users: filteredUsers,
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
                  onEdit: (user) => context.go('/user/edit/${user.id}'),
                  onStatusChanged: (user, newStatus) =>
                      _handleStatusChange(user, newStatus),
                  onManageRelations: (user) =>
                      context.go('/user/${user.id}/relations'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
