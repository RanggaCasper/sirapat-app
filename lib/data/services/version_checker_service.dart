import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckerService {
  final Dio _dio;
  final String _repoOwner;
  final String _repoName;

  VersionCheckerService({
    required String repoOwner,
    required String repoName,
    Dio? dio,
  }) : _repoOwner = repoOwner,
       _repoName = repoName,
       _dio = dio ?? Dio();

  /// Check if there's a newer version available on GitHub
  Future<VersionCheckResult> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      print('Current app version: ${packageInfo}');
      final currentVersion = packageInfo.version;

      // Get latest release from GitHub
      final response = await _dio.get(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        final releaseUrl = data['html_url'] as String;
        final releaseNotes = data['body'] as String? ?? '';
        final releaseDate = data['published_at'] as String;

        // Get download URLs for assets
        final assets = data['assets'] as List;
        String? apkUrl;
        String? aabUrl;

        for (var asset in assets) {
          final name = asset['name'] as String;
          final downloadUrl = asset['browser_download_url'] as String;

          if (name.endsWith('.apk')) {
            apkUrl = downloadUrl;
          } else if (name.endsWith('.aab')) {
            aabUrl = downloadUrl;
          }
        }

        final hasUpdate = _compareVersions(currentVersion, latestVersion) < 0;

        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          hasUpdate: hasUpdate,
          releaseUrl: releaseUrl,
          releaseNotes: releaseNotes,
          releaseDate: DateTime.parse(releaseDate),
          apkDownloadUrl: apkUrl,
          aabDownloadUrl: aabUrl,
        );
      } else {
        throw Exception('Failed to fetch release info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error checking for updates: $e');
    }
  }

  /// Get all releases from GitHub
  Future<List<ReleaseInfo>> getAllReleases({int perPage = 10}) async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases',
        queryParameters: {'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ReleaseInfo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch releases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching releases: $e');
    }
  }

  /// Compare two version strings
  /// Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
  int _compareVersions(String v1, String v2) {
    // Remove build number if exists (e.g., "1.0.0+1" -> "1.0.0")
    v1 = v1.split('+').first;
    v2 = v2.split('+').first;

    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = v1Parts.length > v2Parts.length
        ? v1Parts.length
        : v2Parts.length;

    for (int i = 0; i < maxLength; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }

    return 0;
  }
}

class VersionCheckResult {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseUrl;
  final String releaseNotes;
  final DateTime releaseDate;
  final String? apkDownloadUrl;
  final String? aabDownloadUrl;

  VersionCheckResult({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseUrl,
    required this.releaseNotes,
    required this.releaseDate,
    this.apkDownloadUrl,
    this.aabDownloadUrl,
  });
}

class ReleaseInfo {
  final String version;
  final String name;
  final String description;
  final String url;
  final DateTime publishedAt;
  final bool isPrerelease;
  final List<AssetInfo> assets;

  ReleaseInfo({
    required this.version,
    required this.name,
    required this.description,
    required this.url,
    required this.publishedAt,
    required this.isPrerelease,
    required this.assets,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) {
    final assetsList =
        (json['assets'] as List?)?.map((a) => AssetInfo.fromJson(a)).toList() ??
        [];

    return ReleaseInfo(
      version: (json['tag_name'] as String).replaceAll('v', ''),
      name: json['name'] as String? ?? '',
      description: json['body'] as String? ?? '',
      url: json['html_url'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      isPrerelease: json['prerelease'] as bool? ?? false,
      assets: assetsList,
    );
  }
}

class AssetInfo {
  final String name;
  final String downloadUrl;
  final int size;

  AssetInfo({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  factory AssetInfo.fromJson(Map<String, dynamic> json) {
    return AssetInfo(
      name: json['name'] as String,
      downloadUrl: json['browser_download_url'] as String,
      size: json['size'] as int,
    );
  }
}
