import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de análise de solo extraída do certificado DMLab.
///
/// Parâmetros avaliados:
/// - Matéria Orgânica (dag/kg)
/// - pH CaCl₂
/// - Al³⁺ (cmolc/dm³)
/// - Ca²⁺ (cmolc/dm³)
/// - Mg²⁺ (cmolc/dm³)
/// - K⁺ (cmolc/dm³)
/// - CTC efetiva (cmolc/dm³)
/// - CTC pH 7,0 (cmolc/dm³)
/// - Saturação por Bases V (%)
/// - PST (%)
/// - Saturação por Al m (%)
class SoilAnalysis {
  final String id;
  final String? documentId;
  final String userId;

  // Identificação da amostra
  final String dmlabNumber;
  final DateTime analysisDate;
  final String sampleNumber;
  final String sampleCode;
  final String farmName;
  final double? depthCm;

  // Informações do documento
  final String? solicitante;
  final String? interessado;
  final String? dataEntrada;
  final String? material;

  // Parâmetros da análise
  final double? organicMatter; // Matéria Orgânica (dag/kg)
  final double? phCacl2; // pH CaCl₂
  final double? al3Plus; // Al³⁺ (cmolc/dm³)
  final double? ca2Plus; // Ca²⁺ (cmolc/dm³)
  final double? mg2Plus; // Mg²⁺ (cmolc/dm³)
  final double? kPlus; // K⁺ (cmolc/dm³)
  final double? ctcEfetiva; // CTC efetiva (cmolc/dm³)
  final double? ctcPh7; // CTC pH 7,0 (cmolc/dm³)
  final double? vPercent; // Saturação por Bases V (%)
  final double? pst; // PST (%)
  final double? mPercent; // Saturação por Al m (%)

  final DateTime createdAt;

  const SoilAnalysis({
    required this.id,
    required this.userId,
    this.documentId,
    required this.dmlabNumber,
    required this.analysisDate,
    required this.sampleNumber,
    required this.sampleCode,
    required this.farmName,
    this.depthCm,
    this.solicitante,
    this.interessado,
    this.dataEntrada,
    this.material,
    this.organicMatter,
    this.phCacl2,
    this.al3Plus,
    this.ca2Plus,
    this.mg2Plus,
    this.kPlus,
    this.ctcEfetiva,
    this.ctcPh7,
    this.vPercent,
    this.pst,
    this.mPercent,
    required this.createdAt,
  });

  factory SoilAnalysis.fromFirestore(String id, Map<String, dynamic> data) {
    return SoilAnalysis(
      id: id,
      userId: data['userId'] as String? ?? '',
      documentId: data['documentId'] as String?,
      dmlabNumber: data['dmlabNumber'] as String? ?? '',
      analysisDate:
          (data['analysisDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sampleNumber: data['sampleNumber'] as String? ?? '',
      sampleCode: data['sampleCode'] as String? ?? '',
      farmName: data['farmName'] as String? ?? '',
      depthCm: (data['depthCm'] as num?)?.toDouble(),
      solicitante: data['solicitante'] as String?,
      interessado: data['interessado'] as String?,
      dataEntrada: data['dataEntrada'] as String?,
      material: data['material'] as String?,
      organicMatter: (data['organicMatter'] as num?)?.toDouble(),
      phCacl2: (data['phCacl2'] as num?)?.toDouble(),
      al3Plus: (data['al3Plus'] as num?)?.toDouble(),
      ca2Plus: (data['ca2Plus'] as num?)?.toDouble(),
      mg2Plus: (data['mg2Plus'] as num?)?.toDouble(),
      kPlus: (data['kPlus'] as num?)?.toDouble(),
      ctcEfetiva: (data['ctcEfetiva'] as num?)?.toDouble(),
      ctcPh7: (data['ctcPh7'] as num?)?.toDouble(),
      vPercent: (data['vPercent'] as num?)?.toDouble(),
      pst: (data['pst'] as num?)?.toDouble(),
      mPercent: (data['mPercent'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'documentId': documentId,
      'dmlabNumber': dmlabNumber,
      'analysisDate': Timestamp.fromDate(analysisDate),
      'sampleNumber': sampleNumber,
      'sampleCode': sampleCode,
      'farmName': farmName,
      'depthCm': depthCm,
      'solicitante': solicitante,
      'interessado': interessado,
      'dataEntrada': dataEntrada,
      'material': material,
      'organicMatter': organicMatter,
      'phCacl2': phCacl2,
      'al3Plus': al3Plus,
      'ca2Plus': ca2Plus,
      'mg2Plus': mg2Plus,
      'kPlus': kPlus,
      'ctcEfetiva': ctcEfetiva,
      'ctcPh7': ctcPh7,
      'vPercent': vPercent,
      'pst': pst,
      'mPercent': mPercent,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  SoilAnalysis copyWith({
    String? id,
    String? userId,
    String? documentId,
    String? dmlabNumber,
    DateTime? analysisDate,
    String? sampleNumber,
    String? sampleCode,
    String? farmName,
    double? depthCm,
    String? solicitante,
    String? interessado,
    String? dataEntrada,
    String? material,
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
    DateTime? createdAt,
  }) {
    return SoilAnalysis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentId: documentId ?? this.documentId,
      dmlabNumber: dmlabNumber ?? this.dmlabNumber,
      analysisDate: analysisDate ?? this.analysisDate,
      sampleNumber: sampleNumber ?? this.sampleNumber,
      sampleCode: sampleCode ?? this.sampleCode,
      farmName: farmName ?? this.farmName,
      depthCm: depthCm ?? this.depthCm,
      solicitante: solicitante ?? this.solicitante,
      interessado: interessado ?? this.interessado,
      dataEntrada: dataEntrada ?? this.dataEntrada,
      material: material ?? this.material,
      organicMatter: organicMatter ?? this.organicMatter,
      phCacl2: phCacl2 ?? this.phCacl2,
      al3Plus: al3Plus ?? this.al3Plus,
      ca2Plus: ca2Plus ?? this.ca2Plus,
      mg2Plus: mg2Plus ?? this.mg2Plus,
      kPlus: kPlus ?? this.kPlus,
      ctcEfetiva: ctcEfetiva ?? this.ctcEfetiva,
      ctcPh7: ctcPh7 ?? this.ctcPh7,
      vPercent: vPercent ?? this.vPercent,
      pst: pst ?? this.pst,
      mPercent: mPercent ?? this.mPercent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
