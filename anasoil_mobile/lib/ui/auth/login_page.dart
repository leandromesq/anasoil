import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/login_credentials.dart';
import '../shared/app_logo.dart';
import 'auth_viewmodel.dart';

/// Tela de login
class LoginPage extends StatefulWidget {
  final AuthViewModel viewModel;

  const LoginPage({super.key, required this.viewModel});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final credentials = LoginCredentials(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await widget.viewModel.loginCommand.execute(credentials);

    if (!mounted) return;

    final result = widget.viewModel.loginCommand.result;
    if (result is Error) {
      final error = result as Error;
      AnaSoilToast.error(context, error.error.toString());
    } else if (result is Ok) {
      // Login bem-sucedido, redirecionar para a home
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const AppLogo(size: 80),
                  const SizedBox(height: 16),

                  // Título
                  Text(
                    'Bem-vindo de volta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.baseGray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre na sua conta AnaSoil',
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
                  const SizedBox(height: 16),

                  // Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: '••••••••',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua senha';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Esqueci minha senha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.go('/reset-password');
                      },
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de login
                  ListenableBuilder(
                    listenable: widget.viewModel.loginCommand,
                    builder: (context, _) {
                      final isLoading = widget.viewModel.loginCommand.running;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: AppTheme.baseWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: AppTheme.primaryGreen,
                          disabledForegroundColor: AppTheme.baseWhite,
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
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
