import 'package:anasoil_mobile/domain/models/analysis_intake_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analysis intake state exposes save guards', () {
    const initial = AnalysisIntakeState();
    expect(initial.canSave, isFalse);

    const extracted = AnalysisIntakeState(
      step: AnalysisIntakeStep.extracted,
      documentId: 'doc-1',
      extractedCount: 2,
    );

    expect(extracted.canSave, isTrue);
  });
}
