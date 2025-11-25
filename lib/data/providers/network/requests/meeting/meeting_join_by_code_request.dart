import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class JoinMeetingByCodeRequest implements APIRequestRepresentable {
  final String meetingCode;

  JoinMeetingByCodeRequest({required this.meetingCode});

  @override
  String get url => "${APIEndpoint.meetings}/join";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/meeting/join";

  @override
  HTTPMethod get method => HTTPMethod.post;

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
  Map<String, dynamic>? get body => {'meeting_code': meetingCode};

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
