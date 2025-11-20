import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class UpdateMeetingStatusRequest implements APIRequestRepresentable {
  final int id;
  final String status;

  UpdateMeetingStatusRequest({required this.id, required this.status});

  @override
  String get url => "${APIEndpoint.meetings}/$id/status";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/meeting/$id/status";

  @override
  HTTPMethod get method => HTTPMethod.patch;

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
  Map<String, dynamic>? get body => {'status': status};

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
