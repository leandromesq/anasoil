part of 'analysis_flow_widgets.dart';

class SelectedPdfCard extends StatelessWidget {
  final String fileName;
  final bool canRemove;
  final VoidCallback onRemove;

  const SelectedPdfCard({
    super.key,
    required this.fileName,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnaSoilSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      radius: AnaSoilRadius.lg,
      borderColor: AppTheme.primaryGreen,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AnaSoilSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.secondaryRedLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: AppTheme.secondaryRed,
              size: 32,
            ),
          ),
          const SizedBox(width: AnaSoilSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.baseGray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AnaSoilSpacing.xs),
                const Text(
                  'PDF selecionado',
                  style: TextStyle(fontSize: 13, color: AppTheme.baseGray600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: canRemove ? onRemove : null,
            icon: const Icon(Icons.close, color: AppTheme.baseGray600),
          ),
        ],
      ),
    );
  }
}
