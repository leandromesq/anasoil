import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../utils/result.dart';
import 'auth_viewmodel.dart';

/// Tela de recuperação de senha
class ResetPasswordPage extends StatefulWidget {
  final AuthViewModel viewModel;

  const ResetPasswordPage({super.key, required this.viewModel});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    await widget.viewModel.resetPasswordCommand.execute(email);

    if (!mounted) return;

    final result = widget.viewModel.resetPasswordCommand.result;
    if (result is Ok) {
      AnaSoilToast.success(context, 'Instruções enviadas para seu e-mail');
      context.go('/login');
    } else if (result is Error) {
      final error = result;
      AnaSoilToast.error(context, error.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.baseGray900),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone
                Icon(Icons.lock_reset, size: 80, color: AppTheme.primaryGreen),
                const SizedBox(height: 24),

                // Título
                Text(
                  'Esqueceu a senha?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.baseGray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Digite seu e-mail e enviaremos instruções para redefinir sua senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.baseGray600),
                ),
                const SizedBox(height: 48),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seu@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botão de recuperar senha
                ListenableBuilder(
                  listenable: widget.viewModel.resetPasswordCommand,
                  builder: (context, _) {
                    final isLoading =
                        widget.viewModel.resetPasswordCommand.running;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.baseWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.baseWhite,
                              ),
                            )
                          : const Text(
                              'Recuperar Senha',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Link para voltar ao login
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Voltar ao login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
