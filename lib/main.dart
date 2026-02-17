import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/theme/colors.dart';
import 'package:vantage419/core/theme/theme_provider.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';
import 'package:vantage419/features/splash/splash_screen.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vantage419/l10n/generated/app_localizations.dart';
<<<<<<< HEAD
=======
import 'package:vantage419/core/services/analytics_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vantage419/firebase_options.dart';
>>>>>>> main

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
=======
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Analytics service for error logging (initialized after Firebase)
  final analytics = AnalyticsService();

>>>>>>> main
  // Global error handler — catches framework-level errors (widget build failures, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FlutterError caught: ${details.exceptionAsString()}');
    analytics.logError(details.exception, details.stack);
  };

  // Async/isolate error handler — catches errors outside the Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PlatformDispatcher error: $error');
    debugPrint('$stack');
    analytics.logError(error, stack, fatal: true);
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
