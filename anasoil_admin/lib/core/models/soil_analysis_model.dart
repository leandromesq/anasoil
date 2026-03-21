import 'package:cloud_firestore/cloud_firestore.dart';

class SoilAnalysisModel {
  final String id;
  final String? documentId;
  final String userId;

  final String dmlabNumber;
  final DateTime analysisDate;
  final String sampleNumber;
  final String sampleCode;
  final String farmName;
  final double? depthCm;

  final String? solicitante;
  final String? interessado;
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

  final DateTime createdAt;

  SoilAnalysisModel({
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SoilAnalysisModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SoilAnalysisModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      documentId: data['documentId'],
      dmlabNumber: data['dmlabNumber'] ?? '',
      analysisDate:
          (data['analysisDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sampleNumber: data['sampleNumber'] ?? '',
      sampleCode: data['sampleCode'] ?? '',
      farmName: data['farmName'] ?? '',
      depthCm: (data['depthCm'] as num?)?.toDouble(),
      solicitante: data['solicitante'],
      interessado: data['interessado'],
      dataEntrada: data['dataEntrada'],
      material: data['material'],
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
