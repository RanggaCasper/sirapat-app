import 'package:sirapat_app/domain/entities/user.dart';

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
  };
}
