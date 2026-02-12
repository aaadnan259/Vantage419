import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/vantage_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/providers/repository_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler — catches framework-level errors (widget build failures, etc.)
  // TODO: Replace debugPrint with Sentry/Crashlytics reporting in production
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FlutterError caught: ${details.exceptionAsString()}');
    // TODO: FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Async/isolate error handler — catches errors outside the Flutter framework
  // TODO: Replace debugPrint with Sentry/Crashlytics reporting in production
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PlatformDispatcher error: $error');
    debugPrint('$stack');
    // TODO: FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Lock to portrait for focused mobile UX
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // OLED-friendly status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: VantageColors.primaryBackground,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const VantageApp(),
    ),
  );
}

class VantageApp extends ConsumerWidget {
  const VantageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Vantage 419',
      debugShowCheckedModeBanner: false,
      theme: VantageTheme.light,
      darkTheme: VantageTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
