import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_form_viewmodel.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserFormPage extends StatefulWidget {
  final String? userId;
  const UserFormPage({super.key, this.userId});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late final UserFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'agricultor';
  bool _isActive = true;

  bool get isEditing => widget.userId != null;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<UserFormViewModel>();

    if (isEditing) {
      _viewModel.fetchUserCommand.execute(widget.userId!);
    }

    _viewModel.addListener(_updateFormFields);
  }

  void _updateFormFields() {
    if (_viewModel.editingUser != null) {
      final user = _viewModel.editingUser!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      setState(() {
        _selectedRole = user.role;
        _isActive = user.active;
      });
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateFormFields);
    _viewModel.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final userToSave = UserModel(
        id: widget.userId ?? '',
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        active: _isActive,
        createdAt: _viewModel.editingUser?.createdAt,
      );

      try {
        await _viewModel.saveUserCommand.execute(userToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Usuário atualizado com sucesso!'
                    : 'Usuário criado com sucesso!',
              ),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 1),
            ),
          );
          context.go('/users');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
              backgroundColor: AppTheme.secondaryRed,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: isEditing ? 'Editar Usuário' : 'Novo Usuário',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 0,
            color: AppTheme.baseWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.baseGray200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEditing
                              ? PhosphorIcons.pencilSimple()
                              : PhosphorIcons.userPlus(),
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing ? 'Editar Usuário' : 'Criar Novo Usuário',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.baseGray900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(PhosphorIcons.user()),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(PhosphorIcons.envelope()),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Formato de e-mail incorreto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Função',
                        prefixIcon: Icon(PhosphorIcons.briefcase()),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'agricultor',
                          child: Text('Agricultor'),
                        ),
                        DropdownMenuItem(
                          value: 'consultor',
                          child: Text('Consultor'),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administrador'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Selecione uma função'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    if (isEditing) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.baseGray50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.baseGray200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isActive
                                  ? PhosphorIcons.checkCircle()
                                  : PhosphorIcons.xCircle(),
                              color: _isActive
                                  ? AppTheme.primaryGreen
                                  : AppTheme.secondaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ativo?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.baseGray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              activeThumbColor: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/users'),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onSave,
                            child: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
