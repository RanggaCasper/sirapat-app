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
  };
}
