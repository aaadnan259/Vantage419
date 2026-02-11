import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/vantage_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/providers/repository_providers.dart';
import 'features/roulette/providers/roulette_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for focused mobile UX
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // OLED-friendly status bar (S4.6: uses VantageColors)
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
