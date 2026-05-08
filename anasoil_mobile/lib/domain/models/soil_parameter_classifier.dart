import 'package:anasoil_shared/anasoil_shared.dart';

import 'soil_analysis.dart';

/// Backwards-compatible names for the shared Parameter Classifier module.
typedef SoilLevel = ClassificationLevel;
typedef SoilClassification = ParameterClassification;

class SoilParameterClassifier {
  const SoilParameterClassifier._();

  static List<SoilClassification> classifyAll(SoilAnalysis analysis) {
    return ParameterClassifier.classifyAll(
      AnalysisParameterValues(
        organicMatter: analysis.organicMatter,
        phCacl2: analysis.phCacl2,
        al3Plus: analysis.al3Plus,
        ca2Plus: analysis.ca2Plus,
        mg2Plus: analysis.mg2Plus,
        kPlus: analysis.kPlus,
        ctcEfetiva: analysis.ctcEfetiva,
        ctcPh7: analysis.ctcPh7,
        vPercent: analysis.vPercent,
        pst: analysis.pst,
        mPercent: analysis.mPercent,
      ),
    );
  }
}
