import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../profile/profile_viewmodel.dart';

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Logo e nome do app
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AnaSoil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Notificações
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.grey[700],
                onPressed: () {
                  // TODO: Implementar notificações
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificações em desenvolvimento'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

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
                      backgroundColor: Colors.green[700],
                      backgroundImage: hasAvatar
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : null,
                      child: !hasAvatar
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
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
