import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';

class ResetPasswordRequest extends APIRequestRepresentable {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  String get url => '${APIEndpoint.baseUrl}/auth/reset-password';

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => '/auth/reset-password';

  @override
  HTTPMethod get method => HTTPMethod.post;

  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Map<String, dynamic> get body => {
    'email': email,
    'otp': otp,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };

  @override
  Map<String, dynamic>? get query => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
