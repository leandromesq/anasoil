import 'package:anasoil_admin/core/app_router.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/theme_provider.dart';
import 'package:anasoil_admin/firebase_options.dart';
import 'package:anasoil_admin/core/url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = locator<ThemeProvider>();

    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'AnaSoil Admin',
          theme: themeProvider.theme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
