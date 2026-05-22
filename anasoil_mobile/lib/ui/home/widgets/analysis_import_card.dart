part of 'analysis_flow_widgets.dart';

class AnalysisImportCard extends StatelessWidget {
  final VoidCallback onTap;

  const AnalysisImportCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: AppTheme.baseGray400),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AnaSoilSpacing.xxxl),
          decoration: BoxDecoration(
            color: AppTheme.baseWhite,
            borderRadius: BorderRadius.circular(AnaSoilRadius.lg),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AnaSoilSpacing.lg),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(AnaSoilRadius.md),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: AppTheme.baseWhite,
                  size: 48,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.lg),
              const Text(
                'Importar Documento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.baseGray900,
                ),
              ),
              const SizedBox(height: AnaSoilSpacing.sm),
              const Text(
                '*Formatos Suportados: .pdf',
                style: TextStyle(fontSize: 13, color: AppTheme.secondaryRed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
