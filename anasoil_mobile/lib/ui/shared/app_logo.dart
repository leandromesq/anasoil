import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppLogoTone { green, white, splash }

class AppLogo extends StatelessWidget {
  final double size;
  final AppLogoTone tone;

  const AppLogo({super.key, required this.size, this.tone = AppLogoTone.green});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      switch (tone) {
        AppLogoTone.green => 'assets/images/anasoil_logo_green.svg',
        AppLogoTone.white => 'assets/images/anasoil_logo_white.svg',
        AppLogoTone.splash => 'assets/images/anasoil_logo_splash.svg',
      },
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: 'AnaSoil',
    );
  }
}
