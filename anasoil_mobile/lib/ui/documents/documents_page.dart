import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/document.dart';
import '../home/analysis_viewmodel.dart';

/// Tela de listagem de documentos do usuário
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late final AnalysisViewModel _viewModel;
  String? _inlineMessage;
  AnaSoilStatusTone _inlineTone = AnaSoilStatusTone.neutral;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AnalysisViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.deleteDocumentCommand.addListener(_onDeleteChanged);
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    _viewModel.loadDocumentsCommand.clear();
    await _viewModel.loadDocumentsCommand.execute();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.deleteDocumentCommand.removeListener(_onDeleteChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onDeleteChanged() {
    if (!mounted) return;
    setState(() {});

    if (_viewModel.deleteDocumentCommand.completed) {
      setState(() {
        _inlineTone = AnaSoilStatusTone.success;
        _inlineMessage = 'Documento removido.';
      });
      _viewModel.loadDocumentsCommand.clear();
      _viewModel.loadDocumentsCommand.execute();
    } else if (_viewModel.deleteDocumentCommand.error) {
      setState(() {
        _inlineTone = AnaSoilStatusTone.danger;
        _inlineMessage = 'Não foi possível remover o documento.';
      });
    }
  }

  Future<void> _confirmDelete(SoilDocument doc) async {
    final confirmed = await AnaSoilConfirmDialog.show(
      context,
      title: 'Remover documento?',
      message:
          'Deseja remover "${doc.fileName}"? Esta ação não remove análises já salvas.',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _viewModel.deleteDocumentCommand.execute(doc.id);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _viewModel.loadDocumentsCommand.running;
    final hasError = _viewModel.loadDocumentsCommand.error;
    final documents = _viewModel.documents;

    return Scaffold(
      backgroundColor: AppTheme.baseGray50,
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        backgroundColor: AppTheme.baseWhite,
        foregroundColor: AppTheme.baseGray900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: isLoading
          ? const AnaSoilLoadingState(message: 'Carregando documentos...')
          : hasError
          ? AnaSoilEmptyState(
              icon: Icons.error_outline,
              title: 'Erro ao carregar documentos',
              message:
                  'Verifique a conexão e tente buscar os documentos novamente.',
              actionLabel: 'Tentar novamente',
              onAction: _loadDocuments,
            )
          : documents.isEmpty
          ? const AnaSoilEmptyState(
              icon: Icons.folder_open,
              title: 'Nenhum documento encontrado',
              message:
                  'Importe um PDF na tela de análise para manter seus documentos aqui.',
            )
          : _buildDocumentList(documents),
    );
  }

  Widget _buildDocumentList(List<SoilDocument> documents) {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      color: AppTheme.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(AnaSoilSpacing.lg),
        itemCount: documents.length + (_inlineMessage == null ? 0 : 1),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AnaSoilSpacing.md),
        itemBuilder: (context, index) {
          if (_inlineMessage != null && index == 0) {
            return AnaSoilInlineMessage(
              message: _inlineMessage!,
              icon: _inlineTone == AnaSoilStatusTone.danger
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              tone: _inlineTone,
            );
          }
          final docIndex = _inlineMessage == null ? index : index - 1;
          return _DocumentCard(
            doc: documents[docIndex],
            fileSize: _formatFileSize(documents[docIndex].fileSize),
            date: _formatDate(documents[docIndex].createdAt),
            onOpen: () =>
                context.push('/documents/preview', extra: documents[docIndex]),
            onDelete: () => _confirmDelete(documents[docIndex]),
          );
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final SoilDocument doc;
  final String fileSize;
  final String date;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.doc,
    required this.fileSize,
    required this.date,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        child: AnaSoilSurface(
          padding: const EdgeInsets.all(AnaSoilSpacing.lg),
          radius: AnaSoilRadius.md,
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
                  size: 28,
                ),
              ),
              const SizedBox(width: AnaSoilSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseGray900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AnaSoilSpacing.xs),
                    Text(
                      '$fileSize  •  $date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.baseGray500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.baseGray400,
                ),
                tooltip: 'Remover',
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.baseGray400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
