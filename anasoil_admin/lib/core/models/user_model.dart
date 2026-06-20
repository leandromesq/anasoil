import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool active;
  final String? phone;
  final String? avatarUrl;
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
    this.phone,
    this.avatarUrl,
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
      phone: data[UserFields.phone] as String?,
      avatarUrl: data[UserFields.avatarUrl] as String?,
      createdAt:
          (data[UserFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      consultorIds: List<String>.from(data[UserFields.consultorIds] ?? []),
      agricultorIds: List<String>.from(data[UserFields.agricultorIds] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      UserFields.name: name,
      UserFields.email: email.trim().toLowerCase(),
      UserFields.role: userRole.firestoreValue,
      UserFields.active: active,
      UserFields.createdAt: Timestamp.fromDate(createdAt),
      UserFields.consultorIds: consultorIds,
      UserFields.agricultorIds: agricultorIds,
    };

    if (phone != null) data[UserFields.phone] = phone;
    if (avatarUrl != null) data[UserFields.avatarUrl] = avatarUrl;

    return data;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? active,
    String? phone,
    String? avatarUrl,
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
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      consultorIds: consultorIds ?? this.consultorIds,
      agricultorIds: agricultorIds ?? this.agricultorIds,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, active: $active, phone: $phone, avatarUrl: $avatarUrl, createdAt: $createdAt, consultorIds: $consultorIds, agricultorIds: $agricultorIds)';
  }
}
