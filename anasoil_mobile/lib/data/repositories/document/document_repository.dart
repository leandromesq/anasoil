import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../domain/models/document.dart';
import '../../../utils/result.dart';

/// Interface do repositório de documentos
abstract class DocumentRepository extends ChangeNotifier {
  /// Lista de documentos do usuário
  List<SoilDocument> get documents;

  /// Faz upload de um documento
  Future<Result<SoilDocument>> uploadDocument(File file, String fileName);

  /// Carrega documentos do usuário
  Future<Result<List<SoilDocument>>> getDocuments();

  /// Deleta um documento
  Future<Result<void>> deleteDocument(String docId);
}
