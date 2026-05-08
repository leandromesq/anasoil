/// Shared Firestore collection and field names for AnaSoil.
abstract final class AnaSoilCollections {
  static const users = 'users';
  static const documents = 'documents';
  static const analyses = 'soilAnalyses';
}

abstract final class UserFields {
  static const name = 'name';
  static const email = 'email';
  static const role = 'role';
  static const active = 'active';
  static const phone = 'phone';
  static const avatarUrl = 'avatarUrl';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const consultorIds = 'consultorIds';
  static const agricultorIds = 'agricultorIds';
}

abstract final class DocumentFields {
  static const userId = 'userId';
  static const fileName = 'fileName';
  static const fileUrl = 'fileUrl';
  static const fileSize = 'fileSize';
  static const mimeType = 'mimeType';
  static const active = 'active';
  static const createdAt = 'createdAt';
}

abstract final class AnalysisFields {
  static const userId = 'userId';
  static const documentId = 'documentId';

  // Lab identification
  static const labNumber = 'dmlabNumber'; // Firestore compat: was 'dmlabNumber'
  static const analysisDate = 'analysisDate';

  // Property context
  static const propertyName = 'farmName'; // Firestore compat: was 'farmName'
  static const depthCm = 'depthCm';

  // Lab report metadata
  static const requester = 'solicitante'; // Firestore compat: was 'solicitante'
  static const stakeholder =
      'interessado'; // Firestore compat: was 'interessado'
  static const dataEntrada = 'dataEntrada';
  static const material = 'material';

  // Measured parameters
  static const organicMatter = 'organicMatter';
  static const phCacl2 = 'phCacl2';
  static const al3Plus = 'al3Plus';
  static const ca2Plus = 'ca2Plus';
  static const mg2Plus = 'mg2Plus';
  static const kPlus = 'kPlus';
  static const ctcEfetiva = 'ctcEfetiva';
  static const ctcPh7 = 'ctcPh7';
  static const vPercent = 'vPercent';
  static const pst = 'pst';
  static const mPercent = 'mPercent';

  static const active = 'active';
  static const createdAt = 'createdAt';
}
