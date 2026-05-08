import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoilAnalysisModel {
  final String id;
  final String? documentId;
  final String userId;

  final String labNumber;
  final DateTime analysisDate;
  final String propertyName;
  final double? depthCm;

  final String? requester;
  final String? stakeholder;
  final String? dataEntrada;
  final String? material;

  final double? organicMatter;
  final double? phCacl2;
  final double? al3Plus;
  final double? ca2Plus;
  final double? mg2Plus;
  final double? kPlus;
  final double? ctcEfetiva;
  final double? ctcPh7;
  final double? vPercent;
  final double? pst;
  final double? mPercent;

  final bool active;
  final DateTime createdAt;

  SoilAnalysisModel({
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SoilAnalysisModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SoilAnalysisModel(
      id: doc.id,
      userId: data[AnalysisFields.userId] ?? '',
      documentId: data[AnalysisFields.documentId],
      labNumber: data[AnalysisFields.labNumber] ?? '',
      analysisDate:
          (data[AnalysisFields.analysisDate] as Timestamp?)?.toDate() ??
          DateTime.now(),
      propertyName: data[AnalysisFields.propertyName] ?? '',
      depthCm: (data[AnalysisFields.depthCm] as num?)?.toDouble(),
      requester: data[AnalysisFields.requester],
      stakeholder: data[AnalysisFields.stakeholder],
      dataEntrada: data[AnalysisFields.dataEntrada],
      material: data[AnalysisFields.material],
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
      AnalysisFields.createdAt: Timestamp.fromDate(createdAt),
    };
  }
}
