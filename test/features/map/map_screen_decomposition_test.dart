import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/providers/spots_provider.dart';
import 'package:vantage419/core/repositories/spot_repository.dart';
import 'package:vantage419/core/services/analytics_service.dart';
import 'package:vantage419/features/map/map_screen.dart';
import 'package:vantage419/features/map/providers/user_location_provider.dart';
import 'package:vantage419/features/map/widgets/map_action_area.dart';
import 'package:vantage419/features/map/widgets/map_status_banners.dart';
import 'package:vantage419/features/map/widgets/map_top_bar.dart';
import 'package:vantage419/features/map/widgets/map_view.dart';
import 'package:vantage419/l10n/generated/app_localizations.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {
  @override
  Future<void> logScreenView(String? screenName, {String? screenClass}) async {}
}

class MockSpotRepository extends Mock implements SpotRepository {
  @override
  Future<List<UserVisit>> getVisits() async => [];

  @override
  Future<List<ToledoSpot>> getSpots() async => [];
}

class MockTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final Uint8List transparentImage = Uint8List.fromList(<int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44,
      0xAE, 0x42, 0x60, 0x82,
    ]);
    return MemoryImage(transparentImage);
  }
}

void main() {
  testWidgets('MapScreen renders decomposed widgets', (
    WidgetTester tester,
  ) async {
    // Set a large surface size to avoid overflow in CategorySelector
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final mockAnalytics = MockAnalyticsService();
    final mockRepository = MockSpotRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          analyticsProvider.overrideWithValue(mockAnalytics),
          spotRepositoryProvider.overrideWithValue(mockRepository),
          // Override spots provider to return immediately
          toledoSpotsProvider.overrideWith((ref) async => []),
          // Override location provider to be loading
          userLocationProvider.overrideWith(
            (ref) => StreamController<LatLng>().stream,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapScreen(
            tileProvider: MockTileProvider(),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Pump again to settle any microtasks
    await tester.pump(const Duration(milliseconds: 100));

    // Verify widgets are present
    expect(find.byType(MapView), findsOneWidget);
    expect(find.byType(MapStatusBanners), findsOneWidget);
    expect(find.byType(MapTopBar), findsOneWidget);
    expect(find.byType(MapActionArea), findsOneWidget);
  });
}
