import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.mimeType = 'application/pdf',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DocumentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DocumentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      mimeType: data['mimeType'] ?? 'application/pdf',
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
