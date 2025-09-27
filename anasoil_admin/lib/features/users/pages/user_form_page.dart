// lib/features/user_management/screens/user_form_screen.dart
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final userToSave = UserModel(
        id: widget.userId ?? '', // ID vazio para novo usuário
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        active: _viewModel.editingUser?.active ?? true,
      );

      _viewModel.saveUserCommand.execute(userToSave);
      // Após salvar, volta para a tela de lista.
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Função'),
                items: const [
                  DropdownMenuItem(
                    value: 'agricultor',
                    child: Text('Agricultor'),
                  ),
                  DropdownMenuItem(
                    value: 'consultor',
                    child: Text('Consultor'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
