import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

/// Initialize permanent dependencies that should live throughout the app lifecycle
class DependencyInjection {
  static Future<void> init() async {
    // Initialize LocalStorageService as permanent service
    await Get.putAsync(() => LocalStorageService().init(), permanent: true);

    // Initialize NotificationController as permanent
    Get.put(NotificationController(), permanent: true);

    // ignore: avoid_print
    print('[DependencyInjection] All permanent dependencies initialized');
  }
}
