import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_form_viewmodel.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  final _phoneController = TextEditingController();
  String _selectedRole = UserRole.farmer.firestoreValue;
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
      _phoneController.text = AnaSoilPhoneInputFormatter.format(
        user.phone ?? '',
      );
      setState(() {
        _selectedRole = user.userRole.firestoreValue;
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
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!locator<AdminSession>().canManageData) {
      AnaSoilToast.error(
        context,
        'Apenas administradores podem editar usuários.',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final userToSave = UserModel(
        id: widget.userId ?? '',
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        active: _isActive,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : AnaSoilPhoneInputFormatter.digitsOnly(_phoneController.text),
        avatarUrl: _viewModel.editingUser?.avatarUrl,
        createdAt: _viewModel.editingUser?.createdAt,
        consultorIds: _viewModel.editingUser?.consultorIds ?? const [],
        agricultorIds: _viewModel.editingUser?.agricultorIds ?? const [],
      );

      try {
        await _viewModel.saveUserCommand.execute(userToSave);
        if (mounted) {
          AnaSoilToast.success(
            context,
            isEditing
                ? 'Usuário atualizado com sucesso!'
                : 'Usuário criado com sucesso!',
          );
          context.go('/users');
        }
      } catch (e) {
        if (mounted) {
          AnaSoilToast.error(
            context,
            'Erro: ${e.toString().replaceFirst('Exception: ', '')}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!locator<AdminSession>().canManageData) {
      return AppLayout(
        title: isEditing ? 'Editar Usuário' : 'Novo Usuário',
        backRoute: '/users',
        backTooltip: 'Voltar para Usuários',
        body: AnaSoilEmptyState(
          icon: Symbols.lock,
          title: 'Sem permissão',
          message: 'Apenas administradores podem criar ou editar usuários.',
          actionLabel: 'Voltar para Usuários',
          onAction: () => context.go('/users'),
        ),
      );
    }

    return AppLayout(
      title: isEditing ? 'Editar Usuário' : 'Novo Usuário',
      backRoute: '/users',
      backTooltip: 'Voltar para Usuários',
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
                          isEditing ? Symbols.edit : Symbols.person_add,
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
                        prefixIcon: Icon(Symbols.person),
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
                        prefixIcon: Icon(Symbols.mail),
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

                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(00) 00000-0000',
                        prefixIcon: Icon(Symbols.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: const [AnaSoilPhoneInputFormatter()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        if (!AnaSoilPhoneInputFormatter.hasCompleteLength(
                          value,
                        )) {
                          return 'Telefone deve estar no formato (DDD) 99999-9999';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Função',
                        prefixIcon: Icon(Symbols.work),
                      ),
                      items: UserRole.assignable
                          .map(
                            (role) => DropdownMenuItem(
                              value: role.firestoreValue,
                              child: Text(role.displayName),
                            ),
                          )
                          .toList(),
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
                              _isActive ? Symbols.check_circle : Symbols.cancel,
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
