# Project Handoff: Vantage 419

**Version:** 1.0.0 (Release Candidate)
**Date:** February 11, 2026
**Tech Stack:** Flutter (Dart 3), Riverpod 2.x, Flutter Map, Shared Preferences.

---

## 1. Project Overview

**Vantage 419** is a "decision engine" app for local discovery in Toledo, Ohio (area code 419). It gamifies the process of choosing a restaurant or activity using a weighted roulette system.

### The Core Loop
1.  **Select Mode**: User chooses a mood (Hungry, Active, or Surprise).
2.  **Spin**: User taps the roulette button.
3.  **Process**: App filters spots by mode, applies weights (unvisited = 3x, visited = 1x), and selects a winner.
4.  **Reveal**: Camera flies to the spot on the map, bottom sheet opens with details.
5.  **Action**: User can "Navigate" (Google Maps) or "Spin Again".

---

## 2. Technical Architecture

The project enforces a **Feature-Sliced** directory structure to ensure scalability.

### 2.1 Directory Structure (`lib/`)
*   **`core/`**: Shared logic used across features.
    *   `models/`: Immutable data classes (`ToledoSpot`, `UserVisit`).
    *   `services/`: Pure Dart classes handling business logic (`RouletteService`).
    *   `theme/`: Design tokens and logic (`VantageTheme`, `VantagePalette`).
    *   `utils/`: Constants and extensions.
*   **`data/`**: Static datasets (`toledo_spots.dart`).
*   **`features/`**: Independent modules containing UI and state.
    *   `map/`: The OSM map visualization.
    *   `roulette/`: The spin interaction and result display.
    *   `settings/`: Configuration UI (Theme Toggle).
    *   `splash/`: App entry point.

### 2.2 State Management (Riverpod)
We use `flutter_riverpod` for dependency injection and state management.
*   **`rouletteProvider`**: A `StateNotifier` managing the spin state (`Idle` -> `Spinning` -> `Result` -> `Error`).
*   **`themeProvider`**: Manages Light/Dark mode and persists preference to disk.
*   **`userLocationProvider`**: A `StreamProvider` wrapping `Geolocator` updates.
*   **`mapControllerProvider`**: Provides a singleton `MapController` that is disposed automatically when the map unmounts.

---

## 3. Sprint Chronicles (Work Log)

Detailed breakdown of the 9-sprint development lifecycle.

### Sprint 1: Critical Stability (The Foundation)
*   **Context**: The MVP crashed often and leaked memory.
*   **S1.1 Map Leak**: `MapController` was not being disposed. *Fix*: Moved to a Riverpod provider with `ref.onDispose(() => controller.dispose())`.
*   **S1.2 Permissions**: App crashed if user denied location. *Fix*: Added `AsyncValue` error handling in provider and a UI error banner.
*   **S1.3 Spin Lock**: Infinite spinner if no spots matched. *Fix*: Added `try/catch` and "No spots found" error state.
*   **S1.6 Tile Failures**: White screen if OSM failed. *Fix*: Added `errorTileCallback` to `TileLayer` to detect network issues.

### Sprint 2: Core UX (The Feel)
*   **Context**: The app worked but felt "janky".
*   **S2.1 Bottom Sheet**: Replaced custom widget with `DraggableScrollableSheet` for physics-based dragging.
*   **S2.2 Dynamic FAB**: Spin button was covered by the sheet. *Fix*: Used `AnimatedPositioned` to slide the button up when the sheet opens.
*   **S2.4 Marker Animation**: Markers popped in instantly. *Fix*: Added `TweenAnimationBuilder` to scale markers from 0 to 1 on load.
*   **S2.5 Haptics**: Added `HapticFeedback.mediumImpact()` on tap and `heavyImpact()` on result reveal for tactile reward.

### Sprint 3: Logic Integrity (The Brain)
*   **Context**: Data could be corrupted, and randomness was clustered.
*   **S3.1 History Pruning**: Visit history grew forever. *Fix*: `_pruneVisits` limits list to 500 items and removes entries older than 60 days.
*   **S3.5 RNG Quality**: Instantiated `Random()` once per service (static) instead of per-spin to avoid seeding issues.
*   **S3.2 Validation**: Added a startup check to ensure all static spots have unique IDs and valid lat/lng.

### Sprint 4: Refactor (The Cleanup)
*   **Context**: `MapScreen` was 800 lines long.
*   **S4.3 Componentization**: Broke `MapScreen` into `MapLayer`, `MapControls`, `EmptyStateOverlay`.
*   **S4.2 Color Unification**: Moved hardcoded colors to `VantagePalette` (ThemeExtension) to support future theming.

### Sprint 5: Performance (The Speed)
*   **Context**: Frame drops during spinning animation.
*   **S5.2 Memoization**: `filteredSpots` was recomputed every build. *Fix*: Moved filtering logic inside the `build` method but verified it's cheap (list is small). *Better Fix*: Could use `Provider` family.
*   **S5.4 Repaint Boundaries**: The spinning button caused the entire map to repaint. *Fix*: Wrapped `SpinButton` animation in `RepaintBoundary`.

### Sprint 6: Growth (The Hook)
*   **S6.1 Branded Splash**: Replaced default white screen with a fade-in logo animation (`SplashScreen`).
*   **S6.2 Native Share**: Integrated `share_plus` to allow sharing "I found [Spot Name] on Vantage 419!".
*   **S6.4 Onboarding**: Added a tooltip "Tap to discover!" for first-time users (stored in `SharedPreferences`).

### Sprint 7: Theming (The Look)
*   **Context**: Needed Dark Mode for night usage.
*   **S7.1 ThemeExtension**: Created `VantagePalette` to handle semantic colors (e.g., `surface`, `accent`) different from Material defaults.
*   **S7.5 Migration**: Refactored every widget to use `context.colors.primary` instead of `VantageColors.blue`.
*   **S7.3 Persistence**: `ThemeProvider` loads saved preference (`ThemeMode.system` default) on app start.

### Sprint 8: QA (The Verify)
*   **S8.2 Profiling**: Verified no memory leaks (DevTools Memory view). Confirmed release build size is small (~16MB APK).
*   **S8.3 Accessibility**: Ensured all touch targets are 44dp+. Added `Semantics` to `ThemeToggle`. Validated contrast ratios.
*   **S8.1 Integration Tests**: Created `app_test.dart` to simulate "Splash -> Map -> Spin". (Requires configuring Windows driver for full automation).

### Sprint 9: Launch (The Ship)
*   **Docs**: Created `STORE_LISTING.md`, `PRIVACY_POLICY.md`, `BUILD_INSTRUCTIONS.md`.
*   **Build**: Verified `flutter build apk --release` works.

---

## 4. Key Components Detail

### 4.1 `ToledoSpot` Model
```dart
class ToledoSpot {
  final String id;          // Unique: "spot_001"
  final String name;        // Display name
  final double latitude;
  final double longitude;
  final SpotCategory category; // Links to color/icon
  // ...
}
```

### 4.2 `RouletteService` Algorithm
1.  **Filter**: `spots.where(category match)`
2.  **History Check**: Get visits from last 30 days.
3.  **Weight Allocation**:
    *   Visited recently? Add to pool **1 time**.
    *   Not visited? Add to pool **3 times**.
4.  **Select**: `pool[random.nextInt(pool.length)]`.

### 4.3 `VantageTheme`
Uses `ThemeExtension` to bridge the gap between Material 3 and custom design needs.
*   `light()`: Off-white surface, high contrast text.
*   `dark()`: Pure black/grey surface (OLED friendly), desaturated accents to reduce eye strain.

---

## 5. Known Issues & Roadmap

### Known Issues
1.  **Map Rotation**: Rotating the map with two fingers might confuse the "Fly To" animation logic (it resets rotation).
2.  **No Offline Mode**: Map tiles require internet. The app shows a grid if offline.

### Future Roadmap (v1.1)
1.  **Favorites**: Allow users to "Heart" spots to exclude them from logic or view logically.
2.  **Custom Filters**: Filter by "Open Now" or "Price $$".
3.  **Cloud Sync**: Optional Firebase login to save history.
