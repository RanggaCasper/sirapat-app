import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class UpdateMeetingRequest implements APIRequestRepresentable {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final String? agenda;
  final String date;
  final String startTime;
  final String endTime;
  final String? status;

  UpdateMeetingRequest({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.agenda,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status,
  });

  @override
  String get url => "${APIEndpoint.meetings}/$id";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/meeting/$id";

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
  Map<String, dynamic>? get body => {
    'title': title,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (location != null && location!.isNotEmpty) 'location': location,
    if (agenda != null && agenda!.isNotEmpty) 'agenda': agenda,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    if (status != null) 'status': status,
  };

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
