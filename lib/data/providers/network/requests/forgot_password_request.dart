import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';

class ForgotPasswordRequest extends APIRequestRepresentable {
  final String email;

  ForgotPasswordRequest({required this.email});

  @override
  String get url => '${APIEndpoint.baseUrl}/auth/forgot-password';

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => '/auth/forgot-password';

  @override
  HTTPMethod get method => HTTPMethod.post;

  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Map<String, dynamic> get body => {'email': email};

  @override
  Map<String, dynamic>? get query => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
