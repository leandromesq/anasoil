import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final bool active;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.mimeType = 'application/pdf',
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DocumentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DocumentModel(
      id: doc.id,
      userId: data[DocumentFields.userId] ?? '',
      fileName: data[DocumentFields.fileName] ?? '',
      fileUrl: data[DocumentFields.fileUrl] ?? '',
      fileSize: data[DocumentFields.fileSize] ?? 0,
      mimeType: data[DocumentFields.mimeType] ?? 'application/pdf',
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
      DocumentFields.createdAt: Timestamp.fromDate(createdAt),
    };
  }
}
