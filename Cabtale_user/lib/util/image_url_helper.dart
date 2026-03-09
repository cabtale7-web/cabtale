import 'package:ride_sharing_user_app/util/app_constants.dart';

class ImageUrlHelper {
  static final RegExp _missingSlashAfterHostPattern =
      RegExp(r'^(https?://[^/]+)(api|storage|public)(/.*)?$');

  static String normalizeBasePath(
    String? url, {
    String fallbackBaseUrl = AppConstants.baseUrl,
  }) {
    final normalizedUrl = normalizeUrl(url, fallbackBaseUrl: fallbackBaseUrl);
    if (normalizedUrl.isEmpty) {
      return '';
    }
    return normalizedUrl.replaceAll(RegExp(r'/+$'), '');
  }

  static String buildImageUrl(
    String? image, {
    String? baseUrl,
    String fallbackBaseUrl = AppConstants.baseUrl,
  }) {
    final rawImage = _sanitize(image);
    if (rawImage.isEmpty) {
      return '';
    }

    if (_isAbsoluteUrl(rawImage)) {
      return normalizeUrl(rawImage, fallbackBaseUrl: fallbackBaseUrl);
    }

    final normalizedBaseUrl = normalizeBasePath(
      baseUrl,
      fallbackBaseUrl: fallbackBaseUrl,
    );

    if (rawImage.startsWith('/')) {
      final origin = _originOf(normalizedBaseUrl) ?? fallbackBaseUrl;
      return normalizeUrl('$origin$rawImage', fallbackBaseUrl: fallbackBaseUrl);
    }

    if (rawImage.startsWith('storage/')) {
      final origin = _originOf(normalizedBaseUrl) ?? fallbackBaseUrl;
      return normalizeUrl('$origin/$rawImage', fallbackBaseUrl: fallbackBaseUrl);
    }

    if (normalizedBaseUrl.isEmpty) {
      return normalizeUrl(rawImage, fallbackBaseUrl: fallbackBaseUrl);
    }

    return normalizeUrl(
      '$normalizedBaseUrl/$rawImage',
      fallbackBaseUrl: fallbackBaseUrl,
    );
  }

  static String normalizeUrl(
    String? url, {
    String fallbackBaseUrl = AppConstants.baseUrl,
  }) {
    var normalizedUrl = _sanitize(url);
    if (normalizedUrl.isEmpty) {
      return '';
    }

    normalizedUrl = normalizedUrl
        .replaceAll('/public/storage/app/public/', '/public/storage/')
        .replaceAll('/storage/app/public/', '/storage/');

    final hostMatch = _missingSlashAfterHostPattern.firstMatch(normalizedUrl);
    if (hostMatch != null) {
      normalizedUrl =
          '${hostMatch.group(1)}/${hostMatch.group(2)}${hostMatch.group(3) ?? ''}';
    }

    if (!_isAbsoluteUrl(normalizedUrl) && normalizedUrl.startsWith('/')) {
      normalizedUrl = '$fallbackBaseUrl$normalizedUrl';
    }

    final absoluteMatch =
        RegExp(r'^(https?://)(.*)$').firstMatch(normalizedUrl);
    if (absoluteMatch != null) {
      final scheme = absoluteMatch.group(1)!;
      final remainder = absoluteMatch.group(2)!.replaceAll(RegExp(r'/+'), '/');
      return '$scheme$remainder';
    }

    return normalizedUrl.replaceAll(RegExp(r'/+'), '/');
  }

  static String _sanitize(String? value) {
    return (value ?? '').trim().replaceAll('\\', '/');
  }

  static bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static String? _originOf(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }
}
