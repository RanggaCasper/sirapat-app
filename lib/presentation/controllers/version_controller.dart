import 'package:get/get.dart';
import 'package:sirapat_app/data/services/version_checker_service.dart';

class VersionController extends GetxController {
  final VersionCheckerService _versionChecker;

  VersionController({required String repoOwner, required String repoName})
    : _versionChecker = VersionCheckerService(
        repoOwner: repoOwner,
        repoName: repoName,
      );

  final Rx<VersionCheckResult?> versionInfo = Rx<VersionCheckResult?>(null);
  final RxBool isChecking = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Automatically check for updates on initialization
    checkForUpdate();
  }

  /// Check for app updates
  Future<void> checkForUpdate() async {
    try {
      isChecking.value = true;
      error.value = '';

      final result = await _versionChecker.checkForUpdate();
      versionInfo.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isChecking.value = false;
    }
  }

  /// Get all releases
  Future<List<ReleaseInfo>> getAllReleases() async {
    try {
      return await _versionChecker.getAllReleases();
    } catch (e) {
      error.value = e.toString();
      return [];
    }
  }

  bool get hasUpdate => versionInfo.value?.hasUpdate ?? false;

  String get currentVersion => versionInfo.value?.currentVersion ?? '-';

  String get latestVersion => versionInfo.value?.latestVersion ?? '-';
}
