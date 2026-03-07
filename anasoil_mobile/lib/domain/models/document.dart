import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de documento importado para análise de solo
class SoilDocument {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;

  const SoilDocument({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    required this.createdAt,
  });

  factory SoilDocument.fromFirestore(String id, Map<String, dynamic> data) {
    return SoilDocument(
      id: id,
      userId: data['userId'] as String? ?? '',
      fileName: data['fileName'] as String? ?? '',
      fileUrl: data['fileUrl'] as String? ?? '',
      fileSize: data['fileSize'] as int? ?? 0,
      mimeType: data['mimeType'] as String? ?? 'application/pdf',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  SoilDocument copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    DateTime? createdAt,
  }) {
    return SoilDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
