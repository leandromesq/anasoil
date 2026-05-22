import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/profile_update_data.dart';
import '../../utils/result.dart';
import 'profile_viewmodel.dart';

/// Tela de edição de perfil
class EditProfilePage extends StatefulWidget {
  final ProfileViewModel viewModel;

  const EditProfilePage({super.key, required this.viewModel});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = widget.viewModel.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showAvatarOptions() async {
    final profile = widget.viewModel.profile;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.baseGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (profile?.avatarUrl != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppTheme.secondaryRed,
                ),
                title: Text(
                  'Remover foto',
                  style: TextStyle(color: AppTheme.secondaryRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    await widget.viewModel.updateAvatarCommand.execute(File(picked.path));

    if (!mounted) return;

    final result = widget.viewModel.updateAvatarCommand.result;
    if (result is Error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result as Error).error.toString()),
          backgroundColor: AppTheme.secondaryRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto atualizada com sucesso'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  Future<void> _removeAvatar() async {
    await widget.viewModel.removeAvatarCommand.execute();

    if (!mounted) return;

    final result = widget.viewModel.removeAvatarCommand.result;
    if (result is Error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result as Error).error.toString()),
          backgroundColor: AppTheme.secondaryRed,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final data = ProfileUpdateData(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    await widget.viewModel.updateProfileCommand.execute(data);

    if (!mounted) return;

    final result = widget.viewModel.updateProfileCommand.result;
    if (result is Error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result as Error).error.toString()),
          backgroundColor: AppTheme.secondaryRed,
        ),
      );
    } else if (result is Ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseWhite,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          ListenableBuilder(
            listenable: widget.viewModel.updateProfileCommand,
            builder: (context, _) {
              final running = widget.viewModel.updateProfileCommand.running;

              return TextButton(
                onPressed: running ? null : _handleSave,
                child: running
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    final profile = widget.viewModel.profile;
                    final isUploading =
                        widget.viewModel.updateAvatarCommand.running ||
                        widget.viewModel.removeAvatarCommand.running;

                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.primaryGreen,
                              backgroundImage: profile?.avatarUrl != null
                                  ? NetworkImage(profile!.avatarUrl!)
                                  : null,
                              child: isUploading
                                  ? const CircularProgressIndicator(
                                      color: AppTheme.baseWhite,
                                    )
                                  : profile?.avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppTheme.baseWhite,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: isUploading ? null : _showAvatarOptions,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Alterar Imagem'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Nome
              TextFormField(
                controller: _nameController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite seu nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (não editável)
              TextFormField(
                initialValue: widget.viewModel.profile?.email ?? '',
                enabled: false,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: AppTheme.baseGray100,
                ),
              ),
              const SizedBox(height: 16),

              // Telefone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(00) 00000-0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (cleanPhone.length < 10) {
                      return 'Telefone inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tipo de perfil (não editável)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.baseGray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.badge_outlined, color: AppTheme.baseGray600),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Perfil',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.baseGray600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.viewModel.profile?.profileType.displayName ??
                              '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
