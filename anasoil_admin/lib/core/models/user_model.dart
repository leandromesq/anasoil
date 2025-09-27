import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool active;
  final List<String> consultorIds; // Para agricultores
  final List<String> agricultorIds; // Para consultores

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    this.consultorIds = const [],
    this.agricultorIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      active: data['active'] ?? false,
      // Converte os dados da lista do Firestore para List<String>
      consultorIds: List<String>.from(data['consultorIds'] ?? []),
      agricultorIds: List<String>.from(data['agricultorIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'active': active,
      'consultorIds': consultorIds,
      'agricultorIds': agricultorIds,
    };
  }
}
