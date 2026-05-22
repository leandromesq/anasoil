import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/soil_analysis.dart';
import '../../domain/models/soil_parameter_classifier.dart';

/// Página de detalhes de uma análise de solo.
class AnalysisDetailPage extends StatelessWidget {
  final SoilAnalysis analysis;

  const AnalysisDetailPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final classifications = SoilParameterClassifier.classifyAll(analysis);
    final d = analysis.analysisDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      appBar: AppBar(
        title: const Text('Detalhes da Análise'),
        backgroundColor: AppTheme.baseWhite,
        foregroundColor: AppTheme.baseGray900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: classifications.isEmpty
          ? const AnaSoilEmptyState(
              icon: Icons.science_outlined,
              title: 'Nenhum parâmetro disponível',
              message: 'Os dados desta análise ainda não foram classificados.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AnaSoilSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(dateStr),
                  const SizedBox(height: AnaSoilSpacing.lg),
                  _buildSummarySection(classifications),
                  const SizedBox(height: AnaSoilSpacing.lg),
                  _buildRangeSection(classifications),
                  const SizedBox(height: AnaSoilSpacing.lg),
                  _buildParametersList(classifications),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(String dateStr) {
    return AnaSoilSurface(
      width: double.infinity,
      radius: AnaSoilRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.grass,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.propertyName.isNotEmpty
                          ? analysis.propertyName
                          : 'Análise ${analysis.labNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.baseGray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (analysis.requester != null) ...[
            const SizedBox(height: AnaSoilSpacing.md),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: AppTheme.baseGray500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    analysis.requester!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.baseGray600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AnaSoilSpacing.md),
          Wrap(
            spacing: AnaSoilSpacing.sm,
            runSpacing: AnaSoilSpacing.sm,
            children: [
              AnaSoilStatusChip(
                label: 'Amostra ${analysis.labNumber}',
                tone: AnaSoilStatusTone.success,
              ),
              if (analysis.depthCm != null)
                AnaSoilStatusChip(
                  label: '${analysis.depthCm!.toStringAsFixed(0)} cm',
                  tone: AnaSoilStatusTone.neutral,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(List<SoilClassification> classifications) {
    final baixo = classifications.where((c) => c.level == SoilLevel.low).length;
    final medio = classifications
        .where((c) => c.level == SoilLevel.medium)
        .length;
    final alto = classifications.where((c) => c.level == SoilLevel.high).length;

    return AnaSoilSurface(
      width: double.infinity,
      radius: AnaSoilRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.baseGray900,
            ),
          ),
          const SizedBox(height: AnaSoilSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Baixo',
                  baixo,
                  foreground: AppTheme.secondaryRedDark,
                  background: AppTheme.secondaryRedLight,
                  border: AppTheme.secondaryRed.withValues(alpha: 0.18),
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.sm),
              Expanded(
                child: _buildSummaryItem(
                  'Médio',
                  medio,
                  foreground: AppTheme.warningAmberDark,
                  background: AppTheme.warningAmberLight,
                  border: AppTheme.warningAmber.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.sm),
              Expanded(
                child: _buildSummaryItem(
                  'Alto',
                  alto,
                  foreground: AppTheme.primaryGreenDark,
                  background: AppTheme.primaryGreenSoft,
                  border: AppTheme.primaryGreenLight.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    int count, {
    required Color foreground,
    required Color background,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AnaSoilSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: foreground)),
        ],
      ),
    );
  }

  Widget _buildRangeSection(List<SoilClassification> classifications) {
    return AnaSoilSurface(
      width: double.infinity,
      radius: AnaSoilRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faixas dos parâmetros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.baseGray900,
            ),
          ),
          const SizedBox(height: AnaSoilSpacing.xs),
          const Text(
            'Cada parâmetro usa a própria faixa de referência.',
            style: TextStyle(fontSize: 12, color: AppTheme.baseGray600),
          ),
          const SizedBox(height: AnaSoilSpacing.lg),
          ...classifications.map(_buildRangeRow),
        ],
      ),
    );
  }

  Widget _buildRangeRow(SoilClassification classification) {
    final color = _colorForLevel(classification.level);
    final unitStr = classification.unit.isNotEmpty
        ? ' ${classification.unit}'
        : '';
    final valueText = '${_formatNumber(classification.value)}$unitStr';
    final markerPosition = _markerPosition(classification);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  classification.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.baseGray900,
                  ),
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.baseGray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AnaSoilSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final markerLeft = (constraints.maxWidth - 14) * markerPosition;
              return SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _rangeSegment(AppTheme.secondaryRedLight),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: _rangeSegment(AppTheme.warningAmberLight),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: _rangeSegment(AppTheme.primaryGreenSoft),
                        ),
                      ],
                    ),
                    Positioned(
                      left: markerLeft,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.baseWhite,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            children: [
              const Text(
                'Baixo',
                style: TextStyle(fontSize: 11, color: AppTheme.baseGray600),
              ),
              const Spacer(),
              Text(
                '${_formatNumber(classification.lowThreshold)}–${_formatNumber(classification.highThreshold)}$unitStr',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.baseGray600,
                ),
              ),
              const Spacer(),
              const Text(
                'Alto',
                style: TextStyle(fontSize: 11, color: AppTheme.baseGray600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangeSegment(Color color) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildParametersList(List<SoilClassification> classifications) {
    final baixo = classifications.where((c) => c.level == SoilLevel.low);
    final medio = classifications.where((c) => c.level == SoilLevel.medium);
    final alto = classifications.where((c) => c.level == SoilLevel.high);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhamento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.baseGray900,
          ),
        ),
        const SizedBox(height: AnaSoilSpacing.md),
        if (baixo.isNotEmpty) _buildParameterGroup('Baixo', baixo),
        if (medio.isNotEmpty) _buildParameterGroup('Médio', medio),
        if (alto.isNotEmpty) _buildParameterGroup('Alto', alto),
      ],
    );
  }

  Widget _buildParameterGroup(
    String title,
    Iterable<SoilClassification> classifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: AnaSoilSpacing.sm,
            top: AnaSoilSpacing.xs,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.baseGray600,
            ),
          ),
        ),
        ...classifications.map(_buildParameterCard),
      ],
    );
  }

  Widget _buildParameterCard(SoilClassification classification) {
    final color = _colorForLevel(classification.level);
    final unitStr = classification.unit.isNotEmpty
        ? ' ${classification.unit}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: AnaSoilSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.baseWhite,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        border: Border.all(color: AppTheme.baseGray200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(AnaSoilRadius.sm),
            ),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AnaSoilSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classification.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.baseGray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Referência média: ${_formatNumber(classification.lowThreshold)}–${_formatNumber(classification.highThreshold)}$unitStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.baseGray500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatNumber(classification.value)}$unitStr',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.baseGray900,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  classification.levelText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _markerPosition(SoilClassification classification) {
    final low = classification.lowThreshold;
    final high = classification.highThreshold;
    final value = classification.value;
    if (high <= low) return value < low ? 0.0 : 1.0;
    final position = (value - low) / (high - low);
    return position.clamp(0.0, 1.0);
  }

  Color _colorForLevel(SoilLevel level) {
    switch (level) {
      case SoilLevel.low:
        return AnaSoilSemanticColors.soilLow;
      case SoilLevel.medium:
        return AnaSoilSemanticColors.soilMedium;
      case SoilLevel.high:
        return AnaSoilSemanticColors.soilHigh;
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(value < 1 ? 2 : 1);
  }
}
