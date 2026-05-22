import 'package:anasoil_admin/core/models/document_model.dart';
import 'package:anasoil_admin/core/models/soil_analysis_model.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<DocumentModel> _documentsRef;
  late final CollectionReference<SoilAnalysisModel> _analysesRef;

  FirestoreService() {
    _documentsRef = _db
        .collection(AnaSoilCollections.documents)
        .withConverter<DocumentModel>(
          fromFirestore: (snapshots, _) =>
              DocumentModel.fromFirestore(snapshots),
          toFirestore: (doc, _) => doc.toFirestore(),
        );

    _analysesRef = _db
        .collection(AnaSoilCollections.analyses)
        .withConverter<SoilAnalysisModel>(
          fromFirestore: (snapshots, _) =>
              SoilAnalysisModel.fromFirestore(snapshots),
          toFirestore: (analysis, _) => analysis.toFirestore(),
        );
  }

  Stream<List<DocumentModel>> getDocuments() {
    return _documentsRef.snapshots().map((snapshot) {
      final documents = snapshot.docs
          .map((doc) => doc.data())
          .where((doc) => doc.active)
          .toList();

      documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return documents;
    });
  }

  Future<void> deleteDocument(String documentId) async {
    await _documentsRef.doc(documentId).update({'active': false});
  }

  Stream<List<SoilAnalysisModel>> getAnalyses() {
    return _analysesRef.snapshots().map((snapshot) {
      final analyses = snapshot.docs
          .map((doc) => doc.data())
          .where((analysis) => analysis.active)
          .toList();

      analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return analyses;
    });
  }

  Future<void> deleteAnalysis(String analysisId) async {
    await _analysesRef.doc(analysisId).update({'active': false});
  }
}
