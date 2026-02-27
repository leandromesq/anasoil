import 'profile_type.dart';

/// Modelo de usuário do sistema AnaSoil
class User {
  final String id;
  final String name;
  final String email;
  final ProfileType profileType;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileType,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileType: ProfileType.values.firstWhere(
        (e) => e.name == json['profileType'],
        orElse: () => ProfileType.farmer,
      ),
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileType': profileType.name,
      'phone': phone,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    ProfileType? profileType,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileType: profileType ?? this.profileType,
      phone: phone ?? this.phone,
    );
  }
}
