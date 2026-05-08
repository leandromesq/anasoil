import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/repositories/analysis_repository.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AnalysisDetailPage extends StatefulWidget {
  final String analysisId;
  const AnalysisDetailPage({super.key, required this.analysisId});

  @override
  State<AnalysisDetailPage> createState() => _AnalysisDetailPageState();
}

class _AnalysisDetailPageState extends State<AnalysisDetailPage> {
  SoilAnalysisModel? _analysis;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      final repo = locator<AnalysisRepository>();
      final analysis = await repo.getById(widget.analysisId);
      if (analysis == null) {
        setState(() {
          _error = 'Análise não encontrada';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Análise não encontrada';
        _isLoading = false;
      });
    }
  }

  String _getUserName(String userId) {
    final userRepo = locator<UserRepository>();
    final user = userRepo.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserModel(
        id: userId,
        name: 'Desconhecido',
        email: '',
        role: '',
        active: false,
      ),
    );
    return user.name;
  }

  Future<void> _deleteAnalysis() async {
    final displayName = _analysis?.propertyName.isNotEmpty == true
        ? _analysis!.propertyName
        : _analysis?.labNumber ?? 'Análise';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Análise'),
        content: Text('Deseja realmente excluir "$displayName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppTheme.secondaryRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await locator<AnalysisRepository>().deleteAnalysis(widget.analysisId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Análise excluída com sucesso!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        context.go('/analyses');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: AppTheme.secondaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLayout(
        title: 'Análise',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _analysis == null) {
      return AppLayout(
        title: 'Análise',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.chartLine(),
                size: 64,
                color: AppTheme.baseGray400,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Análise não encontrada',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.baseGray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/analyses'),
                child: const Text('Voltar para Análises'),
              ),
            ],
          ),
        ),
      );
    }

    final analysis = _analysis!;
    final classifications = _classifyAll(analysis);

    return AppLayout(
      title: 'Análise',
      actions: [
        TextButton.icon(
          onPressed: _deleteAnalysis,
          icon: Icon(
            PhosphorIcons.trash(),
            size: 18,
            color: AppTheme.secondaryRed,
          ),
          label: const Text(
            'Excluir',
            style: TextStyle(color: AppTheme.secondaryRed),
          ),
        ),
        const SizedBox(width: 8),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeaderCard(analysis),
              const SizedBox(height: 20),
              if (classifications.isEmpty)
                _buildEmptyParametersCard()
              else ...[
                _buildSummaryCard(classifications),
                const SizedBox(height: 20),
                _buildRangeCard(classifications),
                const SizedBox(height: 20),
                _buildParametersCard(classifications),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(SoilAnalysisModel analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.plant(),
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis.propertyName.isNotEmpty
                            ? analysis.propertyName
                            : 'Propriedade não informada',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag(
                            'Amostra ${analysis.labNumber}',
                            foreground: AppTheme.primaryGreenDark,
                            background: AppTheme.primaryGreenSoft,
                            border: AppTheme.primaryGreenLight.withValues(
                              alpha: 0.35,
                            ),
                          ),
                          if (analysis.depthCm != null)
                            _buildTag(
                              '${analysis.depthCm} cm',
                              foreground: AppTheme.baseGray600,
                              background: AppTheme.baseGray100,
                              border: AppTheme.baseGray200,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Proprietário', _getUserName(analysis.userId)),
            _buildInfoRow(
              'Data da Análise',
              _formatDate(analysis.analysisDate),
            ),
            if (analysis.requester != null)
              _buildInfoRow('Solicitante', analysis.requester!),
            if (analysis.stakeholder != null)
              _buildInfoRow('Interessado', analysis.stakeholder!),
            if (analysis.dataEntrada != null)
              _buildInfoRow('Data Entrada', analysis.dataEntrada!),
            if (analysis.material != null)
              _buildInfoRow('Material', analysis.material!),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<ParameterClassification> classifications) {
    final low = classifications
        .where((c) => c.level == ClassificationLevel.low)
        .length;
    final medium = classifications
        .where((c) => c.level == ClassificationLevel.medium)
        .length;
    final high = classifications
        .where((c) => c.level == ClassificationLevel.high)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Baixo',
                    low,
                    foreground: AppTheme.secondaryRedDark,
                    background: AppTheme.secondaryRedLight,
                    border: AppTheme.secondaryRed.withValues(alpha: 0.18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Médio',
                    medium,
                    foreground: AppTheme.warningAmberDark,
                    background: AppTheme.warningAmberLight,
                    border: AppTheme.warningAmber.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Alto',
                    high,
                    foreground: AppTheme.primaryGreenDark,
                    background: AppTheme.primaryGreenSoft,
                    border: AppTheme.primaryGreenLight.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeCard(List<ParameterClassification> classifications) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faixas dos parâmetros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cada parâmetro usa a própria faixa de referência.',
              style: TextStyle(fontSize: 13, color: AppTheme.baseGray600),
            ),
            const SizedBox(height: 20),
            ...classifications.map(_buildRangeRow),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersCard(List<ParameterClassification> classifications) {
    final low = classifications.where(
      (c) => c.level == ClassificationLevel.low,
    );
    final medium = classifications.where(
      (c) => c.level == ClassificationLevel.medium,
    );
    final high = classifications.where(
      (c) => c.level == ClassificationLevel.high,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (low.isNotEmpty) _buildParameterGroup('Baixo', low),
            if (medium.isNotEmpty) _buildParameterGroup('Médio', medium),
            if (high.isNotEmpty) _buildParameterGroup('Alto', high),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyParametersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nenhum parâmetro disponível',
          style: TextStyle(color: AppTheme.baseGray500),
        ),
      ),
    );
  }

  Widget _buildRangeRow(ParameterClassification c) {
    final color = _levelColor(c.level);
    final unitStr = c.unit.isNotEmpty ? ' ${c.unit}' : '';
    final markerPosition = _markerPosition(c);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_formatNumber(c.value)}$unitStr',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                              color: Colors.black.withValues(alpha: 0.14),
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
                '${_formatNumber(c.lowThreshold)}–${_formatNumber(c.highThreshold)}$unitStr',
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

  Widget _buildParameterGroup(
    String title,
    Iterable<ParameterClassification> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.baseGray600,
            ),
          ),
        ),
        ...items.map(_buildParameterRow),
      ],
    );
  }

  Widget _buildParameterRow(ParameterClassification c) {
    final color = _levelColor(c.level);
    final unitStr = c.unit.isNotEmpty ? ' ${c.unit}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.baseWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.baseGray200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Referência média: ${_formatNumber(c.lowThreshold)}–${_formatNumber(c.highThreshold)}$unitStr',
                  style: const TextStyle(
                    fontSize: 12,
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
                '${_formatNumber(c.value)}$unitStr',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _levelBackground(c.level),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  c.levelText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSummaryItem(
    String label,
    int count, {
    required Color foreground,
    required Color background,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 13, color: foreground)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.baseGray500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(
    String text, {
    required Color foreground,
    required Color background,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }

  Color _levelColor(ClassificationLevel level) {
    switch (level) {
      case ClassificationLevel.low:
        return AppTheme.secondaryRed;
      case ClassificationLevel.medium:
        return AppTheme.warningAmber;
      case ClassificationLevel.high:
        return AppTheme.primaryGreen;
    }
  }

  Color _levelBackground(ClassificationLevel level) {
    switch (level) {
      case ClassificationLevel.low:
        return AppTheme.secondaryRedLight;
      case ClassificationLevel.medium:
        return AppTheme.warningAmberLight;
      case ClassificationLevel.high:
        return AppTheme.primaryGreenSoft;
    }
  }

  double _markerPosition(ParameterClassification c) {
    final middleRange = c.highThreshold - c.lowThreshold;
    final min = c.lowThreshold - middleRange;
    final max = c.highThreshold + middleRange;
    if (max <= min) return 0.5;
    return ((c.value - min) / (max - min)).clamp(0.0, 1.0);
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    if (value.abs() < 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<ParameterClassification> _classifyAll(SoilAnalysisModel analysis) {
    return ParameterClassifier.classifyAll(
      AnalysisParameterValues(
        organicMatter: analysis.organicMatter,
        phCacl2: analysis.phCacl2,
        al3Plus: analysis.al3Plus,
        ca2Plus: analysis.ca2Plus,
        mg2Plus: analysis.mg2Plus,
        kPlus: analysis.kPlus,
        ctcEfetiva: analysis.ctcEfetiva,
        ctcPh7: analysis.ctcPh7,
        vPercent: analysis.vPercent,
        pst: analysis.pst,
        mPercent: analysis.mPercent,
      ),
    );
  }
}
