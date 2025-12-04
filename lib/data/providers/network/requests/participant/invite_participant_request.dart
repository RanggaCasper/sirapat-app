import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class InviteParticipantRequest implements APIRequestRepresentable {
  final int meetingId;
  final String identifier;

  InviteParticipantRequest({required this.meetingId, required this.identifier});

  @override
  String get url => "${APIEndpoint.participants}/invite-participant";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/meeting-participant/invite-participant";

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
  Map<String, dynamic>? get body => {
    'meeting_id': meetingId,
    'identifier': identifier,
  };

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
