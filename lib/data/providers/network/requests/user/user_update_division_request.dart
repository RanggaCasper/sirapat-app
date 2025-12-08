import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class UpdateUserDivisonRequest implements APIRequestRepresentable {
  final int id;
  final int divisionId;

  UpdateUserDivisonRequest({required this.id, required this.divisionId});

  @override
  String get url => "${APIEndpoint.updateDivision}/";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "auth/update-divison";

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
  Map<String, dynamic>? get body => {'user_id': id, 'division_id': divisionId};
  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
