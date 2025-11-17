import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class DivisionCreateRequest extends APIRequestRepresentable {
  final String name;
  final String? description;

  DivisionCreateRequest({required this.name, this.description});

  @override
  String get url => APIEndpoint.divisions;

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/divisions";

  @override
  HTTPMethod get method => HTTPMethod.post;

  @override
  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  @override
  Map<String, dynamic> get body => {
        "name": name,
        "description": description,
      };

  @override
  Map<String, dynamic>? get query => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
