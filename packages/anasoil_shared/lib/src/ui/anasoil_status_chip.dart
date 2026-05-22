import 'package:flutter/material.dart';

import '../theme_tokens.dart';

enum AnaSoilStatusTone { neutral, success, warning, danger }

class AnaSoilStatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AnaSoilStatusTone tone;

  const AnaSoilStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = AnaSoilStatusTone.neutral,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AnaSoilSpacing.md,
        vertical: AnaSoilSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: AnaSoilSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
