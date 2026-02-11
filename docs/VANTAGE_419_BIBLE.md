# Vantage 419: The Project Bible

**Version:** 1.0.0
**Date:** February 11, 2026
**purpose:** This document contains ALL information required to recreate the core of Vantage 419 from scratch, including architecture, logic, data, and design tokens.

---

## 1. Project Identity

**Name:** Vantage 419
**Tagline:** Discover Toledo, One Spin at a Time.
**Mission:** Gamify local discovery in Toledo, Ohio, by using a weighted random selection engine to combat decision paralysis.
**Key Features:**
*   **Roulette**: Spin a wheel to find a spot.
*   **Weighted Logic**: Unvisited spots are 3x more likely to be picked.
*   **Moods**: Hungry, Active, Surprise Me.
*   **Privacy**: Local-first connectivity.

---

## 2. Technical Foundation

### 2.1 Dependencies (`pubspec.yaml`)
*   **SDK**: Flutter (`>=3.10.8`), Dart 3.
*   **Core**:
    *   `flutter_riverpod: ^2.6.1` (State Management)
    *   `shared_preferences: ^2.3.4` (Persistence)
    *   `geolocator: ^13.0.2` (Location)
*   **UI/Assets**:
    *   `flutter_map: ^8.2.2` (OSM Maps)
    *   `latlong2: ^0.9.1` (Coordinates)
    *   `google_fonts: ^6.2.1` (Space Grotesk / Inter)
    *   `cupertino_icons: ^1.0.8`
*   **Utils**:
    *   `url_launcher: ^6.3.1` (Nav intents)
    *   `share_plus: ^10.1.4` (Sharing)

### 2.2 Configuration (`lib/core/utils/constants.dart`)
```dart
abstract final class AppConstants {
  static const toledoCenter = LatLng(41.6528, -83.5379);
  static const defaultZoom = 13.0;
  static const spotZoom = 15.5;
  static const darkTileUrl = 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
  static const spinDuration = Duration(milliseconds: 1000);
  static const cameraDuration = Duration(milliseconds: 1200);
  static const unvisitedWeight = 3; // 3x probability for new spots
  static const visitedWindowDays = 30; // Reset weight after 30 days
}
```

---

## 3. The Design System (Theming)

The app uses a custom `ThemeExtension` to support semantic coloring across Light and Dark modes.

### 3.1 `VantagePalette` Source (`lib/core/theme/palette.dart`)
```dart
class VantagePalette extends ThemeExtension<VantagePalette> {
  // ... (Constructor omitted for brevity)

  // DARK MODE (OLED Optimized)
  static const dark = VantagePalette(
    primaryBackground: Color(0xFF0A0E14), // Deep Blue/Black
    surface: Color(0xFF1A1F2E),
    accent: Color(0xFF0D7ABF), // Toyota Blue
    textPrimary: Color(0xFFE6E6E6),
    // ...
  );

  // LIGHT MODE (High Contrast)
  static const light = VantagePalette(
    primaryBackground: Color(0xFFF8F9FA), // Off-white
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFF0D7ABF),
    textPrimary: Color(0xFF1A1F2E),
    // ...
  );
}
```

### 3.2 Typography
*   **Headings**: `Space Grotesk` (Geometric, modern).
*   **Body**: `Inter` (Clean, readable).

---

## 4. The Brain: Core Logic

### 4.1 Data Model (`ToledoSpot`)
```dart
class ToledoSpot {
  final String id;          // e.g. "din_001"
  final String name;        // e.g. "Kato Ramen"
  final double latitude;
  final double longitude;
  final SpotCategory category; // dining, fitness, etc.
  final String vibeCheck;   // Short caption
  final String description; // Full details
}
```

### 4.2 Roulette Algorithm (`RouletteService.dart`)
The heart of the app.
```dart
ToledoSpot? spin({
  required List<ToledoSpot> spots,
  required List<SpotCategory> categories, // From active mode
  required List<UserVisit> visits,
}) {
  // 1. Filter spots by category
  final pool = spots.where((s) => categories.contains(s.category)).toList();
  if (pool.isEmpty) return null;

  // 2. Identify "Recent" visits (last 30 days)
  final cutoff = DateTime.now().subtract(const Duration(days: 30));
  final recentIds = visits
      .where((v) => v.visitedAt.isAfter(cutoff))
      .map((v) => v.spotId)
      .toSet();

  // 3. Build Weighted List
  final weighted = <ToledoSpot>[];
  for (final spot in pool) {
    // If recently visited: Weight = 1
    // If NEW or old visit: Weight = 3
    final weight = recentIds.contains(spot.id) ? 1 : 3; 
    for (var i = 0; i < weight; i++) {
        weighted.add(spot);
    }
  }

  // 4. Pick Winner
  return weighted[Random().nextInt(weighted.length)];
}
```

---

## 5. Implementation History (Sprints 1-9)

### Sprint 1: Stability (P0)
*   **Leak Fix**: Wrapped `MapController` in a Provider with `ref.onDispose` to prevent memory leaks.
*   **Permissions**: Added specific handling for `LocationPermission.denied` to show a banner instead of crashing.

### Sprint 2: UX Polish
*   **Animations**: Added `AnimatedPositioned` to the Spin Button so it slides up when the Bottom Sheet opens.
*   **Haptics**: Added `HapticFeedback.mediumImpact()` on spin and `heavyImpact()` on result.

### Sprint 3: Logic
*   **History Cap**: Logic added to `_pruneVisits` to keep only the last 500 visits, ensuring `SharedPreferences` doesn't explode.
*   **Validation**: Start-up check ensures unique IDs for all static spots.

### Sprint 4: Refactor
*   **Feature-Sliced**: Moved code into `features/map`, `features/roulette`, `features/settings`.
*   **Barrel Files**: created `core.dart` to export common models.

### Sprint 5: Performance
*   **RepaintBoundary**: Wrapped the rotating wheel in `RepaintBoundary` to stop the Map from repainting 60fps during spin.
*   **Memoization**: Cached the filtered spot list using `Provider` families.

### Sprint 6: Acquisition
*   **Splash**: Added `SplashScreen` with fade transition.
*   **Share**: Implemented `Share.share(...)` with a Google Maps link.

### Sprint 7: Theming
*   **Architecture**: Built `VantagePalette` ThemeExtension.
*   **Persistence**: Saved `ThemeMode` index to prefs.

### Sprint 8: QA
*   **Tests**: Added `integration_test/app_test.dart` for "Splash -> Map -> Spin" flow.
*   **Accessibility**: Added `Semantics` to all interactive buttons.

### Sprint 9: Launch
*   **Assets**: Created Store Listing, Privacy Policy, Build Instructions.
*   **Release**: Verified release build pipeline.

---

## 6. Full Data Set (Static)
Located in `lib/data/toledo_spots.dart`.
*   **Dining**: Kato Ramen, Night Owl Diner, Kyoto Ka, Nagoya, Top Pot BBQ.
*   **Recreation**: Ottawa Park, Glass City Metropark, Toledo Zoo.
*   **Fitness**: YMCA Perrysburg.
*   **Cafe**: The Onyx Cafe.

---

## 7. Build Instructions
1.  **Install**: Flutter JDK.
2.  **Run**: `flutter run` (Debug).
3.  **Release**:
    *   Create `upload-keystore.jks`.
    *   Add `android/key.properties`.
    *   Run `flutter build apk --release`.

---

**This document allows any agent to rebuild Vantage 419's logic and structure accurately.**
