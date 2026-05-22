import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChangePasswordPage extends StatefulWidget {
  final String oobCode;

  const ChangePasswordPage({super.key, required this.oobCode});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isVerifying = true;
  String? _errorMessage;
  String? _verifiedEmail;
  bool _passwordChanged = false;

  @override
  void initState() {
    super.initState();
    _verifyCode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    try {
      final email = await locator<AuthService>().verifyPasswordResetCode(
        widget.oobCode,
      );
      if (mounted) {
        setState(() {
          _verifiedEmail = email;
          _isVerifying = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapFirebaseError(e.toString());
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await locator<AuthService>().confirmPasswordReset(
        widget.oobCode,
        _passwordController.text,
      );
      if (mounted) setState(() => _passwordChanged = true);
    } on Exception catch (e) {
      setState(() {
        _errorMessage = _mapFirebaseError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String error) {
    if (error.contains('expired-action-code')) {
      return 'Este link expirou. Solicite um novo link de redefinição.';
    }
    if (error.contains('invalid-action-code')) {
      return 'Este link é inválido ou já foi utilizado.';
    }
    if (error.contains('user-disabled')) {
      return 'Esta conta foi desativada.';
    }
    if (error.contains('user-not-found')) {
      return 'Nenhuma conta encontrada.';
    }
    if (error.contains('weak-password')) {
      return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
    }
    return 'Erro ao redefinir senha. Tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Nova Senha',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.baseGray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _verifiedEmail != null
                      ? 'Defina a nova senha para $_verifiedEmail'
                      : 'Defina sua nova senha de acesso',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.baseGray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.baseWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.baseGray200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isVerifying) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_passwordChanged) {
      return _buildSuccessContent();
    }

    if (_verifiedEmail == null) {
      return _buildErrorContent();
    }

    return _buildFormContent();
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreenLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Symbols.check_circle,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Senha alterada com sucesso!',
                  style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Ir para o login'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.secondaryRedLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Symbols.warning, color: AppTheme.secondaryRedDark, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage ?? 'Link inválido ou expirado.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryRedDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => context.go('/reset-password'),
            child: const Text('Solicitar novo link'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              'Voltar para o login',
              style: TextStyle(fontSize: 13, color: AppTheme.baseGray500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nova senha',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.baseGray900,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Symbols.visibility
                      : Symbols.visibility_off,
                  color: AppTheme.baseGray500,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a nova senha';
              }
              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Confirmar senha',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.baseGray900,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Symbols.visibility
                      : Symbols.visibility_off,
                  color: AppTheme.baseGray500,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme a nova senha';
              }
              if (value != _passwordController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
            onFieldSubmitted: (_) => _changePassword(),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.secondaryRedLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Symbols.warning,
                    color: AppTheme.secondaryRedDark,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryRedDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.baseWhite,
                      ),
                    )
                  : const Text('Alterar senha'),
            ),
          ),
        ],
      ),
    );
  }
}
