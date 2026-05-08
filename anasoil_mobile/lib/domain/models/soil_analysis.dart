import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de análise de solo extraída do certificado de laboratório.
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

  // Identificação do laboratório
  final String labNumber;
  final DateTime analysisDate;

  // Contexto da propriedade
  final String propertyName;
  final double? depthCm;

  // Metadados do laudo
  final String? requester;
  final String? stakeholder;
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

  final bool active;
  final DateTime createdAt;

  const SoilAnalysis({
    required this.id,
    required this.userId,
    this.documentId,
    required this.labNumber,
    required this.analysisDate,
    required this.propertyName,
    this.depthCm,
    this.requester,
    this.stakeholder,
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
    this.active = true,
    required this.createdAt,
  });

  factory SoilAnalysis.fromFirestore(String id, Map<String, dynamic> data) {
    return SoilAnalysis(
      id: id,
      userId: data[AnalysisFields.userId] as String? ?? '',
      documentId: data[AnalysisFields.documentId] as String?,
      labNumber: data[AnalysisFields.labNumber] as String? ?? '',
      analysisDate:
          (data[AnalysisFields.analysisDate] as Timestamp?)?.toDate() ??
          DateTime.now(),
      propertyName: data[AnalysisFields.propertyName] as String? ?? '',
      depthCm: (data[AnalysisFields.depthCm] as num?)?.toDouble(),
      requester: data[AnalysisFields.requester] as String?,
      stakeholder: data[AnalysisFields.stakeholder] as String?,
      dataEntrada: data[AnalysisFields.dataEntrada] as String?,
      material: data[AnalysisFields.material] as String?,
      organicMatter: (data[AnalysisFields.organicMatter] as num?)?.toDouble(),
      phCacl2: (data[AnalysisFields.phCacl2] as num?)?.toDouble(),
      al3Plus: (data[AnalysisFields.al3Plus] as num?)?.toDouble(),
      ca2Plus: (data[AnalysisFields.ca2Plus] as num?)?.toDouble(),
      mg2Plus: (data[AnalysisFields.mg2Plus] as num?)?.toDouble(),
      kPlus: (data[AnalysisFields.kPlus] as num?)?.toDouble(),
      ctcEfetiva: (data[AnalysisFields.ctcEfetiva] as num?)?.toDouble(),
      ctcPh7: (data[AnalysisFields.ctcPh7] as num?)?.toDouble(),
      vPercent: (data[AnalysisFields.vPercent] as num?)?.toDouble(),
      pst: (data[AnalysisFields.pst] as num?)?.toDouble(),
      mPercent: (data[AnalysisFields.mPercent] as num?)?.toDouble(),
      active: data[AnalysisFields.active] as bool? ?? true,
      createdAt:
          (data[AnalysisFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      AnalysisFields.userId: userId,
      AnalysisFields.documentId: documentId,
      AnalysisFields.labNumber: labNumber,
      AnalysisFields.analysisDate: Timestamp.fromDate(analysisDate),
      AnalysisFields.propertyName: propertyName,
      AnalysisFields.depthCm: depthCm,
      AnalysisFields.requester: requester,
      AnalysisFields.stakeholder: stakeholder,
      AnalysisFields.dataEntrada: dataEntrada,
      AnalysisFields.material: material,
      AnalysisFields.organicMatter: organicMatter,
      AnalysisFields.phCacl2: phCacl2,
      AnalysisFields.al3Plus: al3Plus,
      AnalysisFields.ca2Plus: ca2Plus,
      AnalysisFields.mg2Plus: mg2Plus,
      AnalysisFields.kPlus: kPlus,
      AnalysisFields.ctcEfetiva: ctcEfetiva,
      AnalysisFields.ctcPh7: ctcPh7,
      AnalysisFields.vPercent: vPercent,
      AnalysisFields.pst: pst,
      AnalysisFields.mPercent: mPercent,
      AnalysisFields.active: active,
      AnalysisFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  SoilAnalysis copyWith({
    String? id,
    String? userId,
    String? documentId,
    String? labNumber,
    DateTime? analysisDate,
    String? propertyName,
    double? depthCm,
    String? requester,
    String? stakeholder,
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
    bool? active,
    DateTime? createdAt,
  }) {
    return SoilAnalysis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentId: documentId ?? this.documentId,
      labNumber: labNumber ?? this.labNumber,
      analysisDate: analysisDate ?? this.analysisDate,
      propertyName: propertyName ?? this.propertyName,
      depthCm: depthCm ?? this.depthCm,
      requester: requester ?? this.requester,
      stakeholder: stakeholder ?? this.stakeholder,
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
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
