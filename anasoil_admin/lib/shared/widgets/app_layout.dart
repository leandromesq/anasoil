import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const AppLayout({
    super.key,
    required this.body,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      body: Row(
        children: [
          // Sidebar
          const AppSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                AppNavbar(title: title, actions: actions),
                // Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.baseWhite,
        border: Border(
          right: BorderSide(color: AppTheme.baseGray200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppTheme.baseWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AnaSoil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.baseGray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: const [
                SidebarItem(
                  icon: Icons.people,
                  title: 'Usuários',
                  isActive: true,
                  route: '/users',
                ),
                SidebarItem(
                  icon: Icons.analytics,
                  title: 'Análises',
                  isActive: false,
                  route: '/analytics',
                ),
                SidebarItem(
                  icon: Icons.folder,
                  title: 'Documentos',
                  isActive: false,
                  route: '/documents',
                ),
                SidebarItem(
                  icon: Icons.settings,
                  title: 'Configurações',
                  isActive: false,
                  route: '/settings',
                ),
              ],
            ),
          ),

          // User Profile
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.baseGray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: AppTheme.baseWhite,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.baseGray900,
                        ),
                      ),
                      Text(
                        'admin@anasoil.com',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.baseGray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final String route;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? AppTheme.primaryGreen : AppTheme.baseGray500,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppTheme.primaryGreen : AppTheme.baseGray600,
          ),
        ),
        selected: isActive,
        selectedColor: AppTheme.primaryGreen,
        selectedTileColor: AppTheme.primaryGreenLight.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        onTap: () {
          // TODO: Implementar navegação
          // context.go(route);
        },
      ),
    );
  }
}

class AppNavbar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const AppNavbar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.baseWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.baseGray200, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.baseGray900,
              ),
            ),

            const Spacer(),

            // Actions
            if (actions != null) ...actions!,

            // Profile/Settings
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.baseGray600,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
                color: AppTheme.baseGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
