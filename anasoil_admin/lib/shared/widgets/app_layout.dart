import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/shared/widgets/app_logo.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Breakpoint below which the layout switches to mobile (drawer + bottom nav)
const double _kMobileBreakpoint = AnaSoilBreakpoints.tablet;

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < _kMobileBreakpoint;

    if (isMobile) {
      return _MobileScaffold(child: child);
    }

    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      body: Row(
        children: [
          const _AppSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ============================================================================
// Mobile layout
// ============================================================================

class _MobileScaffold extends StatelessWidget {
  final Widget child;

  const _MobileScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      appBar: AppBar(
        backgroundColor: AppTheme.baseWhite,
        foregroundColor: AppTheme.baseGray900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _routeTitle(currentRoute),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Symbols.menu, color: AppTheme.baseGray600),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const _AppDrawer(),
      body: child,
    );
  }

  String _routeTitle(String route) {
    if (route.startsWith('/user')) return 'Usuários';
    if (route.startsWith('/document')) return 'Documentos';
    if (route.startsWith('/analysis')) return 'Análises';
    if (route == '/settings') return 'Configurações';
    if (route == '/users') return 'Usuários';
    if (route == '/documents') return 'Documentos';
    if (route == '/analyses') return 'Análises';
    return 'AnaSoil Admin';
  }
}

// ============================================================================
// Drawer (mobile)
// ============================================================================

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final session = locator<AdminSession>();
    final userEmail = session.email ?? '';
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryGreen),
            child: Row(
              children: [
                const AppLogo(size: 48, tone: AppLogoTone.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'AnaSoil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.baseWhite,
                        ),
                      ),
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.baseWhite.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Symbols.group,
            title: 'Usuários',
            isActive: currentRoute.startsWith('/user'),
            route: '/users',
          ),
          _DrawerItem(
            icon: Symbols.monitoring,
            title: 'Análises',
            isActive:
                currentRoute.startsWith('/analysis') ||
                currentRoute == '/analyses',
            route: '/analyses',
          ),
          _DrawerItem(
            icon: Symbols.folder,
            title: 'Documentos',
            isActive:
                currentRoute.startsWith('/document') ||
                currentRoute == '/documents',
            route: '/documents',
          ),
          _DrawerItem(
            icon: Symbols.settings,
            title: 'Configurações',
            isActive: currentRoute == '/settings',
            route: '/settings',
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(Symbols.person, size: 18, color: AppTheme.baseWhite),
            ),
            title: const Text(
              'Administrador',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              userEmail,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: Icon(Symbols.logout, color: AppTheme.baseGray500),
              onPressed: () async {
                Navigator.pop(context);
                await session.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primaryGreen : AppTheme.baseGray500,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppTheme.primaryGreen : AppTheme.baseGray600,
        ),
      ),
      selected: isActive,
      selectedColor: AppTheme.primaryGreen,
      selectedTileColor: AppTheme.primaryGreenLight.withValues(alpha: 0.1),
      hoverColor: AppTheme.primaryGreenLight.withValues(alpha: 0.08),
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}

// ============================================================================
// Desktop sidebar
// ============================================================================

class _AppSidebar extends StatelessWidget {
  const _AppSidebar();

  @override
  Widget build(BuildContext context) {
    final session = locator<AdminSession>();
    final userEmail = session.email ?? '';
    final currentRoute = GoRouterState.of(context).matchedLocation;

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
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const AppLogo(size: 40),
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Symbols.group,
                  title: 'Usuários',
                  isActive: currentRoute.startsWith('/user'),
                  route: '/users',
                ),
                _SidebarItem(
                  icon: Symbols.monitoring,
                  title: 'Análises',
                  isActive:
                      currentRoute == '/analyses' ||
                      currentRoute.startsWith('/analysis'),
                  route: '/analyses',
                ),
                _SidebarItem(
                  icon: Symbols.folder,
                  title: 'Documentos',
                  isActive:
                      currentRoute == '/documents' ||
                      currentRoute.startsWith('/document'),
                  route: '/documents',
                ),
                _SidebarItem(
                  icon: Symbols.settings,
                  title: 'Configurações',
                  isActive: currentRoute == '/settings',
                  route: '/settings',
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(AnaSoilSpacing.lg),
            padding: const EdgeInsets.all(AnaSoilSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.baseGray100,
              borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(
                    Symbols.person,
                    size: 18,
                    color: AppTheme.baseWhite,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.baseGray900,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.baseGray500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Symbols.logout,
                    size: 18,
                    color: AppTheme.baseGray500,
                  ),
                  tooltip: 'Sair',
                  onPressed: () async {
                    await session.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final String route;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isActive ? AppTheme.primaryGreen : AppTheme.baseGray600;
    final iconColor = isActive ? AppTheme.primaryGreen : AppTheme.baseGray500;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AnaSoilSpacing.md,
        vertical: 2,
      ),
      child: Material(
        color: isActive
            ? AppTheme.primaryGreenLight.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
          mouseCursor: isActive
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          hoverColor: isActive ? Colors.transparent : AppTheme.baseGray100,
          splashColor: AppTheme.primaryGreenLight.withValues(alpha: 0.08),
          highlightColor: AppTheme.primaryGreenLight.withValues(alpha: 0.04),
          onTap: isActive ? null : () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// AppLayout (desktop navbar)
// ============================================================================

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
    final isMobile = MediaQuery.sizeOf(context).width < _kMobileBreakpoint;

    if (isMobile) {
      return Padding(padding: const EdgeInsets.all(16), child: body);
    }

    return Column(
      children: [
        AppNavbar(title: title, actions: actions),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: body,
          ),
        ),
      ],
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.baseGray900,
              ),
            ),
            const Spacer(),
            ...?actions,
          ],
        ),
      ),
    );
  }
}
