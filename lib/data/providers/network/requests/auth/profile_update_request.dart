import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class ProfileUpdateRequest extends APIRequestRepresentable {
  // final String nip;
  // final String username;
  final String fullName;
  // final String email;
  final String phone;
  final int divisionId;

  ProfileUpdateRequest({
    // required this.nip,
    // required this.username,
    required this.fullName,
    // required this.email,
    required this.phone,
    required this.divisionId,
  });

  @override
  String get url => APIEndpoint.updateProfile;

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/profile/update";

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
  Map<String, dynamic> get body => {
    // "nip": nip,
    // "username": username,
    "full_name": fullName,
    // "email": email,
    "phone": phone,
    "division_id": divisionId,
  };

  @override
  Map<String, dynamic>? get query => null;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
