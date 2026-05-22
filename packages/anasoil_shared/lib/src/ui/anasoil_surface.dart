import 'package:flutter/material.dart';

import '../theme_tokens.dart';

class AnaSoilSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double radius;
  final bool elevated;
  final double? width;

  const AnaSoilSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AnaSoilSpacing.lg),
    this.backgroundColor = AnaSoilSemanticColors.surface,
    this.borderColor = AnaSoilSemanticColors.borderSubtle,
    this.radius = AnaSoilRadius.md,
    this.elevated = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: AnaSoilElevation.cardBlur,
                  offset: AnaSoilElevation.subtleOffset,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
