import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';

class RegisterRequest extends APIRequestRepresentable {
  final String nip;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.nip,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  String get url => APIEndpoint.register;

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => '/auth/register';

  @override
  HTTPMethod get method => HTTPMethod.post;

  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Map<String, dynamic> get body => {
    'nip': nip,
    'username': username,
    'full_name': fullName,
    'email': email,
    'phone': phone,
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
