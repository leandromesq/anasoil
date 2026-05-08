import 'package:anasoil_shared/anasoil_shared.dart';
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

  UserRole get userRole => UserRole.parse(role);

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
      name: data[UserFields.name] ?? '',
      email: data[UserFields.email] ?? '',
      role: UserRole.parse(data[UserFields.role] as String?).firestoreValue,
      active: data[UserFields.active] ?? false,
      createdAt:
          (data[UserFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      consultorIds: List<String>.from(data[UserFields.consultorIds] ?? []),
      agricultorIds: List<String>.from(data[UserFields.agricultorIds] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      UserFields.name: name,
      UserFields.email: email.trim().toLowerCase(),
      UserFields.role: userRole.firestoreValue,
      UserFields.active: active,
      UserFields.createdAt: Timestamp.fromDate(createdAt),
      UserFields.consultorIds: consultorIds,
      UserFields.agricultorIds: agricultorIds,
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

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, active: $active, createdAt: $createdAt, consultorIds: $consultorIds, agricultorIds: $agricultorIds)';
  }
}
