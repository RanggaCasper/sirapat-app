import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class ChangePasswordRequest implements APIRequestRepresentable {
  final int id;
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordRequest({
    required this.id,
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  String get url => "${APIEndpoint.users}/$id";

  @override
  String get endpoint => '${APIEndpoint.users}/$id/change-password';

  @override
  String get path => "/master/user/$id";

  @override
  HTTPMethod get method => HTTPMethod.post;

  @override
  Map<String, dynamic>? get query => null;

  @override
  Map<String, dynamic>? get body => {
    'current_password': currentPassword,
    'new_password': newPassword,
    'new_password_confirmation': newPasswordConfirmation,
  };

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
  Future request() {
    return APIProvider.instance.request(this);
  }
}
