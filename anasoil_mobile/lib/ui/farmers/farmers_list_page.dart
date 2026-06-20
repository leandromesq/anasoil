import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/user.dart';
import '../../ui/auth/auth_viewmodel.dart';
import 'farmers_viewmodel.dart';

/// Página de lista de agricultores vinculados ao consultor
class FarmersListPage extends StatefulWidget {
  const FarmersListPage({super.key});

  @override
  State<FarmersListPage> createState() => _FarmersListPageState();
}

class _FarmersListPageState extends State<FarmersListPage> {
  late final FarmersViewModel _viewModel;
  late final AuthViewModel _authViewModel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FarmersViewModel>();
    _authViewModel = getIt<AuthViewModel>();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userId = _authViewModel.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Usuário não autenticado';
      });
      return;
    }

    final result = await _viewModel.loadFarmers(userId);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result is Error<List<User>>) {
        _error = result.error.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      appBar: AppBar(
        title: const Text('Meus Agricultores'),
        backgroundColor: AppTheme.baseWhite,
        foregroundColor: AppTheme.baseGray900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_isLoading) {
            return const AnaSoilSkeletonList(itemCount: 5);
          }

          if (_error != null) {
            return AnaSoilEmptyState(
              icon: Icons.error_outline,
              title: 'Erro ao carregar agricultores',
              message: _error == 'Usuário não autenticado'
                  ? 'Entre novamente para consultar seus agricultores vinculados.'
                  : 'Verifique a conexão e tente buscar os agricultores novamente.',
              actionLabel: 'Tentar novamente',
              onAction: _loadFarmers,
            );
          }

          final farmers = _viewModel.farmers;
          if (farmers.isEmpty) {
            return const AnaSoilEmptyState(
              icon: Icons.people_outline,
              title: 'Nenhum agricultor vinculado',
              message:
                  'Quando agricultores forem vinculados a você, eles aparecerão aqui.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFarmers,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AnaSoilSpacing.lg),
              itemCount: farmers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AnaSoilSpacing.md),
                  child: _FarmerCard(
                    farmer: farmers[index],
                    onTap: () => context.push(
                      '/farmers/${farmers[index].id}',
                      extra: farmers[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final User farmer;
  final VoidCallback onTap;

  const _FarmerCard({required this.farmer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = farmer.avatarUrl != null && farmer.avatarUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnaSoilRadius.lg),
        child: AnaSoilSurface(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          radius: AnaSoilRadius.lg,
          elevated: true,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryGreenSoft,
                backgroundImage: hasAvatar
                    ? NetworkImage(farmer.avatarUrl!)
                    : null,
                child: !hasAvatar
                    ? const Icon(
                        Icons.person,
                        color: AppTheme.primaryGreen,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: AnaSoilSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    const SizedBox(height: AnaSoilSpacing.xs),
                    Text(
                      farmer.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.baseGray600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (farmer.phone != null && farmer.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        AnaSoilPhoneInputFormatter.format(farmer.phone!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.baseGray500,
                        ),
                      ),
                    ],
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
