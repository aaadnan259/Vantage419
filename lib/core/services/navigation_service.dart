import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vantage419/core/utils/constants.dart';

/// Launches external navigation apps with destination coordinates.
class NavigationService {
  const NavigationService._();

  /// Singleton instance — no state, just methods (S5.5).
  static const instance = NavigationService._();

  /// Attempt Google Maps → Waze → web fallback.
  /// Returns false if all launch attempts fail or throw.
  Future<bool> navigateTo({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      // Try Google Maps first
      final googleUrl = Uri.parse(
        AppConstants.googleNavScheme
            .replaceAll('{lat}', latitude.toString())
            .replaceAll('{lng}', longitude.toString()),
      );
      if (await canLaunchUrl(googleUrl)) {
        return launchUrl(googleUrl);
      }

      // Waze fallback
      final wazeUrl = Uri.parse(
        AppConstants.wazeNavScheme
            .replaceAll('{lat}', latitude.toString())
            .replaceAll('{lng}', longitude.toString()),
      );
      if (await canLaunchUrl(wazeUrl)) {
        return launchUrl(wazeUrl, mode: LaunchMode.externalApplication);
      }

      // Web browser fallback
      final webUrl = Uri.parse(
        AppConstants.googleWebNavScheme
            .replaceAll('{lat}', latitude.toString())
            .replaceAll('{lng}', longitude.toString()),
      );
      return launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('⚠️ Navigation launch failed: $e');
      return false;
    }
  }
}
