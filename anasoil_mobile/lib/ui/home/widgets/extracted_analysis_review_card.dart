part of 'analysis_flow_widgets.dart';

class ExtractedAnalysisReviewCard extends StatelessWidget {
  final SoilAnalysis analysis;
  final int index;

  const ExtractedAnalysisReviewCard({
    super.key,
    required this.analysis,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final classifications = SoilParameterClassifier.classifyAll(analysis);
    final missingParams = [
      ('M.O.', analysis.organicMatter),
      ('pH', analysis.phCacl2),
      ('Al³⁺', analysis.al3Plus),
      ('Ca²⁺', analysis.ca2Plus),
      ('Mg²⁺', analysis.mg2Plus),
      ('K⁺', analysis.kPlus),
      ('CTC efetiva', analysis.ctcEfetiva),
      ('CTC pH 7,0', analysis.ctcPh7),
      ('V%', analysis.vPercent),
      ('PST', analysis.pst),
      ('Sat. Al', analysis.mPercent),
    ].where((p) => p.$2 == null).map((p) => p.$1).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: AnaSoilSpacing.md),
      elevation: 0,
      color: AppTheme.baseWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        side: const BorderSide(color: AppTheme.baseGray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed('analysis-detail', extra: analysis),
        child: Padding(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnaSoilStatusChip(
                    label: 'Amostra ${index + 1}',
                    tone: AnaSoilStatusTone.success,
                  ),
                  const Spacer(),
                  Text(
                    analysis.labNumber.isNotEmpty ? analysis.labNumber : 'N/A',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.baseGray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AnaSoilSpacing.sm),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.baseGray400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AnaSoilSpacing.md),
              _DataRow(
                'Fazenda',
                analysis.propertyName.isNotEmpty
                    ? analysis.propertyName
                    : 'N/A',
              ),
              _DataRow(
                'Nº DMLab',
                analysis.labNumber.isNotEmpty ? analysis.labNumber : 'N/A',
              ),
              const Divider(height: 20),
              const _Legend(),
              const SizedBox(height: AnaSoilSpacing.md),
              const Text(
                'Parâmetros da Análise',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.baseGray900,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.sm),
              Wrap(
                spacing: AnaSoilSpacing.sm,
                runSpacing: AnaSoilSpacing.sm,
                children: [
                  ...classifications.map(
                    (c) => SoilParameterChip.classified(c),
                  ),
                  ...missingParams.map(SoilParameterChip.notAvailable),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
