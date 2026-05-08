import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/dependency_injection.dart';
import 'core/router_config.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Garante que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configura a injeção de dependências
  await setupDependencyInjection();

  // Inicia o app
  runApp(const AnaSoilApp());
}

/// App principal do AnaSoil
class AnaSoilApp extends StatelessWidget {
  const AnaSoilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AnaSoil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
