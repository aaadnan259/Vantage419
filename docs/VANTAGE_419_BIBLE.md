# Vantage 419: The Definitive Project Bible

**Version:** 1.0.0-beta
**Date:** February 12, 2026
**Purpose:** A comprehensive encyclopedia of the Vantage 419 project, documenting its history, architecture, and features to verify the current state and enable full reproduction.

---

## 1. Genesis & Identity

**Name:** Vantage 419
**Mission:** Break the routine of local discovery in Toledo, Ohio, through gamified, weighted random selection.
**Core Value:** "Don't decide. Spin."

**Key Features:**
*   **Roulette**: Tinder-style card shuffle animation to pick a spot.
*   **Weighted Logic**: Unvisited spots have 3x higher probability.
*   **OLED-First**: Deep dark mode (#0A0E14) for battery saving and aesthetic.
*   **Local-First**: No account required, all data static + local prefs.

---

## 2. Architecture & File Structure

The project follows a **Feature-First Clean Architecture**.

### 2.1 File Tree (Key Files)
```
lib/
├── core/
│   ├── data_sources/
│   │   └── spot_local_data_source.dart  # Handles JSON loading + Prefs
│   ├── models/
│   │   ├── toledo_spot.dart             # The Spot Entity (immutable)
│   │   ├── user_visit.dart              # History Record
│   │   └── spot_category.dart           # Enum (dining, nightlife, etc.)
│   ├── repositories/
│   │   ├── spot_repository.dart         # Interface
│   │   └── spot_repository_impl.dart    # Implementation (Standardized Errors)
│   ├── services/
│   │   ├── analytics_service.dart       # Usage tracking
│   │   └── performance_service.dart     # Trace monitoring
│   ├── theme/
│   │   ├── palette.dart                 # VantagePalette (ThemeExtension)
│   │   └── typography.dart              # Space Grotesk / Inter
│   └── utils/
│       └── constants.dart               # Config (URLs, LatLng, Durations)
├── features/
│   ├── map/
│   │   ├── map_screen.dart              # Main UI (FlutterMap)
│   │   └── widgets/
│   │       ├── floating_search_pill.dart # Primary Action Button
│   │       ├── category_selector.dart    # Filter Bar
│   │       └── user_location_marker.dart # "You are here"
│   ├── roulette/
│   │   ├── logic/
│   │   │   └── roulette_service.dart     # The Weighted Algorithm
│   │   └── widgets/
│   │       └── shuffle_deck_overlay.dart # The Animation (Stack of Cards)
│   └── splash/
│       └── splash_screen.dart            # Branded Entry
└── main.dart                             # App Entry, Providers, Routes
```

### 2.2 Tech Stack
*   **Flutter**: ^3.10.8
*   **Riverpod**: 2.6.1 (State Management)
*   **Flutter Map**: 8.2.2 (OpenStreetMap/CartoDB)
*   **CachedNetworkImage**: 3.4.1 (Image Caching)
*   **Shared Preferences**: 2.3.4 (Persistence)

---

## 3. The Chronicles (Version History)

### Sprint 0: Pre-Flight (Baseline)
*   **Established**: Project structure, linting rules, and CI environment.
*   **Result**: 0 lint errors, 17/17 passing tests baseline.

### Sprint 1: Critical Blockers
*   **Fixes**: Solved `LocationPermission` loops on Android 14.
*   **Stability**: Implemented Global Error Handling (`FlutterError.onError`).
*   **Bug**: Fixed `StateNotifier` async gap issues in MapController.

### Sprint 2: Foundation (P1)
*   **Data**: Moved hardcoded lists to `assets/data/spots.json`.
*   **Analytics**: Created `AnalyticsService` abstraction.
*   **UX**: Added "Spin Rate Limiting" (2s cooldown) to prevent spam.

### Sprint 3: Polish (P2)
*   **Branding**: Replaced default Flutter launcher icon with Vantage Logo.
*   **Splash**: Implemented OLED-black splash screen (#0A0A0A).
*   **Permissions**: Created `LocationRationaleDialog` for polite permission requests.

### Sprint 4: Code Quality
*   **Optimization**: Converted widgets to `const`, extracted Magic Numbers.
*   **Audit**: Fixed minor memory leaks in AnimationControllers.
*   **Cleanup**: Removed 6+ TODO comments, resolved 50+ lint warnings.

### Sprint 5: Testing
*   **Coverage**: Added Unit Tests for `RouletteService` and `SpotRepository`.
*   **Widgets**: Added tests for `FloatingSearchPill`.
*   **Integration**: Set up `integration_test` scaffold.

### Sprint 6: Architecture
*   **Monitoring**: Added `PerformanceService` to trace JSON load times.
*   **Caching**: Implemented `CachedNetworkImage` in `ShuffleDeckOverlay`.
*   **Hardening**: Standardized `RepositoryException` for predictable failures.

### Sprint 7: Deployment (Beta)
*   **CI/CD**: Created `.github/workflows/flutter_ci.yml` (Analyze + Test).
*   **Docs**: Finalized `README.md` and `PROJECT_HANDOVER.md`.
*   **Release**: Verified `flutter build apk --release` (v1.0.0-beta).

---

## 4. Feature Intelligence

### 4.1 The Roulette Algorithm
Located in `RouletteService`, the selection logic is **weighted**:
1.  **Filter**: Candidates must match the selected `SpotCategory`.
2.  **History Check**: Look back 30 days in `UserVisit` logs.
3.  **Weight Assignment**:
    *   **Recently Visited**: Weight = 1.
    *   **Unvisited / Old**: Weight = 3.
4.  **Selection**: Random pick from the weighted pool.

### 4.2 Map Implementation
*   **Engine**: `flutter_map` using `TileLayer` with CartoDB Dark/Light styles.
*   **Interaction**: Custom `AnimatedMapController` logic for smooth fly-to.
*   **Overlays**: `EmptyStateOverlay` (if no spots match filter) and `ShuffleDeckOverlay` (modal).

### 4.3 Theme System
Uses `VantagePalette` (ThemeExtension) to semanticize colors:
*   `surface`: Card backgrounds.
*   `primaryBackground`: The deep void (#0A0E14).
*   `accent`: The "Toyota Blue" brand color (#0D7ABF).

---

## 5. Replication Guide

To recreate this project from scratch:

1.  **Scaffold**: `flutter create vantage419`.
2.  **Deps**: Copy `pubspec.yaml` dependencies.
3.  **Assets**: Place `spots.json` in `assets/data/`.
4.  **Core**: Copy `lib/core` (Data, Logic, Theme).
5.  **Features**: Copy `lib/features` (UI).
6.  **Config**: Ensure `android/app/build.gradle` has correct CompileSDK (34) and Kotlin (1.9.24).
7.  **Run**: `flutter run`.

---

## 6. Testing & Quality
*   **Run All Tests**: `flutter test`.
*   **Run Integration**: `flutter test integration_test/app_test.dart`.
*   **CI/CD**: Triggers on push to `main` or `production-sprint-*`.

---

**Authorized by Antigravity Agent**
