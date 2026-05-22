/// Classifies measured Analysis parameters using the current agronomic
/// threshold table.
enum ClassificationLevel { low, medium, high }

class ParameterClassification {
  final String label;
  final String unit;
  final double value;
  final ClassificationLevel level;
  final double lowThreshold;
  final double highThreshold;

  const ParameterClassification({
    required this.label,
    required this.unit,
    required this.value,
    required this.level,
    required this.lowThreshold,
    required this.highThreshold,
  });

  String get levelText {
    switch (level) {
      case ClassificationLevel.low:
        return 'Baixo';
      case ClassificationLevel.medium:
        return 'Médio';
      case ClassificationLevel.high:
        return 'Alto';
    }
  }
}

class AnalysisParameterValues {
  final double? organicMatter;
  final double? phCacl2;
  final double? al3Plus;
  final double? ca2Plus;
  final double? mg2Plus;
  final double? kPlus;
  final double? ctcEfetiva;
  final double? ctcPh7;
  final double? vPercent;
  final double? pst;
  final double? mPercent;

  const AnalysisParameterValues({
    this.organicMatter,
    this.phCacl2,
    this.al3Plus,
    this.ca2Plus,
    this.mg2Plus,
    this.kPlus,
    this.ctcEfetiva,
    this.ctcPh7,
    this.vPercent,
    this.pst,
    this.mPercent,
  });
}

class ParameterClassifier {
  const ParameterClassifier._();

  static ClassificationLevel _classify(double value, double low, double high) {
    if (value < low) return ClassificationLevel.low;
    if (value > high) return ClassificationLevel.high;
    return ClassificationLevel.medium;
  }

  static List<ParameterClassification> classifyAll(
    AnalysisParameterValues values,
  ) {
    final results = <ParameterClassification>[];

    void add(
      String label,
      String unit,
      double? value,
      double low,
      double high,
    ) {
      if (value == null) return;
      results.add(
        ParameterClassification(
          label: label,
          unit: unit,
          value: value,
          level: _classify(value, low, high),
          lowThreshold: low,
          highThreshold: high,
        ),
      );
    }

    add('M.O.', 'dag/kg', values.organicMatter, 1.5, 3.0);
    add('pH', '', values.phCacl2, 5.0, 6.0);
    add('Al³⁺', 'cmolc/dm³', values.al3Plus, 0.5, 1.0);
    add('Ca²⁺', 'cmolc/dm³', values.ca2Plus, 1.6, 3.0);
    add('Mg²⁺', 'cmolc/dm³', values.mg2Plus, 0.4, 1.0);
    add('K⁺', 'mg/dm³', values.kPlus, 30, 60);
    add('CTC efetiva', 'cmolc/dm³', values.ctcEfetiva, 2.0, 4.0);
    add('CTC pH 7,0', 'cmolc/dm³', values.ctcPh7, 5.0, 15.0);
    add('V%', '%', values.vPercent, 50, 70);
    add('PST', '%', values.pst, 6, 15);
    add('Sat. Al', '%', values.mPercent, 30, 50);

    return results;
  }
}
