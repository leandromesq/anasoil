/// Tipo de perfil do usuário no sistema AnaSoil
enum ProfileType {
  /// Agricultor - Responsável pelas atividades diárias de plantio
  farmer,

  /// Consultor Agrícola - Auxilia nas decisões estratégicas
  consultant;

  String get displayName {
    switch (this) {
      case ProfileType.farmer:
        return 'Agricultor';
      case ProfileType.consultant:
        return 'Consultor';
    }
  }
}
