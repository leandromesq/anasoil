import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../utils/result.dart';

/// Serviço de acesso ao Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Faz upload de um arquivo e retorna a URL de download
  Future<Result<String>> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return Result.ok(downloadUrl);
    } catch (e) {
      return Result.error(Exception('Erro ao fazer upload do arquivo: $e'));
    }
  }

  /// Deleta um arquivo do Storage
  Future<Result<void>> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar arquivo: $e'));
    }
  }

  /// Deleta um arquivo do Storage pela URL de download
  Future<Result<void>> deleteFileByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar arquivo: $e'));
    }
  }
}
