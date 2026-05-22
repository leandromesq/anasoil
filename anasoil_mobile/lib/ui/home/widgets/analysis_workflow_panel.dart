part of 'analysis_flow_widgets.dart';

class AnalysisWorkflowPanel extends StatelessWidget {
  final AnalysisIntakeStep step;

  const AnalysisWorkflowPanel({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Documento', Icons.description_outlined, _workflowState(0)),
      ('Extração', Icons.auto_awesome, _workflowState(1)),
      ('Revisão', Icons.fact_check_outlined, _workflowState(2)),
      ('Salvar', Icons.save_outlined, _workflowState(3)),
    ];

    return AnaSoilSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(AnaSoilSpacing.lg),
      radius: AnaSoilRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fluxo da análise',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.baseGray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _helperText(),
            style: const TextStyle(fontSize: 13, color: AppTheme.baseGray600),
          ),
          const SizedBox(height: AnaSoilSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _WorkflowStep(
                    label: items[i].$1,
                    icon: items[i].$2,
                    state: items[i].$3,
                  ),
                ),
                if (i != items.length - 1)
                  Container(
                    width: AnaSoilSpacing.lg,
                    height: 2,
                    color: items[i].$3 == _WorkflowStepState.complete
                        ? AppTheme.primaryGreenLight
                        : AppTheme.baseGray200,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _WorkflowStepState _workflowState(int index) {
    final activeIndex = switch (step) {
      AnalysisIntakeStep.idle => 0,
      AnalysisIntakeStep.fileSelected => 0,
      AnalysisIntakeStep.uploadingDocument => 0,
      AnalysisIntakeStep.documentUploaded => 1,
      AnalysisIntakeStep.extracting => 1,
      AnalysisIntakeStep.extracted => 2,
      AnalysisIntakeStep.saving => 3,
      AnalysisIntakeStep.complete => 4,
      AnalysisIntakeStep.failed => -1,
    };

    if (step == AnalysisIntakeStep.failed) return _WorkflowStepState.error;
    if (activeIndex == 4 || index < activeIndex) {
      return _WorkflowStepState.complete;
    }
    if (index == activeIndex) return _WorkflowStepState.active;
    return _WorkflowStepState.pending;
  }

  String _helperText() {
    return switch (step) {
      AnalysisIntakeStep.idle => 'Selecione um PDF para começar.',
      AnalysisIntakeStep.fileSelected =>
        'Documento pronto para envio e extração.',
      AnalysisIntakeStep.uploadingDocument =>
        'Enviando o documento com segurança.',
      AnalysisIntakeStep.documentUploaded =>
        'Documento enviado. Extraindo os dados do PDF.',
      AnalysisIntakeStep.extracting => 'Lendo o PDF e identificando amostras.',
      AnalysisIntakeStep.extracted =>
        'Revise as amostras extraídas antes de salvar.',
      AnalysisIntakeStep.saving => 'Salvando as análises no histórico.',
      AnalysisIntakeStep.complete =>
        'Análises salvas e disponíveis para consulta.',
      AnalysisIntakeStep.failed => 'Revise o erro abaixo e tente novamente.',
    };
  }
}

class _WorkflowStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final _WorkflowStepState state;

  const _WorkflowStep({
    required this.label,
    required this.icon,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _WorkflowStepState.complete => AppTheme.primaryGreen,
      _WorkflowStepState.active => AppTheme.primaryGreenDark,
      _WorkflowStepState.error => AppTheme.secondaryRed,
      _WorkflowStepState.pending => AppTheme.baseGray400,
    };
    final bg = switch (state) {
      _WorkflowStepState.complete => AppTheme.primaryGreenSoft,
      _WorkflowStepState.active => AppTheme.primaryGreenSoft,
      _WorkflowStepState.error => AppTheme.secondaryRedLight,
      _WorkflowStepState.pending => AppTheme.baseGray100,
    };

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(
            state == _WorkflowStepState.complete ? Icons.check : icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: state == _WorkflowStepState.active
                ? FontWeight.w700
                : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
