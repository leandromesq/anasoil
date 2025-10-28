import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool active;
  final DateTime createdAt;
  final List<String> consultorIds; // Para agricultores
  final List<String> agricultorIds; // Para consultores

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    DateTime? createdAt,
    this.consultorIds = const [],
    this.agricultorIds = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      active: data['active'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'createdAt': Timestamp.fromDate(createdAt),
      'consultorIds': consultorIds,
      'agricultorIds': agricultorIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? active,
    DateTime? createdAt,
    List<String>? consultorIds,
    List<String>? agricultorIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      consultorIds: consultorIds ?? this.consultorIds,
      agricultorIds: agricultorIds ?? this.agricultorIds,
    );
  }
}
