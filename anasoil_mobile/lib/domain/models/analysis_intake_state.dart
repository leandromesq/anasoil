enum AnalysisIntakeStep {
  idle,
  fileSelected,
  uploadingDocument,
  documentUploaded,
  extracting,
  extracted,
  saving,
  complete,
  failed,
}

class AnalysisIntakeState {
  final AnalysisIntakeStep step;
  final String? fileName;
  final String? documentId;
  final String? errorMessage;
  final int extractedCount;

  const AnalysisIntakeState({
    this.step = AnalysisIntakeStep.idle,
    this.fileName,
    this.documentId,
    this.errorMessage,
    this.extractedCount = 0,
  });

  bool get canExtract =>
      step == AnalysisIntakeStep.documentUploaded && documentId != null;
  bool get canSave =>
      step == AnalysisIntakeStep.extracted &&
      documentId != null &&
      extractedCount > 0;

  AnalysisIntakeState copyWith({
    AnalysisIntakeStep? step,
    String? fileName,
    String? documentId,
    String? errorMessage,
    int? extractedCount,
    bool clearError = false,
    bool clearDocumentId = false,
  }) {
    return AnalysisIntakeState(
      step: step ?? this.step,
      fileName: fileName ?? this.fileName,
      documentId: clearDocumentId ? null : documentId ?? this.documentId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      extractedCount: extractedCount ?? this.extractedCount,
    );
  }
}
