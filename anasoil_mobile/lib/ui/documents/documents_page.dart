import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/dependency_injection.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento removido'),
          backgroundColor: Colors.green,
        ),
      );
      _viewModel.loadDocumentsCommand.clear();
      _viewModel.loadDocumentsCommand.execute();
    } else if (_viewModel.deleteDocumentCommand.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao remover documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(SoilDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover documento'),
        content: Text('Deseja remover "${doc.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _viewModel.deleteDocumentCommand.execute(doc.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? _buildErrorState()
              : documents.isEmpty
                  ? _buildEmptyState()
                  : _buildDocumentList(documents),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar documentos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDocuments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum documento encontrado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Importe documentos na tela de análise',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(List<SoilDocument> documents) {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return _buildDocumentCard(doc);
        },
      ),
    );
  }

  Widget _buildDocumentCard(SoilDocument doc) {
    return InkWell(
      onTap: () {
        context.push('/documents/preview', extra: doc);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.red[700],
                size: 28,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatFileSize(doc.fileSize)}  •  ${_formatDate(doc.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(doc),
              icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
              tooltip: 'Remover',
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
