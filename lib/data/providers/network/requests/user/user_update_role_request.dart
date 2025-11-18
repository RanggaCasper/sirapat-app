import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class UpdateUserRoleRequest implements APIRequestRepresentable {
  final int id;
  final String role;

  UpdateUserRoleRequest({required this.id, required this.role});

  @override
  String get url => "${APIEndpoint.users}/update-role/$id";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/master/user/$id/role";

  @override
  HTTPMethod get method => HTTPMethod.put;

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
  Map<String, dynamic>? get body => {'role': role};

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
