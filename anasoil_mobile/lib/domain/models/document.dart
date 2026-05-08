import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de documento importado para análise de solo
class SoilDocument {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final bool active;
  final DateTime createdAt;

  const SoilDocument({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    this.active = true,
    required this.createdAt,
  });

  factory SoilDocument.fromFirestore(String id, Map<String, dynamic> data) {
    return SoilDocument(
      id: id,
      userId: data[DocumentFields.userId] as String? ?? '',
      fileName: data[DocumentFields.fileName] as String? ?? '',
      fileUrl: data[DocumentFields.fileUrl] as String? ?? '',
      fileSize: data[DocumentFields.fileSize] as int? ?? 0,
      mimeType: data[DocumentFields.mimeType] as String? ?? 'application/pdf',
      active: data[DocumentFields.active] as bool? ?? true,
      createdAt:
          (data[DocumentFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      DocumentFields.userId: userId,
      DocumentFields.fileName: fileName,
      DocumentFields.fileUrl: fileUrl,
      DocumentFields.fileSize: fileSize,
      DocumentFields.mimeType: mimeType,
      DocumentFields.active: active,
      DocumentFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  SoilDocument copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    bool? active,
    DateTime? createdAt,
  }) {
    return SoilDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
