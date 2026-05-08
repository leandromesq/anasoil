import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_viewmodel.dart';
import '../profile/profile_viewmodel.dart';
import '../shared/common_app_bar.dart';
import 'analysis_viewmodel.dart';
import 'home_page.dart';
import 'analysis_page.dart';
import 'history_page.dart';
import '../profile/profile_page.dart';

/// Scaffold principal com bottom navigation
class MainScaffold extends StatefulWidget {
  final AuthViewModel authViewModel;
  final ProfileViewModel profileViewModel;

  const MainScaffold({
    super.key,
    required this.authViewModel,
    required this.profileViewModel,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        authViewModel: widget.authViewModel,
        onNavigateToTab: _onItemTapped,
      ),
      AnalysisPage(onNavigateToHistory: () => _onItemTapped(2)),
      const HistoryPage(),
      ProfilePage(
        viewModel: widget.profileViewModel,
        authViewModel: widget.authViewModel,
      ),
    ];

    // Carrega análises salvas para exibir na home (atividades recentes)
    getIt<AnalysisViewModel>().loadAnalysesCommand.execute();

    // Carrega perfil do usuário para exibir avatar na AppBar
    widget.profileViewModel.loadProfileCommand.execute();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(onProfileTap: () => _onItemTapped(3)),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GNav(
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppTheme.primaryGreen,
              color: Colors.grey[600],
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.analytics, text: 'Análise'),
                GButton(icon: Icons.history, text: 'Histórico'),
                GButton(icon: Icons.person, text: 'Perfil'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
