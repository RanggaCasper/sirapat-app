import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';

class MeetGetRequest extends APIRequestRepresentable {
  @override
  String get url => APIEndpoint.divisions;

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/admin/meeting";

  @override
  HTTPMethod get method => HTTPMethod.get;

  @override
  Map<String, String> get headers {
    final storage = Get.find<LocalStorageService>();
    final token = storage.getData<String>(StorageKey.token);

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  @override
  Map<String, dynamic>? get query => null;

  @override
  Map<String, dynamic>? get body => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
