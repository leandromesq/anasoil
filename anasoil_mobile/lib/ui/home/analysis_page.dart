import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/dependency_injection.dart';
import '../../domain/models/soil_analysis.dart';
import '../../domain/models/soil_parameter_classifier.dart';
import '../../utils/result.dart';
import 'analysis_viewmodel.dart';

/// Página de nova análise
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late final AnalysisViewModel _viewModel;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AnalysisViewModel>();
    _viewModel.uploadDocumentCommand.addListener(_onUploadChanged);
    _viewModel.extractPdfCommand.addListener(_onExtractChanged);
  }

  @override
  void dispose() {
    _viewModel.uploadDocumentCommand.removeListener(_onUploadChanged);
    _viewModel.extractPdfCommand.removeListener(_onExtractChanged);
    super.dispose();
  }

  void _onUploadChanged() {
    if (!mounted) return;
    setState(() {});

    final command = _viewModel.uploadDocumentCommand;

    if (command.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento importado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (command.error) {
      final errorMsg = command.result is Error
          ? (command.result as Error).error.toString()
          : 'Erro desconhecido';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao importar: $errorMsg'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onExtractChanged() {
    if (!mounted) return;
    setState(() {});

    final command = _viewModel.extractPdfCommand;

    if (command.completed) {
      final count = _viewModel.extractedAnalyses.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count amostra(s) extraída(s) do PDF!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (command.error) {
      final errorMsg = command.result is Error
          ? (command.result as Error).error.toString()
          : 'Erro desconhecido';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na extração: $errorMsg'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        setState(() {
          _selectedFile = file;
        });

        _viewModel.setSelectedFileName(fileName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar arquivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeSelection() {
    setState(() {
      _selectedFile = null;
    });
    _viewModel.clearSelection();
  }

  Future<void> _startAnalysis() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, importe um documento primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 1. Upload do documento
    await _viewModel.uploadDocumentCommand.execute(_selectedFile!);

    if (!_viewModel.uploadDocumentCommand.completed) return;

    // 2. Extrair dados do PDF
    await _viewModel.extractPdfCommand.execute(_selectedFile!);

    if (_viewModel.extractPdfCommand.completed) {
      setState(() {
        _selectedFile = null;
      });
    }
  }

  Future<void> _saveAllAnalyses() async {
    final result = await _viewModel.saveAllExtractedAnalyses();

    if (!mounted) return;

    if (result is Ok<int>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.value} análise(s) salva(s) com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (result is Error<int>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = _viewModel.uploadDocumentCommand.running;
    final isExtracting = _viewModel.extractPdfCommand.running;
    final isProcessing = isUploading || isExtracting;
    final hasExtractedData = _viewModel.extractedAnalyses.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Iniciar Nova Análise',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // Card de importar documento ou arquivo selecionado
            if (_selectedFile == null && !hasExtractedData)
              _buildImportCard()
            else if (_selectedFile != null && !hasExtractedData)
              _buildSelectedFileCard(),

            if (!hasExtractedData) ...[
              const SizedBox(height: 32),

              // Botão Iniciar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _startAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.green[300],
                  ),
                  child: isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isUploading ? 'Enviando...' : 'Extraindo...',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Iniciar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],

            // Resultados da extração
            if (hasExtractedData) ...[
              _buildExtractedDataSection(),
              const SizedBox(height: 24),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _viewModel.clearExtractedAnalyses();
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Descartar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAllAnalyses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar Dados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard() {
    return GestureDetector(
      onTap: _pickDocument,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Colors.grey[400]!,
          strokeWidth: 2,
          dashWidth: 8,
          dashSpace: 4,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Importar Documento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '*Formatos Suportados: .pdf',
                style: TextStyle(fontSize: 13, color: Colors.red[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard() {
    final fileName = _viewModel.selectedFileName ?? 'documento.pdf';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[700]!, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF selecionado',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _viewModel.uploadDocumentCommand.running
                ? null
                : _removeSelection,
            icon: Icon(Icons.close, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedDataSection() {
    final analyses = _viewModel.extractedAnalyses;

    // Pega infos do documento da primeira análise (são iguais para todas)
    final firstAnalysis = analyses.isNotEmpty ? analyses.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Infos do documento
        if (firstAnalysis != null &&
            (firstAnalysis.solicitante != null ||
                firstAnalysis.interessado != null ||
                firstAnalysis.dataEntrada != null ||
                firstAnalysis.material != null))
          _buildDocumentInfoCard(firstAnalysis),

        if (firstAnalysis != null &&
            (firstAnalysis.solicitante != null ||
                firstAnalysis.interessado != null ||
                firstAnalysis.dataEntrada != null ||
                firstAnalysis.material != null))
          const SizedBox(height: 16),

        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 24),
            const SizedBox(width: 8),
            Text(
              '${analyses.length} amostra(s) extraída(s)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista de amostras extraídas
        ...analyses.asMap().entries.map(
          (entry) => _buildAnalysisCard(entry.value, entry.key),
        ),
      ],
    );
  }

  Widget _buildDocumentInfoCard(SoilAnalysis analysis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Informações do Documento',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (analysis.solicitante != null)
            _buildDocInfoRow('Solicitante', analysis.solicitante!),
          if (analysis.interessado != null)
            _buildDocInfoRow('Interessado', analysis.interessado!),
          if (analysis.dataEntrada != null)
            _buildDocInfoRow('Data de Entrada', analysis.dataEntrada!),
          if (analysis.material != null)
            _buildDocInfoRow('Material', analysis.material!),
        ],
      ),
    );
  }

  Widget _buildDocInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
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
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(SoilAnalysis analysis, int index) {
    final classifications = SoilParameterClassifier.classifyAll(analysis);

    // Todos os parâmetros avaliados
    final allParams = [
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
    ];
    final missingParams = allParams
        .where((p) => p.$2 == null)
        .map((p) => p.$1)
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Amostra ${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                analysis.sampleCode.isNotEmpty ? analysis.sampleCode : 'N/A',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fazenda e DMLab
          _buildDataRow(
            'Fazenda',
            analysis.farmName.isNotEmpty ? analysis.farmName : 'N/A',
          ),
          _buildDataRow(
            'Nº DMLab',
            analysis.dmlabNumber.isNotEmpty ? analysis.dmlabNumber : 'N/A',
          ),

          const Divider(height: 20),

          // Legenda de classificação
          _buildLegend(),
          const SizedBox(height: 12),

          // Parâmetros da Análise
          const Text(
            'Parâmetros da Análise',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...classifications.map((c) => _buildClassifiedChip(c)),
              ...missingParams.map((label) => _buildNaChip(label)),
            ],
          ),
        ],
      ),
    );
  }

  Color _levelColor(SoilLevel level) {
    switch (level) {
      case SoilLevel.baixo:
        return const Color(0xFFE53935); // vermelho
      case SoilLevel.medio:
        return const Color(0xFFFFA726); // laranja
      case SoilLevel.alto:
        return const Color(0xFF43A047); // verde
    }
  }

  Color _levelBgColor(SoilLevel level) {
    switch (level) {
      case SoilLevel.baixo:
        return const Color(0xFFFFEBEE);
      case SoilLevel.medio:
        return const Color(0xFFFFF3E0);
      case SoilLevel.alto:
        return const Color(0xFFE8F5E9);
    }
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(SoilLevel.baixo, 'Baixo'),
        const SizedBox(width: 12),
        _buildLegendItem(SoilLevel.medio, 'Médio'),
        const SizedBox(width: 12),
        _buildLegendItem(SoilLevel.alto, 'Alto'),
      ],
    );
  }

  Widget _buildLegendItem(SoilLevel level, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _levelColor(level),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildClassifiedChip(SoilClassification classification) {
    final color = _levelColor(classification.level);
    final bgColor = _levelBgColor(classification.level);
    final valueStr =
        classification.value == classification.value.roundToDouble()
        ? classification.value.toStringAsFixed(0)
        : classification.value.toStringAsFixed(
            classification.value < 1 ? 2 : 1,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${classification.label}: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'Poppins',
                  ),
                ),
                TextSpan(
                  text: valueStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
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
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontFamily: 'Poppins',
              ),
            ),
            TextSpan(
              text: 'N/A',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter para criar borda tracejada
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 8,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
