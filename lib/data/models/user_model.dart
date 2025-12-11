import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/data/models/division_model.dart';

class UserModel extends User {
  UserModel({
    super.id,
    super.nip,
    super.username,
    super.email,
    super.phone,
    super.fullName,
    super.profilePhoto,
    super.role,
    super.createdAt,
    super.updatedAt,
    super.divisionId,
    super.division,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
          ? DivisionModel.fromJson(json['division'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
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

  // From Entity to Model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      nip: user.nip,
      username: user.username,
      email: user.email,
      phone: user.phone,
      fullName: user.fullName,
      profilePhoto: user.profilePhoto,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      divisionId: user.divisionId,
      division: user.division,
    );
  }

  // To Entity
  User toEntity() {
    return User(
      id: id,
      nip: nip,
      username: username,
      email: email,
      phone: phone,
      fullName: fullName,
      profilePhoto: profilePhoto,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      divisionId: divisionId,
      division: division,
    );
  }

  // CopyWith
  @override
  UserModel copyWith({
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
    return UserModel(
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
}
