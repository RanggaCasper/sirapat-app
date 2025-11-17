import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';

class DivisionGetRequest extends APIRequestRepresentable {
  @override
  String get url => APIEndpoint.divisions;

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/divisions";

  @override
  HTTPMethod get method => HTTPMethod.get;

  @override
  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  @override
  Map<String, dynamic>? get query => null;

  @override
  Map<String, dynamic>? get body => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
