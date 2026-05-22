import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/theme/app_theme.dart';
import '../profile/profile_viewmodel.dart';
import 'app_logo.dart';

/// AppBar comum do aplicativo com logo, notificações e avatar
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;

  const CommonAppBar({super.key, this.onProfileTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final profileViewModel = GetIt.I<ProfileViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.baseWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: AnaSoilElevation.subtleBlur,
            offset: AnaSoilElevation.subtleOffset,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnaSoilSpacing.lg,
            vertical: AnaSoilSpacing.sm,
          ),
          child: Row(
            children: [
              // Logo e nome do app
              Row(
                children: [
                  const AppLogo(size: 32),
                  const SizedBox(width: AnaSoilSpacing.sm),
                  const Text(
                    'AnaSoil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.baseGray900,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Notificações
              // IconButton(
              //   icon: const Icon(Icons.notifications_outlined),
              //   color: Colors.grey[700],
              //   onPressed: () {
              //     // Implementar notificações
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text('Notificações em desenvolvimento'),
              //         duration: Duration(seconds: 2),
              //       ),
              //     );
              //   },
              // ),

              // const SizedBox(width: 8),

              // Avatar do perfil
              ListenableBuilder(
                listenable: profileViewModel,
                builder: (context, _) {
                  final profile = profileViewModel.profile;
                  final avatarUrl = profile?.avatarUrl;
                  final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

                  return GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryGreen,
                      backgroundImage: hasAvatar
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : null,
                      child: !hasAvatar
                          ? const Icon(
                              Icons.person,
                              color: AppTheme.baseWhite,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
