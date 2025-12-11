import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/data/providers/network/audio_provider.dart';
import 'package:sirapat_app/data/repositories/audio_repository.dart';

/// Initialize permanent dependencies that should live throughout the app lifecycle
class DependencyInjection {
  static Future<void> init() async {
    // Initialize LocalStorageService as permanent service
    await Get.putAsync(() => LocalStorageService().init(), permanent: true);

    // Initialize NotificationController as permanent
    Get.put(NotificationController(), permanent: true);

    // Initialize API Provider (must be before other providers that depend on it)
    Get.put(APIProvider.instance, permanent: true);

    // Initialize Audio services
    Get.put(AudioProvider(), permanent: true);
    Get.put(AudioRepository(), permanent: true);

    // ignore: avoid_print
    print('[DependencyInjection] All permanent dependencies initialized');
  }
}
