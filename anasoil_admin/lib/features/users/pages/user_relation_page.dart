import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_relation_viewmodel.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserRelationPage extends StatefulWidget {
  final String userId;
  final UserRelationViewModel viewModel;
  const UserRelationPage({
    super.key,
    required this.userId,
    required this.viewModel,
  });

  @override
  State<UserRelationPage> createState() => _UserRelationPageState();
}

class _UserRelationPageState extends State<UserRelationPage> {
  late final UserRelationViewModel _viewModel = widget.viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel.fetchUserCommand.execute(widget.userId);
    _viewModel.fetchAllUsersCommand.execute();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Gerenciar Relações',
      backRoute: '/users',
      backTooltip: 'Voltar para Usuários',
      body: ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _viewModel.fetchUserCommand]),
        builder: (context, _) {
          var command = _viewModel.fetchUserCommand;
          var user = command.getCachedSuccess();

          if (command.value.isRunning && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (command.value.isFailure && user == null) {
            return Center(
              child: Text(
                'Erro ao carregar dados: ${command.getCachedFailure()}',
                style: const TextStyle(color: AppTheme.secondaryRed),
              ),
            );
          }

          if (user != null) {
            if (user.userRole == UserRole.farmer) {
              var linkedConsultors = _viewModel.linkedConsultors;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfoCard(user),
                    const SizedBox(height: 20),
                    command.value.isRunning
                        ? const LinearProgressIndicator(minHeight: 2)
                        : const SizedBox(height: 2),
                    _buildConsultorSection(user, linkedConsultors),
                  ],
                ),
              );
            } else if (user.userRole == UserRole.consultant) {
              var linkedAgricultors = _viewModel.linkedAgricultors;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfoCard(user),
                    const SizedBox(height: 20),
                    command.value.isRunning
                        ? const LinearProgressIndicator(minHeight: 2)
                        : const SizedBox(height: 2),
                    _buildAgricultorSection(user, linkedAgricultors),
                  ],
                ),
              );
            }
            return Center(
              child: Text(
                'O usuário ${user.name} possui o papel de "${user.role}", que não tem relações gerenciáveis nesta seção.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserInfoCard(UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Icon(_getRoleIcon(user.role), color: AppTheme.baseWhite),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleDisplayName(user.role),
                      style: const TextStyle(
                        color: AppTheme.baseWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultorSection(
    UserModel agricultor,
    List<UserModel> linkedConsultors,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Consultores Vinculados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddConsultorDialog(agricultor),
                icon: Icon(Symbols.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildRelatedUsersList(
              linkedConsultors,
              'Nenhum consultor vinculado',
              (consultorId) => _removeConsultor(agricultor.id, consultorId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgricultorSection(
    UserModel consultor,
    List<UserModel> linkedAgricultors,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Agricultores Vinculados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddAgricultorDialog(consultor),
                icon: Icon(Symbols.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildRelatedUsersList(
              linkedAgricultors,
              'Nenhum agricultor vinculado',
              (agricultorId) => _removeAgricultor(consultor.id, agricultorId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedUsersList(
    List<UserModel> users,
    String emptyMessage,
    Function(String) onRemove,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(fontSize: 16, color: AppTheme.baseGray600),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Icon(_getRoleIcon(user.role), color: AppTheme.baseWhite),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: Icon(Symbols.remove_circle),
              color: AppTheme.secondaryRed,
              onPressed: () =>
                  _showRemoveConfirmation(user, () => onRemove(user.id)),
            ),
          ),
        );
      },
    );
  }

  void _showAddConsultorDialog(UserModel agricultor) async {
    final availableConsultors = await _viewModel.getAvailableConsultors(
      agricultor,
    );
    _showUserSelectionDialog(
      'Adicionar Consultor',
      availableConsultors,
      (consultorId) => _addConsultor(agricultor.id, consultorId),
    );
  }

  void _showAddAgricultorDialog(UserModel consultor) async {
    final availableAgricultors = await _viewModel.getAvailableAgricultors(
      consultor,
    );
    _showUserSelectionDialog(
      'Adicionar Agricultor',
      availableAgricultors,
      (agricultorId) => _addAgricultor(consultor.id, agricultorId),
    );
  }

  void _showUserSelectionDialog(
    String title,
    List<UserModel> users,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: users.isEmpty
              ? const Center(child: Text('Nenhum usuário disponível'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(user.role),
                        child: Icon(
                          _getRoleIcon(user.role),
                          color: AppTheme.baseWhite,
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onSelect(user.id);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(UserModel user, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text('Deseja remover o vínculo com ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _addConsultor(String agricultorId, String consultorId) async {
    try {
      await _viewModel.linkAgricultorConsultorCommand.execute([
        agricultorId,
        consultorId,
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultor adicionado com sucesso!'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppTheme.secondaryRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _addAgricultor(String consultorId, String agricultorId) async {
    try {
      await _viewModel.linkAgricultorConsultorCommand.execute([
        agricultorId,
        consultorId,
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agricultor adicionado com sucesso!'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppTheme.secondaryRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _removeConsultor(String agricultorId, String consultorId) async {
    try {
      await _viewModel.unlinkAgricultorConsultorCommand.execute([
        agricultorId,
        consultorId,
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultor removido com sucesso!'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppTheme.secondaryRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _removeAgricultor(String consultorId, String agricultorId) async {
    try {
      await _viewModel.unlinkAgricultorConsultorCommand.execute([
        agricultorId,
        consultorId,
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agricultor removido com sucesso!'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppTheme.secondaryRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (UserRole.parse(role)) {
      case UserRole.admin:
        return AppTheme.secondaryRed;
      case UserRole.consultant:
        return AppTheme.primaryGreenLight;
      case UserRole.farmer:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (UserRole.parse(role)) {
      case UserRole.admin:
        return Symbols.admin_panel_settings;
      case UserRole.consultant:
        return Symbols.account_circle;
      case UserRole.farmer:
        return Symbols.eco;
    }
  }

  String _getRoleDisplayName(String role) => UserRole.parse(role).displayName;
}
