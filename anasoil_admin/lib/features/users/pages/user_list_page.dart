import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:anasoil_admin/features/users/widgets/users_data_table.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserListPage extends StatefulWidget {
  final UserListViewModel viewModel;
  const UserListPage({super.key, required this.viewModel});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
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

  @override
  Widget build(BuildContext context) {
    var viewModel = widget.viewModel;

    return AppLayout(
      title: 'Gerenciamento de Usuários',
      actions: [
        // Refresh Button
        ListenableBuilder(
          listenable: viewModel.fetchUsersCommand,
          builder: (context, _) {
            if (viewModel.fetchUsersCommand.value.isRunning) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.baseGray600,
                  ),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: viewModel.fetchUsersCommand.execute,
              tooltip: 'Atualizar',
            );
          },
        ),

        // Add User Button
        ElevatedButton.icon(
          onPressed: () => context.go('/user/add'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Novo Usuário'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.baseWhite,
          ),
        ),
      ],
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.deleteUserCommand]),
        builder: (context, _) {
          final isLoading =
              viewModel.fetchUsersCommand.value.isRunning &&
              viewModel.users.isEmpty;

          return UsersDataTable(
            users: viewModel.users,
            isLoading: isLoading,
            onEdit: (user) => context.go('/user/edit/${user.id}'),
            onDelete: (user) =>
                _showDeleteConfirmationDialog(context, viewModel, user),
            onManageRelations: (user) =>
                context.go('/user/${user.id}/relations'),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    UserListViewModel viewModel,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            child: const Text('Excluir'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await viewModel.deleteUserCommand.execute(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro: ${e.toString().replaceFirst('Exception: ', '')}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
