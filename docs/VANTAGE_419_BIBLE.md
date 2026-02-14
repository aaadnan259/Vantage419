# Vantage 419: The Definitive Project Bible

**Version:** 1.0.0-beta
**Date:** February 13, 2026
**Commit:** `d2d4526` (Sprint 7 Complete)
**Purpose:** This document is the **single source of truth** for the Vantage 419 project. It contains every detail necessary to understand, maintain, re-implement, and deploy the application without access to the original repository.

---

## 1. Genesis & Identity

### 1.1 Core Identity
*   **Name:** Vantage 419
*   **Mission:** Gamify local discovery in Toledo, Ohio, by removing decision paralysis through weighted random selection.
*   **Tagline:** "Don't decide. Spin."
*   **Target Audience:** Toledo residents and visitors who "don't know where to eat."

### 1.2 Key Features
1.  **Roulette Engine:** A weighted random selection algorithm triggers a "Tinder-style" card shuffle animation.
2.  **Interactive Map:** A full-screen map interface (OpenStreetMap) showing user location and spots.
3.  **Local Intelligence:** Tracks user history locally to prioritize unvisited spots (3x weight).
4.  **OLED-First Design:** A custom "Midnight" theme (#0A0E14) optimized for modern displays.

---

## 2. Architecture & File Structure

The project follows a **Feature-First Clean Architecture** using **Riverpod** for state management.

### 2.1 File Tree Manifest
```text
lib/
├── core/                               # SHARED FOUNDATION
│   ├── data_sources/
│   │   └── spot_local_data_source.dart # Loads spots.json, manages visits in Prefs
│   ├── errors/
│   │   └── app_exception.dart          # Base exception class
│   ├── models/
│   │   ├── spot_category.dart          # Enum: dining, nightlife, etc.
│   │   ├── toledo_spot.dart            # Immutable Spot Entity
│   │   └── user_visit.dart             # History Entity (timestamped)
│   ├── providers/
│   │   ├── repository_providers.dart   # DI Container for Core Services
│   │   └── spots_provider.dart         # FutureProvider<List<ToledoSpot>>
│   ├── repositories/
│   │   ├── spot_repository.dart        # Abstract Interface
│   │   └── spot_repository_impl.dart   # Implementation (Error Wrapper)
│   ├── services/
│   │   ├── analytics_service.dart      # Event tracking wrapper
│   │   ├── location_service.dart       # Geolocator logic
│   │   ├── performance_service.dart    # Trace logging
│   │   └── roulette_service.dart       # Pure selection logic
│   ├── theme/
│   │   ├── colors.dart                 # Static color constants
│   │   ├── palette.dart                # ThemeExtension (Semantic Colors)
│   │   ├── typography.dart             # TextTheme (Space Grotesk / Inter)
│   │   └── vantage_theme.dart          # ThemeData builder
│   └── utils/
│       ├── constants.dart              # Config strings, magic numbers
│       └── extensions.dart             # Context extensions
├── features/                           # VERTICAL SLICES
│   ├── map/
│   │   ├── providers/
│   │   │   ├── map_controller_provider.dart
│   │   │   └── user_location_provider.dart
│   │   ├── widgets/
│   │   │   ├── category_selector.dart      # Filter chips
│   │   │   ├── floating_search_pill.dart   # Main Action Button
│   │   │   ├── location_rationale_dialog.dart
│   │   │   └── user_location_marker.dart
│   │   └── map_screen.dart             # Feature Entry Point
│   ├── roulette/
│   │   ├── providers/
│   │   │   └── roulette_state_provider.dart # Spin state cycle
│   │   ├── widgets/
│   │   │   └── shuffle_deck_overlay.dart    # Animation (Cards)
│   │   └── logic/ (Delegates to core/services)
│   ├── splash/
│   │   └── splash_screen.dart          # Branded Entry
│   └── settings/
│       └── widgets/theme_toggle.dart   # Dark/Light switch
└── main.dart                           # App Entry
```

---

## 3. Design System (Tokens)

The app uses `VantagePalette` (ThemeExtension) to support seamless Light/Dark mode switching.

### 3.1 Color Palette
**Dark Mode (Midnight)**
*   **Background**: `#0A0E14` (Deep Blue/Black)
*   **Surface**: `#1A1F2E` (Card BG)
*   **Accent**: `#0D7ABF` (Toyota Blue)
*   **Text Primary**: `#E6E6E6`

**Light Mode (YummiBite)**
*   **Background**: `#FAF7F2` (Warm Cream)
*   **Surface**: `#FFFFFF` (White)
*   **Accent**: `#2D5016` (Forest Green)
*   **Text Primary**: `#1A1A1A`

### 3.2 Typography
*   **Headings**: `Playfair Display` (Bold, Serif).
*   **Body**: `Inter` (Sans-serif, Clean).
*   **Code**: `JetBrains Mono` (Debug logs).

---

## 4. Feature Logic Deep Dive

### 4.1 The Roulette Algorithm
Located in `RouletteService`, the selection logic is **weighted**:
1.  **Filter**: Candidates must match the selected `SpotCategory`.
2.  **Recency Check**: Identify IDs visited within last 30 days (`AppConstants.visitedWindowDays`).
3.  **Weighting**:
    *   **Recently Visited**: Weight = 1.
    *   **Unvisited / Old**: Weight = 3 (`AppConstants.unvisitedWeight`).
4.  **Selection**: Random pick from the weighted pool.

---

## 5. Development History (The Sprint Chronicles)

### Sprint 0: Initialization
*   **Goal**: Stable Environment.
*   **Output**: Flutter 3.10+ setup, Lint rules (`analysis_options.yaml`), CI pipeline.

### Sprint 1: Critical Blockers
*   **Fixes**: Solved `LocationPermission` loops on Android 14.
*   **Stability**: Implemented Global Error Handling (`FlutterError.onError`).

### Sprint 2: Foundation
*   **Feature**: "Search" removed in favor of "Spin Only".
*   **Tech**: `AnalyticsService` backed by `debugPrint`.

### Sprint 3: Polish
*   **UI**: Implemented `VantagePalette` for OLED dark mode.
*   **Icon**: Added native icons via `flutter_launcher_icons`.

### Sprint 4 & 5: Quality
*   **Linting**: Strict rules enabled.
*   **Tests**: Unit tests for `RouletteService` and Widget tests.

### Sprint 6: Architecture
*   **Performance**: `PerformanceService` adds traces to JSON parsing.
*   **Caching**: `CachedNetworkImage` added to prevent flicker.

### Sprint 7: Release (Current)
*   **Build**: Release APK generated (`flutter build apk --release`).
*   **CI**: GitHub Actions workflow validates every push.

---

## 6. The Source Code (Essential Files)

### 6.1 `lib/core/services/roulette_service.dart` (The Brain)
```dart
class RouletteService {
  final _rng = Random();

  ToledoSpot? spin({
    required List<ToledoSpot> pool, 
    required List<UserVisit> visits,
  }) {
    if (pool.isEmpty) return null;

    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recentVisitIds = visits.where((v) => v.visitedAt.isAfter(cutoff))
                                 .map((v) => v.spotId).toSet();

    final weighted = <ToledoSpot>[];
    for (final spot in pool) {
      final weight = recentVisitIds.contains(spot.id) ? 1 : 3;
      for (var i = 0; i < weight; i++) {
        weighted.add(spot);
      }
    }
    return weighted[_rng.nextInt(weighted.length)];
  }
}
```

### 6.2 `lib/core/data_sources/spot_local_data_source.dart` (The Data Layer)
```dart
class SpotLocalDataSource {
  final SharedPreferences _prefs;
  static const _visitsKey = 'user_visits';

  Future<List<ToledoSpot>> fetchStaticSpots() async {
    final raw = await rootBundle.loadString('assets/data/spots.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((json) => ToledoSpot.fromJson(json)).toList();
  }

  Future<void> saveVisits(List<UserVisit> visits) async {
    // Pruning logic to keep only last 500 visits
    final json = jsonEncode(visits.map((v) => v.toJson()).toList());
    await _prefs.setString(_visitsKey, json);
  }
}
```

### 6.3 `lib/core/theme/palette.dart` (The Design System)
```dart
class VantagePalette extends ThemeExtension<VantagePalette> {
  // ... fields omitted for brevity ...

  static const dark = VantagePalette(
    primaryBackground: Color(0xFF0A0E14), // Midnight
    accent: Color(0xFF0D7ABF),            // Toyota Blue
    /* ... */
  );

  static const light = VantagePalette(
    primaryBackground: Color(0xFFFAF7F2), // Cream
    accent: Color(0xFF2D5016),            // Forest Green
    /* ... */
  );
}
```

### 6.4 `lib/features/roulette/widgets/shuffle_deck_overlay.dart` (The Animation)
The visual centerpiece of the app.
```dart
// Simplified Logic Representation
class _ShuffleDeckOverlayState extends State<ShuffleDeckOverlay> {
  void _startShuffle() async {
    for (var i = 0; i < _displayStack.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _currentIndex = i + 1);
    }
    // Reveal Winner
  }
}
```

---

## 7. The Data (`assets/data/spots.json`)

The application is powered by this static JSON dataset.

```json
[
    {
        "id": "din_001",
        "name": "Kato Ramen",
        "latitude": 41.6528,
        "longitude": -83.5379,
        "category": "dining",
        "vibeCheck": "Late-night bowl perfection",
        "description": "Authentic Japanese ramen with rich tonkotsu broth.",
        "imageUrl": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624",
        "tags": ["Cozy", "Hot Soup", "Casual"]
    },
    {
        "id": "din_002",
        "name": "Night Owl Diner",
        "latitude": 41.6639,
        "longitude": -83.5552,
        "category": "dining",
        "vibeCheck": "Classic diner vibes, open late",
        "tags": ["Late Night", "Comfort Food", "Retro"]
    },
    {
        "id": "rec_001",
        "name": "Ottawa Park",
        "latitude": 41.6689,
        "longitude": -83.6012,
        "category": "recreation",
        "vibeCheck": "Pick-up games & cardio runs",
        "tags": ["Outdoors", "Cardio", "Free"]
    },
    {
        "id": "fit_001",
        "name": "YMCA Perrysburg",
        "latitude": 41.5570,
        "longitude": -83.6270,
        "category": "fitness",
        "vibeCheck": "Full-service wellness",
        "tags": ["Gym", "Swimming", "Wellness"]
    }
]
```

---

## 8. DevOps & CI/CD

### 8.1 GitHub Actions (`.github/workflows/flutter_ci.yml`)
Runs on every push to `main` or production branches.

```yaml
name: Flutter CI
on:
  push:
    branches: [ "main", "production-sprint-*" ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Analyze
        run: flutter analyze
      - name: Run tests
        run: flutter test
```

### 8.2 Deployment Checklist
1.  **Versioning**: Update `pubspec.yaml` (version: `1.0.0+X`).
2.  **Signing**:
    *   Create `key.properties`:
        ```properties
        storePassword=...
        keyPassword=...
        keyAlias=key0
        storeFile=../upload-keystore.jks
        ```
3.  **Build**: `flutter build apk --release`.
4.  **Verify**: Install on physical device.

---

**End of Definitive Project Bible**
