# Vantage 419: The Definitive Project Bible

**Version:** 1.0.0-beta
**Date:** February 13, 2026
**Commit:** `38399a7` (Sprint 7 Complete)
**Purpose:** This document is the single source of truth for the Vantage 419 project. It contains every detail necessary to understand, maintain, and recreate the application from scratch.

---

## 1. Project Overview

### 1.1 Identity
*   **Name:** Vantage 419
*   **Mission:** To gamify local discovery in Toledo, Ohio, by removing decision paralysis through weighted random selection.
*   **Tagline:** "Don't decide. Spin."

### 1.2 Core Capabilities
1.  **Roulette Engine:** A weighted random selection algorithm triggers a "Tinder-style" card shuffle animation to reveal a dining or entertainment spot.
2.  **Interactive Map:** A full-screen map interface (OpenStreetMap) showing user location and spots.
3.  **Local Intelligence:** Tracks user history locally to prioritize unvisited spots (3x weight).
4.  **OLED-First Design:** A custom "Midnight" theme (#0A0E14) optimized for modern displays and battery life.

---

## 2. Architecture & Patterns

The application follows a **Domain-Driven, Feature-First** architecture using **Riverpod** for dependency injection and state management.

### 2.1 Dependency Graph
The `ProviderScope` in `main.dart` initializes the root state.

*   **Root Providers** (`core/providers/repository_providers.dart`):
    *   `sharedPreferencesProvider` → Injected via `overrides` in `main.dart`.
    *   `performanceProvider` → `PerformanceService` (Singleton).
    *   `analyticsProvider` → `AnalyticsService` (Singleton).
    *   `spotLocalDataSourceProvider` → Depends on `SharedPreferences` + `PerformanceService`.
    *   `spotRepositoryProvider` → Depends on `SpotLocalDataSource`.

*   **Feature Providers**:
    *   `spotsProvider` (FutureProvider) → Fetches `List<ToledoSpot>` from Repository.
    *   `userLocationProvider` (StreamProvider) → Geolocator updates.
    *   `mapControllerProvider` (Provider) → `MapController` instance.
    *   `rouletteStateProvider` (StateNotifier) → Manages the "Spin" lifecycle (Idle -> Spinning -> Result).

### 2.2 File Structure Hierarchy
A detailed manifest of the `lib/` directory:

```text
lib/
├── core/                               # SHARED FOUNDATION
│   ├── data_sources/
│   │   └── spot_local_data_source.dart # Loads spots.json, manages visits in Prefs
│   ├── errors/
│   │   └── app_exception.dart          # Base exception class
│   ├── models/
│   │   ├── spot_category.dart          # Enum: dining, nightlife, etc.
│   │   ├── toledo_spot.dart            # Immutable Data Class (JSON/Domain)
│   │   └── user_visit.dart             # History Entity (timestamped)
│   ├── providers/
│   │   ├── repository_providers.dart   # DI Container for Core Services
│   │   └── spots_provider.dart         # Data access provider
│   ├── repositories/
│   │   ├── spot_repository.dart        # Abstract Interface
│   │   └── spot_repository_impl.dart   # Concrete Impl (Error Handling wrapper)
│   ├── services/
│   │   ├── analytics_service.dart      # Event tracking wrapper
│   │   ├── location_service.dart       # Geolocator logic
│   │   ├── performance_service.dart    # Trace logging
│   │   └── roulette_service.dart       # Pure random selection logic
│   ├── theme/
│   │   ├── colors.dart                 # Static color constants (Legacy)
│   │   ├── palette.dart                # ThemeExtension (Semantic Colors)
│   │   ├── typography.dart             # TextTheme (Space Grotesk / Inter)
│   │   └── vantage_theme.dart          # ThemeData builder
│   └── utils/
│       ├── constants.dart              # Config strings, magic numbers
│       └── extensions.dart             # Dart extensions
├── features/                           # VERTICAL SLICES
│   ├── map/
│   │   ├── providers/                  # Map-specific state
│   │   │   ├── map_controller_provider.dart
│   │   │   └── user_location_provider.dart
│   │   ├── widgets/
│   │   │   ├── category_selector.dart      # Filter chips
│   │   │   ├── floating_search_pill.dart   # Main FAB/Action Bar
│   │   │   ├── location_rationale_dialog.dart
│   │   │   └── user_location_marker.dart
│   │   └── map_screen.dart             # Feature Entry Point
│   ├── roulette/
│   │   ├── providers/
│   │   │   └── roulette_state_provider.dart # Spin state management
│   │   ├── widgets/
│   │   │   └── shuffle_deck_overlay.dart    # The "Card stack" animation
│   │   └── logic/ (folded into core/services for purity)
│   ├── splash/
│   │   └── splash_screen.dart          # App startup
│   └── settings/
│       └── widgets/theme_toggle.dart   # Dark mode switch
└── main.dart                           # App Entry
```

---

## 3. Design System (Tokens)

The app uses `VantagePalette` (ThemeExtension) to support seamless Light/Dark mode switching without hardcoded values.

### 3.1 Color Palette (`core/theme/palette.dart`)

**Dark Mode (Default/Midnight)**
*   **Background**: `#0A0E14` (Deep Blue/Black)
*   **Surface**: `#1A1F2E` (Card BG)
*   **Accent**: `#0D7ABF` (Toyota Blue)
*   **Text Primary**: `#E6E6E6`
*   **Text Secondary**: `#8B95A8`
*   **Status**: Error (`#F44336`), Success (`#4CAF50`).

**Light Mode (YummiBite)**
*   **Background**: `#FAF7F2` (Warm Cream)
*   **Surface**: `#FFFFFF` (White)
*   **Accent**: `#2D5016` (Forest Green - Replaces Blue)
*   **Text Primary**: `#1A1A1A`

### 3.2 Typography (`core/theme/typography.dart`)
*   **Headings**: `GoogleFonts.playfairDisplay`
    *   Display Large: 32px (Bold)
    *   Headline Medium: 20px (w600)
*   **Body**: `GoogleFonts.inter`
    *   Body Large: 16px
    *   Label Small: 11px (JetBrains Mono)

---

## 4. Feature Logic Deep Dive

### 4.1 The Roulette Algorithm (`RouletteService.dart`)
Function: `spin(pool, visits)`
1.  **Filtering**: Input pool is already filtered by the active `SpotCategory`.
2.  **Recency Check**:
    *   Identify IDs visited within `AppConstants.visitedWindowDays` (30 days).
3.  **Weight System**:
    *   **Loop** through filtered pool.
    *   IF spot is in `recent` -> Add **1** instance to `weightedList`.
    *   ELSE -> Add **3** instances (`AppConstants.unvisitedWeight`).
4.  **Selection**: `weightedList[Random().nextInt(length)]`.

### 4.2 Data ingestion (`ToledoSpot.fromJson`)
The model is defensive against bad data:
*   **Coordinates**: Clamped to (-90, 90) / (-180, 180).
*   **Category**: Uses `try/catch` on `SpotCategory.values.byName`. Defaults to `entertainment` if invalid.
*   **Tags**: Null-coalesces to empty list `[]`.

---

## 5. Development History (The Sprint Chronicles)

### Sprint 0: Initialization
*   **Goal**: Stable Environment.
*   **Output**: Flutter 3.10+ setup, Lint rules (`analysis_options.yaml`), CI pipeline.

### Sprint 1: Critical Blockers
*   **Key Fix**: `LocationPermission` handling. Added `LocationRationaleDialog` to explain *why* we need GPS before asking.
*   **Key Fix**: `MapController` memory leak resolved by disposing in provider.

### Sprint 2: Foundation
*   **Feature**: "Search" was removed in favor of "Spin Only" (Decision Record 2.1).
*   **Tech**: `AnalyticsService` backed by `debugPrint` (ready for Firebase).

### Sprint 3: Polish
*   **UI**: Implemented `VantagePalette` for OLED dark mode.
*   **Icon**: Added native Android/iOS icons via `flutter_launcher_icons`.

### Sprint 4 & 5: Quality & Testing
*   **Linting**: Strict rules enabled.
*   **Tests**: Unit tests for `RouletteService` (validation of weights) and Widget tests for `FloatingSearchPill`.

### Sprint 6: Architecture
*   **Performance**: `PerformanceService` adds traces to JSON parsing.
*   **Caching**: `CachedNetworkImage` added to `ShuffleDeckOverlay` to prevent flicker on rapid spins.

### Sprint 7: Release (Current)
*   **Build**: Release APK generated (`flutter build apk --release`).
*   **CI**: GitHub Actions workflow validates every push.
*   **Docs**: Project Bible created.

---

## 6. How to Recreate (Step-by-Step)

If you have this document and the assets, you can rebuild Vantage 419:

1.  **Create Project**:
    ```bash
    flutter create --org dev.adnanashraf vantage419
    ```
2.  **Add Dependencies**:
    *   `flutter_riverpod`, `flutter_map`, `latlong2`, `geolocator`, `shared_preferences`, `url_launcher`, `cached_network_image`, `google_fonts`.
    *   Dev: `flutter_launcher_icons`, `flutter_lints`, `mocktail`.
3.  **Setup Assets**:
    *   Create `assets/data/spots.json`.
    *   Add fonts/icons if not using packages.
    *   Update `pubspec.yaml` to include assets.
4.  **Copy Core Logic**:
    *   Implement `ToledoSpot`, `SpotCategory` models.
    *   Implement `SpotLocalDataSource` (loads JSON).
    *   Implement `RouletteService` (Algorithm).
5.  **Build UI**:
    *   Create `MapScreen` with `FlutterMap`.
    *   Overlay `FloatingSearchPill`.
    *   Implement `ShuffleDeckOverlay` for the spin result.
6.  **Wire Up**:
    *   Wrap app in `ProviderScope`.
    *   Inject `spotRepositoryProvider`.

---

## 7. Known Issues / Roadmap
*   **Backend**: Data is currently static. Next integeration: Supabase.
*   **iOS Signing**: Not configured (Dev needs Apple Developer Account).
*   **Golden Tests**: Disabled due to font rendering differences in CI.

---

**End of File.**
