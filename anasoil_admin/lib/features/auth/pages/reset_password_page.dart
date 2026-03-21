import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await locator<AuthService>().resetPassword(_emailController.text.trim());
      if (mounted) setState(() => _emailSent = true);
    } on Exception catch (e) {
      setState(() {
        _errorMessage = _mapFirebaseError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String error) {
    if (error.contains('user-not-found')) {
      return 'Nenhuma conta encontrada com este email.';
    }
    if (error.contains('invalid-email')) {
      return 'Email inválido.';
    }
    if (error.contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
    }
    return 'Erro ao enviar email. Tente novamente.';
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
                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.leaf(),
                    color: AppTheme.baseWhite,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Redefinir Senha',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.baseGray900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informe seu email para receber o link de redefinição',
                  style: TextStyle(fontSize: 14, color: AppTheme.baseGray500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Card
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
                  child: _emailSent
                      ? _buildSuccessContent()
                      : _buildFormContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                PhosphorIcons.checkCircle(),
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Email enviado com sucesso! Verifique sua caixa de entrada.',
                  style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Voltar para o login'),
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
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.baseGray900,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(hintText: 'admin@anasoil.com'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o email';
              }
              if (!value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
            onFieldSubmitted: (_) => _resetPassword(),
          ),

          // Erro
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
                    PhosphorIcons.warningCircle(),
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

          // Botão
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.baseWhite,
                      ),
                    )
                  : const Text('Enviar link de redefinição'),
            ),
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }
}
