import 'package:flutter/material.dart';

import '../theme_tokens.dart';
import 'anasoil_status_chip.dart';

class AnaSoilInlineMessage extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final AnaSoilStatusTone tone;
  final Widget? action;

  const AnaSoilInlineMessage({
    super.key,
    required this.message,
    required this.icon,
    this.title,
    this.tone = AnaSoilStatusTone.neutral,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      AnaSoilStatusTone.success => (
        foreground: AnaSoilSemanticColors.statusSuccess,
        background: AnaSoilSemanticColors.statusSuccessSoft,
        border: AnaSoilColors.primaryGreenLight.withValues(alpha: 0.35),
      ),
      AnaSoilStatusTone.warning => (
        foreground: AnaSoilSemanticColors.statusWarning,
        background: AnaSoilSemanticColors.statusWarningSoft,
        border: AnaSoilColors.warningAmber.withValues(alpha: 0.25),
      ),
      AnaSoilStatusTone.danger => (
        foreground: AnaSoilSemanticColors.statusDanger,
        background: AnaSoilSemanticColors.statusDangerSoft,
        border: AnaSoilColors.secondaryRed.withValues(alpha: 0.25),
      ),
      AnaSoilStatusTone.neutral => (
        foreground: AnaSoilSemanticColors.textSecondary,
        background: AnaSoilSemanticColors.surfaceMuted,
        border: AnaSoilSemanticColors.borderSubtle,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AnaSoilSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.foreground),
          const SizedBox(width: AnaSoilSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AnaSoilSpacing.xs),
                ],
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AnaSoilSpacing.sm),
            action!,
          ],
        ],
      ),
    );
  }
}
