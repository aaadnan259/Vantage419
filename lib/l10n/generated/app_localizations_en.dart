// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vantage 419';

  @override
  String errorLoadingSpots(String error) {
    return 'Error loading spots: $error';
  }

  @override
  String get noSpotsHereTitle => 'No spots here!';

  @override
  String get noSpotsHereDescription =>
      'Try adjusting your filters or\nexplore a different area.';

  @override
  String noSpotsMatchMode(String mode) {
    return 'No spots match \'$mode\' — try \'Surprise Me\'!';
  }

  @override
  String get genericSpinError => 'Something went wrong. Try spinning again.';

  @override
  String get locationAccessDeniedForever =>
      'Location access permanently denied';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locationServicesOff => 'Location services are off';

  @override
  String get enable => 'Enable';

  @override
  String get locationPermissionNeeded =>
      'Location permission needed for your position';

  @override
  String get settings => 'Settings';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get mapTilesUnavailable =>
      'Map tiles unavailable — check your connection';
}
