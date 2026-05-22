part of 'analysis_flow_widgets.dart';

class AnalysisSaveSuccessCard extends StatelessWidget {
  final List<SoilAnalysis> savedAnalyses;
  final VoidCallback onImportAnother;
  final VoidCallback? onNavigateToHistory;

  const AnalysisSaveSuccessCard({
    super.key,
    required this.savedAnalyses,
    required this.onImportAnother,
    this.onNavigateToHistory,
  });

  @override
  Widget build(BuildContext context) {
    final count = savedAnalyses.length;
    final hasSingleAnalysis = count == 1;

    return AnaSoilSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      radius: AnaSoilRadius.md,
      borderColor: AppTheme.primaryGreenLight.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: AnaSoilSpacing.sm),
              Expanded(
                child: Text(
                  count == 0 ? 'Análises salvas' : '$count análise(s) salva(s)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.baseGray900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AnaSoilSpacing.sm),
          Text(
            hasSingleAnalysis
                ? 'A análise já está disponível para consulta.'
                : 'As análises já estão disponíveis no histórico.',
            style: const TextStyle(fontSize: 14, color: AppTheme.baseGray600),
          ),
          const SizedBox(height: AnaSoilSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onImportAnother,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AnaSoilRadius.md),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Importar outro'),
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: hasSingleAnalysis
                      ? () => context.pushNamed(
                          'analysis-detail',
                          extra: savedAnalyses.first,
                        )
                      : onNavigateToHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.baseWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AnaSoilRadius.md),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(
                    hasSingleAnalysis ? 'Ver análise' : 'Ver histórico',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
