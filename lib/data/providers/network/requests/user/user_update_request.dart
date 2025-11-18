import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

// PUT update user
class UpdateUserRequest implements APIRequestRepresentable {
  final int id;
  final String nip;
  final String username;
  final String email;
  final String phone;
  final String fullName;
  final String? profilePhoto;
  final String? role;

  UpdateUserRequest({
    required this.id,
    required this.nip,
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    this.profilePhoto,
    this.role,
  });

  @override
  String get url => "${APIEndpoint.users}/$id";

  @override
  String get endpoint => APIEndpoint.baseUrl;

  @override
  String get path => "/master/user/$id";

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
    'nip': nip,
    'username': username,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    if (profilePhoto != null && profilePhoto!.isNotEmpty)
      'profile_photo': profilePhoto,
    if (role != null) 'role': role,
  };

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
