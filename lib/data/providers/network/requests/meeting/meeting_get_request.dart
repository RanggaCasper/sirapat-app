import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class GetMeetingsRequest implements APIRequestRepresentable {
  @override
  String get url {
    final meetingsUrl = "${APIEndpoint.meetings}/";
    debugPrint('[GetMeetingsRequest] Full URL: $meetingsUrl');
    return meetingsUrl;
  }

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path {
    final meetingsPath =
        '${APIEndpoint.meetings.replaceFirst(APIEndpoint.baseUrl, '')}/';
    debugPrint('[GetMeetingsRequest] Path: $meetingsPath');
    return meetingsPath;
  }

  @override
  HTTPMethod get method => HTTPMethod.get;

  @override
  Map<String, String> get headers {
    final storage = Get.find<LocalStorageService>();
    final token = storage.getData<String>(StorageKey.token);

    debugPrint('[GetMeetingsRequest] Token exists: ${token != null}');
    if (token != null) {
      debugPrint(
        '[GetMeetingsRequest] Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
    } else {
      debugPrint('[GetMeetingsRequest] WARNING: No token found in storage!');
    }

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
