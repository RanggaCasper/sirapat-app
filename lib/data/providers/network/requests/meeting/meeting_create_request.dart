import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class CreateMeetingRequest implements APIRequestRepresentable {
  final String title;
  final String? description;
  final String? location;
  final String? agenda;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final bool? hasPasscode;

  CreateMeetingRequest({
    required this.title,
    this.description,
    this.location,
    this.agenda,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'scheduled',
    this.hasPasscode,
  });

  @override
  String get url => "${APIEndpoint.meetings}/";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/meeting/";

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
    'title': title,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (location != null && location!.isNotEmpty) 'location': location,
    if (agenda != null && agenda!.isNotEmpty) 'agenda': agenda,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'status': status,
    if (hasPasscode != null) 'has_passcode': hasPasscode,
  };

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
