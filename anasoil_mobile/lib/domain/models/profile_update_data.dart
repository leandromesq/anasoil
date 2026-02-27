/// Dados para atualização do perfil do usuário
class ProfileUpdateData {
  final String? name;
  final String? phone;

  const ProfileUpdateData({this.name, this.phone});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;

    return data;
  }

  bool get isEmpty => name == null && phone == null;
}
