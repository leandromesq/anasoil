import 'soil_analysis.dart';

/// Classificação do parâmetro de solo
enum SoilLevel { baixo, medio, alto }

/// Resultado da classificação de um parâmetro
class SoilClassification {
  final String label;
  final String unit;
  final double value;
  final SoilLevel level;
  final double lowThreshold;
  final double highThreshold;

  const SoilClassification({
    required this.label,
    required this.unit,
    required this.value,
    required this.level,
    required this.lowThreshold,
    required this.highThreshold,
  });

  String get levelText {
    switch (level) {
      case SoilLevel.baixo:
        return 'Baixo';
      case SoilLevel.medio:
        return 'Médio';
      case SoilLevel.alto:
        return 'Alto';
    }
  }
}

/// Classificador de parâmetros de solo baseado em faixas fixas de referência.
///
/// | Parâmetro                   | Baixo  | Médio     | Alto   |
/// |-----------------------------|--------|-----------|--------|
/// | M.O. (dag/kg)               | <1.5   | 1.5–3.0   | >3.0   |
/// | pH CaCl₂                    | <4.5   | 4.5–5.5   | >5.5   |
/// | Al³⁺ (cmolc/dm³)            | <0.2   | 0.2–0.5   | >0.5   |
/// | Ca²⁺ (cmolc/dm³)            | <2.0   | 2.0–4.0   | >4.0   |
/// | Mg²⁺ (cmolc/dm³)            | <0.5   | 0.5–1.0   | >1.0   |
/// | K⁺ (cmolc/dm³)              | <0.15  | 0.15–0.30 | >0.30  |
/// | CTC efetiva (cmolc/dm³)     | <2.5   | 2.5–5.0   | >5.0   |
/// | CTC pH 7,0 (cmolc/dm³)      | <5.0   | 5.0–10.0  | >10.0  |
/// | V (%)                        | <40    | 40–60     | >60    |
/// | PST (%)                      | <5     | 5–10      | >10    |
/// | m (%)                        | <10    | 10–30     | >30    |
class SoilParameterClassifier {
  const SoilParameterClassifier._();

  static SoilLevel _classify(double value, double low, double high) {
    if (value < low) return SoilLevel.baixo;
    if (value > high) return SoilLevel.alto;
    return SoilLevel.medio;
  }

  /// Classifica todos os parâmetros disponíveis de uma análise de solo.
  static List<SoilClassification> classifyAll(SoilAnalysis analysis) {
    final results = <SoilClassification>[];

    if (analysis.organicMatter != null) {
      results.add(
        SoilClassification(
          label: 'M.O.',
          unit: 'dag/kg',
          value: analysis.organicMatter!,
          level: _classify(analysis.organicMatter!, 1.5, 3.0),
          lowThreshold: 1.5,
          highThreshold: 3.0,
        ),
      );
    }

    if (analysis.phCacl2 != null) {
      results.add(
        SoilClassification(
          label: 'pH',
          unit: '',
          value: analysis.phCacl2!,
          level: _classify(analysis.phCacl2!, 4.5, 5.5),
          lowThreshold: 4.5,
          highThreshold: 5.5,
        ),
      );
    }

    if (analysis.al3Plus != null) {
      results.add(
        SoilClassification(
          label: 'Al³⁺',
          unit: 'cmolc/dm³',
          value: analysis.al3Plus!,
          level: _classify(analysis.al3Plus!, 0.2, 0.5),
          lowThreshold: 0.2,
          highThreshold: 0.5,
        ),
      );
    }

    if (analysis.ca2Plus != null) {
      results.add(
        SoilClassification(
          label: 'Ca²⁺',
          unit: 'cmolc/dm³',
          value: analysis.ca2Plus!,
          level: _classify(analysis.ca2Plus!, 2.0, 4.0),
          lowThreshold: 2.0,
          highThreshold: 4.0,
        ),
      );
    }

    if (analysis.mg2Plus != null) {
      results.add(
        SoilClassification(
          label: 'Mg²⁺',
          unit: 'cmolc/dm³',
          value: analysis.mg2Plus!,
          level: _classify(analysis.mg2Plus!, 0.5, 1.0),
          lowThreshold: 0.5,
          highThreshold: 1.0,
        ),
      );
    }

    if (analysis.kPlus != null) {
      results.add(
        SoilClassification(
          label: 'K⁺',
          unit: 'cmolc/dm³',
          value: analysis.kPlus!,
          level: _classify(analysis.kPlus!, 0.15, 0.30),
          lowThreshold: 0.15,
          highThreshold: 0.30,
        ),
      );
    }

    if (analysis.ctcEfetiva != null) {
      results.add(
        SoilClassification(
          label: 'CTC efetiva',
          unit: 'cmolc/dm³',
          value: analysis.ctcEfetiva!,
          level: _classify(analysis.ctcEfetiva!, 2.5, 5.0),
          lowThreshold: 2.5,
          highThreshold: 5.0,
        ),
      );
    }

    if (analysis.ctcPh7 != null) {
      results.add(
        SoilClassification(
          label: 'CTC pH 7,0',
          unit: 'cmolc/dm³',
          value: analysis.ctcPh7!,
          level: _classify(analysis.ctcPh7!, 5.0, 10.0),
          lowThreshold: 5.0,
          highThreshold: 10.0,
        ),
      );
    }

    if (analysis.vPercent != null) {
      results.add(
        SoilClassification(
          label: 'V%',
          unit: '%',
          value: analysis.vPercent!,
          level: _classify(analysis.vPercent!, 40, 60),
          lowThreshold: 40,
          highThreshold: 60,
        ),
      );
    }

    if (analysis.pst != null) {
      results.add(
        SoilClassification(
          label: 'PST',
          unit: '%',
          value: analysis.pst!,
          level: _classify(analysis.pst!, 5, 10),
          lowThreshold: 5,
          highThreshold: 10,
        ),
      );
    }

    if (analysis.mPercent != null) {
      results.add(
        SoilClassification(
          label: 'Sat. Al',
          unit: '%',
          value: analysis.mPercent!,
          level: _classify(analysis.mPercent!, 10, 30),
          lowThreshold: 10,
          highThreshold: 30,
        ),
      );
    }

    return results;
  }
}
