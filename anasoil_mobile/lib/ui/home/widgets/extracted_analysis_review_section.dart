part of 'analysis_flow_widgets.dart';

class ExtractedAnalysisReviewSection extends StatelessWidget {
  final List<SoilAnalysis> analyses;

  const ExtractedAnalysisReviewSection({super.key, required this.analyses});

  @override
  Widget build(BuildContext context) {
    final firstAnalysis = analyses.isNotEmpty ? analyses.first : null;
    final hasDocumentInfo =
        firstAnalysis != null &&
        (firstAnalysis.requester != null ||
            firstAnalysis.stakeholder != null ||
            firstAnalysis.dataEntrada != null ||
            firstAnalysis.material != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDocumentInfo) DocumentInfoCard(analysis: firstAnalysis),
        if (hasDocumentInfo) const SizedBox(height: AnaSoilSpacing.lg),
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: AnaSoilSpacing.sm),
            Text(
              '${analyses.length} amostra(s) extraída(s)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.baseGray900,
              ),
            ),
            const Spacer(),
            const AnaSoilStatusChip(
              label: 'Revisar',
              icon: Icons.fact_check_outlined,
              tone: AnaSoilStatusTone.warning,
            ),
          ],
        ),
        const SizedBox(height: AnaSoilSpacing.lg),
        ...analyses.asMap().entries.map(
          (entry) => ExtractedAnalysisReviewCard(
            analysis: entry.value,
            index: entry.key,
          ),
        ),
      ],
    );
  }
}
