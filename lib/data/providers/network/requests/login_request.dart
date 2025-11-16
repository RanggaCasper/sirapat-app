import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class LoginRequest extends APIRequestRepresentable {
  final String nip;
  final String password;

  LoginRequest({required this.nip, required this.password});

  @override
  String get url => APIEndpoint.login;

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => '/auth/login';

  @override
  HTTPMethod get method => HTTPMethod.post;

  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Map<String, dynamic> get body => {'nip': nip, 'password': password};

  @override
  Map<String, dynamic>? get query => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
