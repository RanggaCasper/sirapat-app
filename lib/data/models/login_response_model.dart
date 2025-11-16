import 'package:sirapat_app/data/models/user_model.dart';

class LoginResponseData {
  final UserModel user;
  final String token;
  final String tokenType;

  LoginResponseData({
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
    'token_type': tokenType,
  };
}
