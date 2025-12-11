import 'package:sirapat_app/domain/entities/division.dart';

class User {
  final int? id;
  final String? nip;
  final String? username;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? profilePhoto;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final int? divisionId;
  final Division? division;

  User({
    this.id,
    this.nip,
    this.username,
    this.email,
    this.phone,
    this.fullName,
    this.profilePhoto,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.divisionId,
    this.division,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return User();

    return User(
      id: json['id'] as int?,
      nip: json['nip'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      divisionId: json['division_id'] as int?,
      division: json['division'] != null
          ? Division.fromJson(json['division'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nip': nip,
    'username': username,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    'profile_photo': profilePhoto,
    'role': role,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'division_id': divisionId,
    if (division != null) 'division': division!.toJson(),
  };

  User copyWith({
    int? id,
    String? nip,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? profilePhoto,
    String? role,
    String? createdAt,
    String? updatedAt,
    int? divisionId,
    Division? division,
  }) {
    return User(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      divisionId: divisionId ?? this.divisionId,
      division: division ?? this.division,
    );
  }

  // Helper getters
  bool get isMaster => role == 'master';
  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
  bool get canManageUsers => isMaster || isAdmin;

  String? get roleDisplay {
    switch (role) {
      case 'master':
        return 'Master';
      case 'admin':
        return 'Admin';
      case 'employee':
        return 'Karyawan';
      default:
        return role;
    }
  }

  @override
  String toString() {
    return 'User(id: $id, nip: $nip, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.nip == nip &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nip.hashCode ^ email.hashCode;
  }
}
