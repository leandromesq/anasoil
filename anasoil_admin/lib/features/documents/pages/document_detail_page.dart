import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/repositories/document_repository.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentDetailPage extends StatefulWidget {
  final String documentId;
  const DocumentDetailPage({super.key, required this.documentId});

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  DocumentModel? _document;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final repo = locator<DocumentRepository>();
      final doc = await repo.getById(widget.documentId);
      if (doc == null) {
        setState(() {
          _error = 'Documento não encontrado';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _document = doc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Documento não encontrado';
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

  Future<void> _openPdf() async {
    if (_document?.fileUrl == null) return;
    final uri = Uri.parse(_document!.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _deleteDocument() async {
    final confirmed = await AnaSoilConfirmDialog.show(
      context,
      title: 'Excluir documento?',
      message:
          'Deseja realmente excluir "${_document?.fileName}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await locator<DocumentRepository>().deleteDocument(widget.documentId);
      if (mounted) {
        AnaSoilToast.success(context, 'Documento excluído com sucesso!');
        context.go('/documents');
      }
    } catch (e) {
      if (mounted) {
        AnaSoilToast.error(context, 'Erro ao excluir: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLayout(
        title: 'Documento',
        backRoute: '/documents',
        backTooltip: 'Voltar para Documentos',
        body: AnaSoilLoadingState(message: 'Carregando documento...'),
      );
    }

    if (_error != null || _document == null) {
      return AppLayout(
        title: 'Documento',
        backRoute: '/documents',
        backTooltip: 'Voltar para Documentos',
        body: AnaSoilEmptyState(
          icon: Symbols.folder,
          title: _error ?? 'Documento não encontrado',
          message:
              'Volte para a lista de documentos e selecione outro registro.',
          actionLabel: 'Voltar para Documentos',
          onAction: () => context.go('/documents'),
        ),
      );
    }

    final doc = _document!;

    return AppLayout(
      title: 'Documento',
      backRoute: '/documents',
      backTooltip: 'Voltar para Documentos',
      actions: [
        TextButton.icon(
          onPressed: _deleteDocument,
          icon: Icon(Symbols.delete, size: 18, color: AppTheme.secondaryRed),
          label: Text(
            'Excluir',
            style: TextStyle(color: AppTheme.secondaryRed),
          ),
        ),
        const SizedBox(width: 8),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
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
                              Symbols.picture_as_pdf,
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
                                  doc.fileName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doc.mimeType,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.baseGray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInfoRow('Proprietário', _getUserName(doc.userId)),
                      _buildInfoRow('Tamanho', _formatFileSize(doc.fileSize)),
                      _buildInfoRow('Tipo', doc.mimeType),
                      _buildInfoRow('Criado em', _formatDate(doc.createdAt)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openPdf,
                          icon: Icon(Symbols.visibility),
                          label: const Text('Visualizar PDF'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            width: 120,
            child: Text(
              label,
              style: TextStyle(
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
