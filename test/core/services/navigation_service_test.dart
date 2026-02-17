import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:vantage419/core/services/navigation_service.dart';

class MockUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  String? launchedUrl;
  PreferredLaunchMode? launchedMode;

  final Set<String> installedSchemes = {
    'comgooglemaps',
    'waze',
    'https',
    'google.navigation'
  };

  @override
  Future<bool> canLaunch(String url) async {
    final uri = Uri.parse(url);
    if (installedSchemes.contains(uri.scheme)) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    launchedMode = options.mode;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUrlLauncher mockUrlLauncher;

  setUp(() {
    mockUrlLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  tearDown(() {
    mockUrlLauncher.launchedUrl = null;
    mockUrlLauncher.launchedMode = null;
    debugDefaultTargetPlatformOverride = null;
  });

  test('navigateTo uses Google Maps scheme on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    // Simulate iOS environment where google.navigation scheme is NOT supported
    mockUrlLauncher.installedSchemes.remove('google.navigation');
    mockUrlLauncher.installedSchemes.add('comgooglemaps');

    await NavigationService.instance.navigateTo(latitude: 41.6528, longitude: -83.5379);

    // Current code uses google.navigation, which is removed from installed schemes.
    // So it falls back to Waze (https) or Web.
    // We expect it to use comgooglemaps:// after fix.
    // So this test should FAIL currently.
    expect(mockUrlLauncher.launchedUrl, startsWith('comgooglemaps://'));
  });

  test('navigateTo uses Waze scheme on iOS if Google Maps not installed', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    mockUrlLauncher.installedSchemes.remove('google.navigation');
    mockUrlLauncher.installedSchemes.remove('comgooglemaps');
    mockUrlLauncher.installedSchemes.add('waze');

    await NavigationService.instance.navigateTo(latitude: 41.6528, longitude: -83.5379);

    expect(mockUrlLauncher.launchedUrl, startsWith('waze://'));
  });

  test('navigateTo uses Android scheme on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    mockUrlLauncher.installedSchemes.add('google.navigation');

    await NavigationService.instance.navigateTo(latitude: 41.6528, longitude: -83.5379);

    expect(mockUrlLauncher.launchedUrl, startsWith('google.navigation:'));
  });
}
