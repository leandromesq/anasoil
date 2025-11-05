import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_relation_viewmodel.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserRelationPage extends StatefulWidget {
  final String userId;
  const UserRelationPage({super.key, required this.userId});

  @override
  State<UserRelationPage> createState() => _UserRelationPageState();
}

class _UserRelationPageState extends State<UserRelationPage> {
  late final UserRelationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<UserRelationViewModel>();
    _viewModel.fetchUserCommand.execute(widget.userId);
    _viewModel.fetchAllUsersCommand.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Gerenciar Relações',
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = _viewModel.currentUser!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(user),
                const SizedBox(height: 20),
                if (user.role == 'agricultor')
                  _buildConsultorSection(user)
                else if (user.role == 'consultor')
                  _buildAgricultorSection(user),
              ],
            ),
          );
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
              child: Icon(_getRoleIcon(user.role), color: Colors.white),
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
                        color: Colors.white,
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

  Widget _buildConsultorSection(UserModel agricultor) {
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
                icon: Icon(PhosphorIcons.plus()),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildRelatedUsersList(
              _viewModel.getLinkedConsultors(agricultor),
              'Nenhum consultor vinculado',
              (consultorId) => _removeConsultor(agricultor.id, consultorId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgricultorSection(UserModel consultor) {
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
                icon: Icon(PhosphorIcons.plus()),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildRelatedUsersList(
              _viewModel.getLinkedAgricultors(consultor),
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
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
              child: Icon(_getRoleIcon(user.role), color: Colors.white),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: Icon(PhosphorIcons.minusCircle()),
              color: Colors.red,
              onPressed: () =>
                  _showRemoveConfirmation(user, () => onRemove(user.id)),
            ),
          ),
        );
      },
    );
  }

  void _showAddConsultorDialog(UserModel agricultor) {
    final availableConsultors = _viewModel.getAvailableConsultors(agricultor);
    _showUserSelectionDialog(
      'Adicionar Consultor',
      availableConsultors,
      (consultorId) => _addConsultor(agricultor.id, consultorId),
    );
  }

  void _showAddAgricultorDialog(UserModel consultor) {
    final availableAgricultors = _viewModel.getAvailableAgricultors(consultor);
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
                          color: Colors.white,
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.secondaryRed;
      case 'consultor':
        return const Color(0xFF3B82F6); // Azul
      case 'agricultor':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.baseGray500;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return PhosphorIcons.shieldCheck();
      case 'consultor':
        return PhosphorIcons.userCircle();
      case 'agricultor':
        return PhosphorIcons.plant();
      default:
        return PhosphorIcons.user();
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'consultor':
        return 'Consultor';
      case 'agricultor':
        return 'Agricultor';
      default:
        return role;
    }
  }
}
