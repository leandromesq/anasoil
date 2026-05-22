part of 'analysis_flow_widgets.dart';

class SoilParameterChip extends StatelessWidget {
  final String label;
  final String value;
  final String? levelText;
  final Color foreground;
  final Color background;
  final Color border;

  const SoilParameterChip._({
    required this.label,
    required this.value,
    this.levelText,
    required this.foreground,
    required this.background,
    required this.border,
  });

  factory SoilParameterChip.classified(SoilClassification classification) {
    final color = _levelColor(classification.level);
    final valueStr =
        classification.value == classification.value.roundToDouble()
        ? classification.value.toStringAsFixed(0)
        : classification.value.toStringAsFixed(
            classification.value < 1 ? 2 : 1,
          );
    return SoilParameterChip._(
      label: classification.label,
      value: valueStr,
      levelText: classification.levelText,
      foreground: color,
      background: _levelBgColor(classification.level),
      border: color.withValues(alpha: 0.4),
    );
  }

  factory SoilParameterChip.notAvailable(String label) {
    return SoilParameterChip._(
      label: label,
      value: 'N/A',
      foreground: AppTheme.baseGray400,
      background: AppTheme.baseGray100,
      border: AppTheme.baseGray300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.baseGray600,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          if (levelText != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                levelText!,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendItem(SoilLevel.low, 'Baixo'),
        SizedBox(width: AnaSoilSpacing.md),
        _LegendItem(SoilLevel.medium, 'Médio'),
        SizedBox(width: AnaSoilSpacing.md),
        _LegendItem(SoilLevel.high, 'Alto'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final SoilLevel level;
  final String text;

  const _LegendItem(this.level, this.text);

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AnaSoilSpacing.xs),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppTheme.baseGray600),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AnaSoilSpacing.xs),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: AppTheme.baseGray600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.baseGray900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

Color _levelColor(SoilLevel level) {
  return switch (level) {
    SoilLevel.low => AnaSoilSemanticColors.soilLow,
    SoilLevel.medium => AnaSoilSemanticColors.soilMedium,
    SoilLevel.high => AnaSoilSemanticColors.soilHigh,
  };
}

Color _levelBgColor(SoilLevel level) {
  return switch (level) {
    SoilLevel.low => AnaSoilSemanticColors.soilLowSoft,
    SoilLevel.medium => AnaSoilSemanticColors.soilMediumSoft,
    SoilLevel.high => AnaSoilSemanticColors.soilHighSoft,
  };
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(AnaSoilRadius.lg),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 8), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
