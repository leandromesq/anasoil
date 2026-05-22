part of 'analysis_flow_widgets.dart';

class DocumentInfoCard extends StatelessWidget {
  final SoilAnalysis analysis;

  const DocumentInfoCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return AnaSoilSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(AnaSoilSpacing.lg),
      backgroundColor: AppTheme.primaryGreenSoft,
      borderColor: AppTheme.primaryGreenLight.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppTheme.primaryGreen, size: 20),
              SizedBox(width: AnaSoilSpacing.sm),
              Text(
                'Informações do Documento',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreenDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AnaSoilSpacing.md),
          if (analysis.requester != null)
            _DocInfoRow('Solicitante', analysis.requester!),
          if (analysis.stakeholder != null)
            _DocInfoRow('Interessado', analysis.stakeholder!),
          if (analysis.dataEntrada != null)
            _DocInfoRow('Data de Entrada', analysis.dataEntrada!),
          if (analysis.material != null)
            _DocInfoRow('Material', analysis.material!),
        ],
      ),
    );
  }
}

class _DocInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DocInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AnaSoilSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryGreenDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.baseGray900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
