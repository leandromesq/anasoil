import 'dart:io';

import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/analysis_intake_state.dart';
import 'analysis_viewmodel.dart';
import 'widgets/analysis_flow_widgets.dart';

/// Página de nova análise
class AnalysisPage extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const AnalysisPage({super.key, this.onNavigateToHistory});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late final AnalysisViewModel _viewModel;
  File? _selectedFile;
  String? _inlineError;
  String? _inlineNotice;

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
      _inlineError = null;
      _inlineNotice = 'Documento enviado. Agora estamos extraindo as amostras.';
    } else if (command.error) {
      final errorMsg = command.result is Error
          ? (command.result as Error).error.toString()
          : 'Erro desconhecido';
      _inlineNotice = null;
      _inlineError = 'Não foi possível importar o documento. $errorMsg';
    }
  }

  void _onExtractChanged() {
    if (!mounted) return;
    setState(() {});

    final command = _viewModel.extractPdfCommand;
    if (command.completed) {
      final count = _viewModel.extractedAnalyses.length;
      _inlineError = null;
      _inlineNotice =
          '$count amostra(s) extraída(s). Revise os dados antes de salvar.';
    } else if (command.error) {
      final errorMsg = command.result is Error
          ? (command.result as Error).error.toString()
          : 'Erro desconhecido';
      _inlineNotice = null;
      _inlineError = 'Não foi possível extrair as amostras do PDF. $errorMsg';
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
          _inlineError = null;
          _inlineNotice =
              'PDF selecionado. Inicie a análise para enviar e extrair as amostras.';
        });

        _viewModel.setSelectedFileName(fileName);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _inlineNotice = null;
        _inlineError = 'Não foi possível selecionar o arquivo. $e';
      });
    }
  }

  void _removeSelection() {
    setState(() {
      _selectedFile = null;
      _inlineError = null;
      _inlineNotice = null;
    });
    _viewModel.clearSelection();
  }

  void _importAnother() {
    _viewModel.clearSelection();
    setState(() {
      _selectedFile = null;
      _inlineError = null;
      _inlineNotice = null;
    });
  }

  Future<void> _startAnalysis() async {
    if (_selectedFile == null) {
      setState(() {
        _inlineNotice = null;
        _inlineError = 'Importe um PDF de análise de solo antes de iniciar.';
      });
      return;
    }

    await _viewModel.uploadDocumentCommand.execute(_selectedFile!);
    if (!_viewModel.uploadDocumentCommand.completed) return;

    await _viewModel.extractPdfCommand.execute(_selectedFile!);
    if (_viewModel.extractPdfCommand.completed) {
      setState(() => _selectedFile = null);
    }
  }

  Future<void> _saveAllAnalyses() async {
    final result = await _viewModel.saveAllExtractedAnalyses();
    if (!mounted) return;

    if (result is Ok<int>) {
      setState(() {
        _inlineError = null;
        _inlineNotice = '${result.value} análise(s) salva(s) com sucesso.';
      });
    } else if (result is Error<int>) {
      setState(() {
        _inlineNotice = null;
        _inlineError = 'Não foi possível salvar as análises. ${result.error}';
      });
    }
  }

  Future<void> _discardExtractedAnalyses() async {
    final confirmed = await AnaSoilConfirmDialog.show(
      context,
      title: 'Descartar amostras extraídas?',
      message:
          'As amostras desta revisão serão removidas. O documento continuará importado para uma nova extração.',
      confirmLabel: 'Descartar',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    _viewModel.clearExtractedAnalyses();
    setState(() {
      _inlineNotice = null;
      _inlineError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = _viewModel.uploadDocumentCommand.running;
    final isExtracting = _viewModel.extractPdfCommand.running;
    final isProcessing = isUploading || isExtracting;
    final isSaving = _viewModel.intakeState.step == AnalysisIntakeStep.saving;
    final hasExtractedData = _viewModel.extractedAnalyses.isNotEmpty;
    final hasCompletedImport =
        _viewModel.intakeState.step == AnalysisIntakeStep.complete;

    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
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
                color: AppTheme.baseGray900,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: AnalysisWorkflowPanel(
                key: ValueKey(_viewModel.intakeState.step),
                step: _viewModel.intakeState.step,
              ),
            ),
            if (_inlineError != null) ...[
              const SizedBox(height: 12),
              AnaSoilInlineMessage(
                message: _inlineError!,
                tone: AnaSoilStatusTone.danger,
                icon: Icons.error_outline,
              ),
            ] else if (_inlineNotice != null) ...[
              const SizedBox(height: 12),
              AnaSoilInlineMessage(
                message: _inlineNotice!,
                tone: AnaSoilStatusTone.success,
                icon: Icons.check_circle_outline,
              ),
            ],
            const SizedBox(height: 24),

            if (!hasCompletedImport &&
                _selectedFile == null &&
                !hasExtractedData)
              AnalysisImportCard(onTap: _pickDocument)
            else if (!hasCompletedImport &&
                _selectedFile != null &&
                !hasExtractedData)
              SelectedPdfCard(
                fileName: _viewModel.selectedFileName ?? 'documento.pdf',
                canRemove: !_viewModel.uploadDocumentCommand.running,
                onRemove: _removeSelection,
              ),

            if (!hasCompletedImport && !hasExtractedData) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _startAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.baseWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AnaSoilRadius.md),
                    ),
                    disabledBackgroundColor: AppTheme.primaryGreen,
                    disabledForegroundColor: AppTheme.baseWhite,
                  ),
                  child: isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppTheme.baseWhite,
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

            if (hasCompletedImport) ...[
              AnalysisSaveSuccessCard(
                savedAnalyses: _viewModel.lastSavedAnalyses,
                onImportAnother: _importAnother,
                onNavigateToHistory: widget.onNavigateToHistory,
              ),
            ],

            if (hasExtractedData) ...[
              ExtractedAnalysisReviewSection(
                analyses: _viewModel.extractedAnalyses,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _discardExtractedAnalyses,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.baseGray600,
                        side: const BorderSide(color: AppTheme.baseGray400),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AnaSoilRadius.md),
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
                      onPressed: isSaving ? null : _saveAllAnalyses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.baseWhite,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AnaSoilRadius.md),
                        ),
                        disabledBackgroundColor: AppTheme.primaryGreen,
                        disabledForegroundColor: AppTheme.baseWhite,
                      ),
                      child: isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.baseWhite,
                                    strokeWidth: 2.2,
                                  ),
                                ),
                                const SizedBox(width: AnaSoilSpacing.sm),
                                Text(
                                  'Salvando...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.baseWhite,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
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
}
