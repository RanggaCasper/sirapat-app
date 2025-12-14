import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class UpdateMeetingMinuteRequest implements APIRequestRepresentable {
  final int meetingMinuteId;
  final String? originalText;
  final String? summary;
  final String? pembahasan;
  final List<String>? keputusan;
  final List<String>? tindakan;
  final List<Map<String, dynamic>>? anggaran;
  final String? totalAnggaran;
  final String? catatanAnggaran;

  UpdateMeetingMinuteRequest({
    required this.meetingMinuteId,
    this.originalText,
    this.summary,
    this.pembahasan,
    this.keputusan,
    this.tindakan,
    this.anggaran,
    this.totalAnggaran,
    this.catatanAnggaran,
  });

  @override
  String get url => "${APIEndpoint.meetingMinutes}/$meetingMinuteId";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/admin/meeting-minute/$meetingMinuteId";

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
  Map<String, dynamic>? get body {
    final Map<String, dynamic> data = {};

    // Only add fields that are not null
    if (originalText != null) data['original_text'] = originalText;
    if (summary != null) data['summary'] = summary;
    if (pembahasan != null) data['pembahasan'] = pembahasan;
    if (keputusan != null) data['keputusan'] = keputusan;
    if (tindakan != null) data['tindakan'] = tindakan;
    if (anggaran != null) data['anggaran'] = anggaran;
    if (totalAnggaran != null) data['total_anggaran'] = totalAnggaran;
    if (catatanAnggaran != null) data['catatan_anggaran'] = catatanAnggaran;

    return data;
  }

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
