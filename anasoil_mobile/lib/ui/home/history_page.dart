import 'package:flutter/material.dart';

/// Página de histórico de análises
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Mock data - TODO: substituir por dados reais
  final List<Map<String, dynamic>> _analyses = [
    {
      'title': 'Análise Solo - Fazenda Norte',
      'date': '2025, 30 de Agosto',
      'consultant': 'José Leandro Mesquita',
      'id': '1',
    },
    {
      'title': 'Análise Solo - Fazenda Norte',
      'date': '2025, 30 de Agosto',
      'consultant': 'José Leandro Mesquita',
      'id': '2',
    },
    {
      'title': 'Análise Solo - Fazenda Norte',
      'date': '2025, 30 de Agosto',
      'consultant': 'José Leandro Mesquita',
      'id': '3',
    },
    {
      'title': 'Análise Solo - Fazenda Norte',
      'date': '2025, 30 de Agosto',
      'consultant': 'José Leandro Mesquita',
      'id': '4',
    },
  ];

  void _deleteAnalysis(String id) {
    // TODO: Implementar exclusão de análise
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Análise'),
        content: const Text('Deseja realmente excluir esta análise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _analyses.removeWhere((a) => a['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Análise excluída'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  void _downloadAnalysis(String id) {
    // TODO: Implementar download de análise
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _analyses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _analyses.length,
              itemBuilder: (context, index) {
                final analysis = _analyses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnalysisCard(analysis),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma análise encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(Map<String, dynamic> analysis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e botão deletar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis['date'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _deleteAnalysis(analysis['id']),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nome do consultor
          Text(
            analysis['consultant'],
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // Botão de download
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.download, color: Colors.green[700]),
                onPressed: () => _downloadAnalysis(analysis['id']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
