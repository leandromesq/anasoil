import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/dependency_injection.dart';
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
  }

  @override
  void dispose() {
    _viewModel.uploadDocumentCommand.removeListener(_onUploadChanged);
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

  Future<void> _startUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, importe um documento primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _viewModel.uploadDocumentCommand.execute(_selectedFile!);

    if (_viewModel.uploadDocumentCommand.completed) {
      setState(() {
        _selectedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = _viewModel.uploadDocumentCommand.running;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
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
            if (_selectedFile == null)
              _buildImportCard()
            else
              _buildSelectedFileCard(),

            const SizedBox(height: 32),

            // Botão Iniciar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isUploading ? null : _startUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.green[300],
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
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
