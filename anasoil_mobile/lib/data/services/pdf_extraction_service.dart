import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../domain/models/soil_analysis.dart';
import '../../utils/result.dart';

/// Serviço de extração de dados de PDFs de análise de solo (certificados DMLab)
class PdfExtractionService {
  /// Extrai texto bruto do PDF e faz parsing das tabelas
  Future<Result<List<SoilAnalysis>>> extractFromFile(
    File pdfFile, {
    required String userId,
    String? documentId,
  }) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      return extractFromBytes(bytes, userId: userId, documentId: documentId);
    } catch (e) {
      return Result.error(Exception('Erro ao ler arquivo PDF: $e'));
    }
  }

  /// Extrai dados de análise a partir dos bytes do PDF
  Future<Result<List<SoilAnalysis>>> extractFromBytes(
    Uint8List bytes, {
    required String userId,
    String? documentId,
  }) async {
    try {
      final text = _extractTextFromPdf(bytes);

      if (text.trim().isEmpty) {
        return Result.error(
          Exception(
            'Não foi possível extrair texto do PDF. '
            'O PDF pode ser uma imagem escaneada.',
          ),
        );
      }

      final analyses = _parseAnalysesFromText(
        text,
        userId: userId,
        documentId: documentId,
      );

      if (analyses.isEmpty) {
        return Result.error(
          Exception(
            'Nenhuma análise encontrada no PDF. '
            'Verifique se o formato do certificado é suportado.',
          ),
        );
      }

      return Result.ok(analyses);
    } catch (e) {
      return Result.error(Exception('Erro ao extrair dados do PDF: $e'));
    }
  }

  /// Cria uma SoilAnalysis a partir de dados manuais (fallback)
  SoilAnalysis createFromManualInput({
    required String userId,
    String? documentId,
    required String dmlabNumber,
    required DateTime analysisDate,
    required String sampleNumber,
    required String sampleCode,
    required String farmName,
    double? depthCm,
    double? organicMatter,
    double? phCacl2,
    double? al3Plus,
    double? ca2Plus,
    double? mg2Plus,
    double? kPlus,
    double? ctcEfetiva,
    double? ctcPh7,
    double? vPercent,
    double? pst,
    double? mPercent,
  }) {
    return SoilAnalysis(
      id: '',
      userId: userId,
      documentId: documentId,
      dmlabNumber: dmlabNumber,
      analysisDate: analysisDate,
      sampleNumber: sampleNumber,
      sampleCode: sampleCode,
      farmName: farmName,
      depthCm: depthCm,
      organicMatter: organicMatter,
      phCacl2: phCacl2,
      al3Plus: al3Plus,
      ca2Plus: ca2Plus,
      mg2Plus: mg2Plus,
      kPlus: kPlus,
      ctcEfetiva: ctcEfetiva,
      ctcPh7: ctcPh7,
      vPercent: vPercent,
      pst: pst,
      mPercent: mPercent,
      createdAt: DateTime.now(),
    );
  }

  /// Valida os dados extraídos da análise
  List<String> validate(SoilAnalysis analysis) {
    final errors = <String>[];

    if (analysis.phCacl2 != null &&
        (analysis.phCacl2! < 0 || analysis.phCacl2! > 14)) {
      errors.add('pH deve estar entre 0 e 14');
    }
    if (analysis.vPercent != null &&
        (analysis.vPercent! < 0 || analysis.vPercent! > 100)) {
      errors.add('V% deve estar entre 0 e 100');
    }
    if (analysis.mPercent != null &&
        (analysis.mPercent! < 0 || analysis.mPercent! > 100)) {
      errors.add('m% deve estar entre 0 e 100');
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Extração de texto via Syncfusion
  // ---------------------------------------------------------------------------

  /// Extrai texto de todas as páginas do PDF usando Syncfusion
  String _extractTextFromPdf(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();
    return text;
  }

  // ---------------------------------------------------------------------------
  // Parsing do texto extraído
  // ---------------------------------------------------------------------------

  /// Faz o parsing das linhas de análise a partir do texto extraído.
  ///
  /// O Syncfusion extrai o texto do PDF com cada célula da tabela em uma linha
  /// separada. A tabela principal do certificado DMLab possui 25 colunas por
  /// amostra, na seguinte ordem:
  ///
  ///  0: Nº DMLab       8: Prof(cm)      16: S
  ///  1: Data            9: Mat.Org.      17: Si
  ///  2: Amostra        10: pH CaCl₂      18: SB
  ///  3: Código         11: P (Resina)    19: CTC
  ///  4: Fazenda        12: K             20: V%
  ///  5: Zona           13: Ca²⁺          21: m%
  ///  6: Talhão         14: Mg²⁺          22: K%
  ///  7: --             15: Al³⁺          23: Ca%
  ///                                      24: Mg%
  ///
  /// Parâmetros que precisamos extrair (11 de análise + identificação):
  /// Mat.Org., pH, K, Ca, Mg, Al, SB (≈CTC efetiva), CTC (pH7), V%, m%
  /// PST não aparece na tabela DMLab.
  List<SoilAnalysis> _parseAnalysesFromText(
    String text, {
    required String userId,
    String? documentId,
  }) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // --- Extrai informações do cabeçalho ---
    String certificateNumber = '';
    DateTime analysisDate = DateTime.now();
    String solicitante = '';
    String interessado = '';
    String dataEntrada = '';
    String material = '';

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Certificado nº (ex: "Certificado de Análises nº 23-562.0")
      if (certificateNumber.isEmpty) {
        final certMatch = RegExp(
          r'(?:Certificado\s+de\s+An[áa]lises\s+n[ºo°]\s*|N[ºo°]\.?\s*)(.+)',
          caseSensitive: false,
        ).firstMatch(line);
        if (certMatch != null) {
          certificateNumber = certMatch.group(1)?.trim() ?? '';
        }
      }

      // Solicitante: valor na próxima linha
      if (RegExp(r'^Solicitante\s*:', caseSensitive: false).hasMatch(line)) {
        final inline = line.replaceFirst(RegExp(r'^Solicitante\s*:\s*', caseSensitive: false), '').trim();
        if (inline.isNotEmpty) {
          solicitante = inline;
        } else if (i + 1 < lines.length) {
          solicitante = lines[i + 1];
        }
      }

      // Interessado: valor na próxima linha
      if (RegExp(r'^Interessado\s*:', caseSensitive: false).hasMatch(line)) {
        final inline = line.replaceFirst(RegExp(r'^Interessado\s*:\s*', caseSensitive: false), '').trim();
        if (inline.isNotEmpty) {
          interessado = inline;
        } else if (i + 1 < lines.length) {
          interessado = lines[i + 1];
        }
      }

      // Data de entrada: valor na próxima linha (formato "dd/mm" ou "dd/mm/aaaa")
      if (RegExp(r'^Data\s+de\s+entrada\s*:', caseSensitive: false).hasMatch(line)) {
        final inline = line.replaceFirst(RegExp(r'^Data\s+de\s+entrada\s*:\s*', caseSensitive: false), '').trim();
        if (inline.isNotEmpty) {
          dataEntrada = inline;
        } else if (i + 1 < lines.length) {
          dataEntrada = lines[i + 1];
        }
      }

      // Material: valor na próxima linha
      if (RegExp(r'^Material\s*:', caseSensitive: false).hasMatch(line)) {
        final inline = line.replaceFirst(RegExp(r'^Material\s*:\s*', caseSensitive: false), '').trim();
        if (inline.isNotEmpty) {
          material = inline;
        } else if (i + 1 < lines.length) {
          material = lines[i + 1];
        }
      }

      // Data completa (ex: "9 de janeiro de 2023")
      final dateFullMatch = RegExp(
        r'(\d{1,2})\s+de\s+(\w+)\s+de\s+(\d{4})',
        caseSensitive: false,
      ).firstMatch(line);
      if (dateFullMatch != null) {
        final day = int.tryParse(dateFullMatch.group(1)!) ?? 1;
        final monthStr = dateFullMatch.group(2)!.toLowerCase();
        final year = int.tryParse(dateFullMatch.group(3)!) ?? 2024;
        final month = _monthFromName(monthStr);
        if (month > 0) {
          analysisDate = DateTime(year, month, day);
        }
      }
    }

    // --- Localiza início da tabela de resultados ---
    // Procura pela sequência de cabeçalhos da tabela (inicia com "Nº" seguido
    // de "DMLab"). O bloco de dados começa após as linhas de unidades.
    int tableDataStart = -1;
    for (var i = 0; i < lines.length - 1; i++) {
      // Detecta o cabeçalho da tabela principal (primeira ocorrência)
      if (lines[i] == 'Nº' && i + 1 < lines.length && lines[i + 1] == 'DMLab') {
        // Pula cabeçalhos + unidades: procura a primeira linha que seja um
        // número de 3 dígitos (nº DMLab da amostra) após o cabeçalho
        for (var j = i + 2; j < lines.length; j++) {
          if (RegExp(r'^\d{3,6}$').hasMatch(lines[j])) {
            tableDataStart = j;
            break;
          }
        }
        break;
      }
    }

    if (tableDataStart < 0) {
      return [];
    }

    // --- Localiza fim da tabela de resultados ---
    // A segunda tabela (granulometria/micronutrientes) começa com outro "Nº"
    // + "DMLab", ou dados não relevantes começam com sequências de "--".
    int tableDataEnd = lines.length;
    for (var i = tableDataStart + 1; i < lines.length - 1; i++) {
      if (lines[i] == 'Nº' && i + 1 < lines.length && lines[i + 1] == 'DMLab') {
        tableDataEnd = i;
        break;
      }
      // Muitas linhas "--" consecutivas indicam preenchimento vazio entre tabelas
      if (i + 5 < lines.length &&
          lines[i] == '--' &&
          lines[i + 1] == '--' &&
          lines[i + 2] == '--' &&
          lines[i + 3] == '--' &&
          lines[i + 4] == '--' &&
          lines[i + 5] == '--') {
        tableDataEnd = i;
        break;
      }
    }

    // --- Coleta tokens da tabela ---
    final tokens = lines.sublist(tableDataStart, tableDataEnd);

    // --- Segmenta tokens em blocos de 25 colunas por amostra ---
    // Cada amostra começa com seu nº DMLab (3-6 dígitos).
    // A primeira amostra traz todos os 25 campos; amostras subsequentes
    // podem ter "--" para Data, Amostra, Código (repetidos do lote).
    final analyses = <SoilAnalysis>[];
    final sampleStartIndices = <int>[];

    for (var i = 0; i < tokens.length; i++) {
      if (RegExp(r'^\d{3,6}$').hasMatch(tokens[i])) {
        sampleStartIndices.add(i);
      }
    }

    for (var s = 0; s < sampleStartIndices.length; s++) {
      final start = sampleStartIndices[s];
      final end = s + 1 < sampleStartIndices.length
          ? sampleStartIndices[s + 1]
          : tokens.length;

      final block = tokens.sublist(start, end);
      if (block.length < 15) continue; // bloco incompleto

      final dmlabNum = block[0];

      // Encontra o índice da profundidade (formato "X-Y") para alinhar as
      // colunas corretamente. A primeira amostra pode não ter Data/Amostra/
      // Código (vem direto Fazenda após nº DMLab), enquanto amostras
      // subsequentes têm "--" nesses campos.
      int depthIdx = -1;
      for (var i = 1; i < block.length && i < 10; i++) {
        if (_looksLikeDepth(block[i])) {
          depthIdx = i;
          break;
        }
      }

      if (depthIdx < 0) continue; // não encontrou profundidade

      // A partir da profundidade, os valores numéricos seguem na ordem fixa:
      // depthIdx+0: Prof(cm)
      // depthIdx+1: Mat.Org.
      // depthIdx+2: pH CaCl₂
      // depthIdx+3: P (Resina) → PST
      // depthIdx+4: K
      // depthIdx+5: Ca²⁺
      // depthIdx+6: Mg²⁺
      // depthIdx+7: Al³⁺
      // depthIdx+8: H+Al SMP → ignorado
      // depthIdx+9: S → ignorado
      // depthIdx+10: Si → ignorado
      // depthIdx+11: SB → usado no cálculo CTC efetiva (SB + Al)
      // depthIdx+12: CTC → CTC pH 7,0
      // depthIdx+13: V%
      // depthIdx+14: m%
      // depthIdx+15: K% → ignorado
      // depthIdx+16: Ca% → ignorado
      // depthIdx+17: Mg% → ignorado

      String at(int offset) =>
          depthIdx + offset < block.length ? block[depthIdx + offset] : '--';

      // Extrai identificação: Fazenda fica entre nº DMLab e profundidade
      // Ordem esperada antes da prof: [Data?, Amostra?, Código?], Fazenda, Zona, Talhão, Prof
      // Fazenda está 3 posições antes da profundidade (Fazenda, Zona, Talhão, Prof)
      final farmName = depthIdx >= 4 ? block[depthIdx - 3] : '';
      final sampleCode = depthIdx >= 5
          ? block[depthIdx - 4]
          : 'AMOSTRA-${s + 1}';

      // CTC efetiva = SB + Al
      final sbVal = _parseValue(at(11));
      final alVal = _parseValue(at(7));
      final ctcEfetiva = (sbVal != null && alVal != null)
          ? sbVal + alVal
          : null;

      analyses.add(
        SoilAnalysis(
          id: '',
          userId: userId,
          documentId: documentId,
          dmlabNumber: dmlabNum,
          analysisDate: analysisDate,
          sampleNumber: '${s + 1}',
          sampleCode: sampleCode != '--' ? sampleCode : 'AMOSTRA-${s + 1}',
          farmName: farmName != '--' ? farmName : '',
          depthCm: _parseDepth(at(0)),
          solicitante: solicitante.isNotEmpty ? solicitante : null,
          interessado: interessado.isNotEmpty ? interessado : null,
          dataEntrada: dataEntrada.isNotEmpty ? dataEntrada : null,
          material: material.isNotEmpty ? material : null,
          organicMatter: _parseValue(at(1)),
          phCacl2: _parseValue(at(2)),
          al3Plus: _parseValue(at(7)),
          ca2Plus: _parseValue(at(5)),
          mg2Plus: _parseValue(at(6)),
          kPlus: _parseValue(at(4)),
          ctcEfetiva: ctcEfetiva, // SB + Al
          ctcPh7: _parseValue(at(12)), // CTC na tabela DMLab
          vPercent: _parseValue(at(13)),
          pst: _parseValue(at(3)), // P (Resina) na tabela DMLab
          mPercent: _parseValue(at(14)),
          createdAt: DateTime.now(),
        ),
      );
    }

    return analyses;
  }

  /// Tenta parsear um valor numérico de uma string da tabela.
  /// Retorna null para "--", "<1", "<2", strings vazias etc.
  double? _parseValue(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '--') return null;

    // Valores como "<1" ou "<2" → retorna o número (limite de quantificação)
    if (trimmed.startsWith('<')) {
      final num = trimmed.substring(1).replaceAll(',', '.');
      return double.tryParse(num);
    }

    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  /// Parseia profundidade no formato "0-20", "20-40" etc.
  /// Retorna a profundidade máxima como double.
  double? _parseDepth(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '--') return null;

    // Formato "0-20" → retorna 20
    final depthMatch = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(trimmed);
    if (depthMatch != null) {
      return double.tryParse(depthMatch.group(2)!);
    }

    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  /// Verifica se uma string parece ser uma profundidade (ex: "0-20", "20-40")
  bool _looksLikeDepth(String value) {
    return RegExp(r'^\d+-\d+$').hasMatch(value.trim());
  }

  /// Converte nome do mês em português para número
  int _monthFromName(String name) {
    const months = {
      'janeiro': 1,
      'fevereiro': 2,
      'março': 3,
      'marco': 3,
      'abril': 4,
      'maio': 5,
      'junho': 6,
      'julho': 7,
      'agosto': 8,
      'setembro': 9,
      'outubro': 10,
      'novembro': 11,
      'dezembro': 12,
    };
    return months[name.toLowerCase()] ?? 0;
  }
}
