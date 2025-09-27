import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
        actions: [
          ListenableBuilder(
            listenable: viewModel.fetchUsersCommand,
            builder: (context, _) {
              if (viewModel.fetchUsersCommand.value.isRunning) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.fetchUsersCommand.execute,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            // Atualize o onPressed:
            onPressed: () => context.go('/user/add'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.deleteUserCommand]),
        builder: (context, _) {
          if (viewModel.fetchUsersCommand.value.isRunning &&
              viewModel.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.users.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          return ListView.builder(
            itemCount: viewModel.users.length,
            itemBuilder: (context, index) {
              final user = viewModel.users[index];
              final isDeleting = viewModel.deleteUserCommand.value.isRunning;

              return ListTile(
                title: Text(user.name),
                subtitle: Text('${user.email} - Role: ${user.role}'),
                trailing: isDeleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () => _showDeleteConfirmationDialog(
                          context,
                          viewModel,
                          user,
                        ),
                      ),
                onTap: () => context.go('/user/edit/${user.id}'),
              );
            },
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
            onPressed: () {
              viewModel.deleteUserCommand.execute(user.id);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}
