import 'dart:io';

import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/user_profile.dart';
import 'profile_viewmodel.dart';
import '../auth/auth_viewmodel.dart';

/// Tela de perfil do usuário
class ProfilePage extends StatefulWidget {
  final ProfileViewModel viewModel;
  final AuthViewModel authViewModel;

  const ProfilePage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await widget.viewModel.loadProfileCommand.execute();
  }

  Future<void> _showAvatarOptions(UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AnaSoilRadius.lg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AnaSoilSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.baseGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AnaSoilSpacing.lg),
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
            if (profile.avatarUrl != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.secondaryRed,
                ),
                title: const Text(
                  'Remover foto',
                  style: TextStyle(color: AppTheme.secondaryRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: AnaSoilSpacing.sm),
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

  Future<void> _logout() async {
    final confirmed = await AnaSoilConfirmDialog.show(
      context,
      title: 'Sair da conta?',
      message: 'Você precisará entrar novamente para acessar o AnaSoil.',
      confirmLabel: 'Sair',
      destructive: true,
    );

    if (!confirmed || !mounted) return;
    await widget.authViewModel.logoutCommand.execute();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.loadProfileCommand.running) {
            return const AnaSoilLoadingState(message: 'Carregando perfil...');
          }

          final profile = widget.viewModel.profile;
          if (profile == null) {
            return const AnaSoilEmptyState(
              icon: Icons.person_off,
              title: 'Perfil não disponível',
              message: 'Entre novamente para acessar seu perfil.',
            );
          }

          return _buildProfileContent(profile);
        },
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AnaSoilSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AnaSoilSpacing.lg),
          _buildAvatarSection(profile),
          const SizedBox(height: AnaSoilSpacing.xxl),
          _buildInfoCard(profile),
          const SizedBox(height: AnaSoilSpacing.lg),
          _buildChangePasswordButton(),
          const SizedBox(height: AnaSoilSpacing.lg),
          _buildLogoutButton(),
          const SizedBox(height: AnaSoilSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(UserProfile profile) {
    final isUploading =
        widget.viewModel.updateAvatarCommand.running ||
        widget.viewModel.removeAvatarCommand.running;

    return GestureDetector(
      onTap: isUploading ? null : () => _showAvatarOptions(profile),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryGreenSoft,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: AppTheme.primaryGreen,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: isUploading
                  ? const CircularProgressIndicator(color: AppTheme.baseWhite)
                  : profile.avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.baseWhite,
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AnaSoilSpacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.baseWhite, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: AppTheme.baseWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserProfile profile) {
    return AnaSoilSurface(
      radius: AnaSoilRadius.lg,
      padding: EdgeInsets.zero,
      elevated: true,
      child: Column(
        children: [
          _buildInfoItem(
            label: 'Nome Completo',
            value: profile.name,
            icon: Icons.edit_outlined,
            onTap: () => context.push('/profile/edit'),
          ),
          const Divider(height: 1),
          _buildInfoItem(
            label: 'Email',
            value: profile.email,
            onTap: () => context.push('/profile/edit'),
          ),
          const Divider(height: 1),
          _buildInfoItem(
            label: 'Telefone',
            value: profile.phone ?? 'Não informado',
            icon: Icons.edit_outlined,
            onTap: () => context.push('/profile/edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.baseGray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AnaSoilSpacing.xs),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.baseGray900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null) Icon(icon, color: AppTheme.baseGray400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/profile/change-password'),
        borderRadius: BorderRadius.circular(AnaSoilRadius.lg),
        child: AnaSoilSurface(
          radius: AnaSoilRadius.lg,
          elevated: true,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.lg),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alterar Senha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Altere a senha da sua conta',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.baseGray600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.baseGray400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _logout,
        borderRadius: BorderRadius.circular(AnaSoilRadius.lg),
        child: AnaSoilSurface(
          radius: AnaSoilRadius.lg,
          borderColor: AppTheme.secondaryRed.withValues(alpha: 0.25),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryRedLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppTheme.secondaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.lg),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sair da Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Desconectar do AnaSoil',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.baseGray600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.baseGray400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
