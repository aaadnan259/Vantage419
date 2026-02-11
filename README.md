# 🎰 Vantage 419

**Discover Toledo, One Spin at a Time**

A gamified local discovery app for Toledo, Ohio. Spin the roulette to find your next spot — whether you're hungry, feeling active, or just want a surprise. Built with Flutter, supporting both Light and Dark modes, and designed to make exploring your city feel like a game.

---

## Table of Contents

- [Why Vantage 419](#why-vantage-419)
- [Features](#features)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Tech Stack](#tech-stack)
- [Configuration](#configuration)
- [Testing](#testing)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

---

## Why Vantage 419

Toledo has great spots, but people keep going to the same three places. Vantage 419 fixes that with a weighted random selection engine that prioritizes places you haven't visited recently. The more you explore, the better the recommendations get.

---

## Features

- **Roulette Discovery** — Spin to find a random spot filtered by mood (Hungry, Active, Surprise Me)
- **Weighted Selection** — Unvisited spots get 3× probability. The algorithm nudges you toward variety.
- **Dynamic Theming** — Toggle between **Light** (Toyota Blue/Off-white) and **Dark** (OLED-optimized) modes.
- **Theme Persistence** — Remembers your preference (System, Light, Dark) automatically.
- **Animated UI** — Smooth camera fly-to animations, bouncing markers, and rotary spin physics.
- **Share Spots** — Send spot details + Google Maps link to friends via native share sheet.
- **Visit History** — Locally persisted with auto-pruning (500 cap, 60-day TTL).
- **First-Launch Onboarding** — "Tap to discover!" tooltip to guide new users.

---

## Quick Start

```bash
# Clone
git clone https://github.com/aaadnan259/Vantage419.git
cd Vantage419

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

> **Requirements:** Flutter SDK `^3.10.8`, Dart 3.x, Android Studio or Xcode for emulators.

---

## Architecture

```
Feature-Sliced Architecture + Riverpod State Management
```

The app follows a clean separation of concerns:

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **Models** | Data structures, enums, serialization | `ToledoSpot`, `SpotCategory`, `RouletteMode` |
| **Services** | Business logic, persistence, external APIs | `RouletteService`, `LocationService`, `NavigationService` |
| **Providers** | Riverpod state containers | `rouletteProvider`, `themeProvider`, `userLocationProvider` |
| **Widgets** | UI components, scoped to their feature | `SpinButton`, `SpotBottomSheet`, `ThemeToggle` |
| **Theme** | Colors, typography, semantic palette | `VantageTheme`, `VantagePalette` |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, splash → map
├── core/
├── core.dart                      # Barrel export for all core modules
│   ├── models/
│   │   ├── roulette_mode.dart         # Mode definitions
│   │   ├── spot_category.dart         # Category enum with color/icon
│   │   ├── toledo_spot.dart           # Spot model
│   │   └── user_visit.dart            # Visit tracking model
│   ├── services/
│   │   ├── location_service.dart      # Geolocator wrapper
│   │   ├── navigation_service.dart    # Maps launcher
│   │   └── roulette_service.dart      # Selection engine
│   ├── theme/
│   │   ├── palette.dart               # ThemeExtension (Semantic Colors)
│   │   ├── theme_provider.dart        # Theme mode state & persistence
│   │   ├── typography.dart            # Space Grotesk + Inter type system
│   │   └── vantage_theme.dart         # Material 3 Factories (Light/Dark)
│   └── utils/
│       ├── constants.dart             # Config constants
│       └── extensions.dart            # context.colors extension
├── data/
│   └── toledo_spots.dart              # Static spot dataset (10 locations)
└── features/
    ├── map/
    │   ├── map_screen.dart            # Main screen
    │   ├── providers/
    │   │   ├── map_controller_provider.dart
    │   │   └── user_location_provider.dart
    │   └── widgets/
    │       ├── custom_marker.dart      # Animated markers
    │       ├── empty_state.dart        # "No spots" overlay
    │       ├── map_controls.dart       # Error banners
    │       ├── map_layer.dart          # Marker layer
    │       └── user_location_marker.dart
    ├── roulette/
    │   ├── providers/
    │   │   ├── roulette_state_provider.dart
    │   │   └── selected_spot_provider.dart
    │   └── widgets/
    │       ├── category_selector.dart  # Mode chips
    │       ├── spin_button.dart        # Roulette button
    │       └── spot_bottom_sheet.dart  # Spot details
    ├── settings/
    │   └── widgets/
    │       └── theme_toggle.dart       # Light/Dark toggle button
    └── splash/
        └── splash_screen.dart          # Branded splash
```

---

## How It Works

### The Roulette Engine

The core algorithm lives in `RouletteService.spin()`:

```dart
// Weighted random selection — unvisited spots get 3× probability
ToledoSpot? spin({
  required List<ToledoSpot> spots,
  required List<SpotCategory> categories,
  required List<UserVisit> visits,
}) {
  final pool = spots.where((s) => categories.contains(s.category)).toList();
  if (pool.isEmpty) return null;

  // Spots not visited in the last 30 days get triple weight
  final weighted = <ToledoSpot>[];
  for (final spot in pool) {
    final weight = recentVisitIds.contains(spot.id) ? 1 : 3;
    for (var i = 0; i < weight; i++) {
      weighted.add(spot);
    }
  }

  return weighted[_rng.nextInt(weighted.length)];
}
```

### Modes

| Mode | Categories | Color |
|------|-----------|-------|
| 🍜 Hungry | Dining, Café | Red |
| 🏃 Active | Recreation, Fitness | Teal |
| 🎰 Surprise Me | All | Yellow |

---

## Tech Stack

| Dependency | Purpose |
|-----------|---------|
| `flutter_map` | OpenStreetMap-based map rendering |
| `latlong2` | Coordinate model |
| `geolocator` | Device location + permissions |
| `flutter_riverpod` | State management |
| `shared_preferences` | Persistence (Visits + Theme) |
| `google_fonts` | Typography |
| `url_launcher` | External navigation |
| `share_plus` | Native share sheet |

---

## Configuration

All tunable values live in `lib/core/utils/constants.dart`:

| Constant | Default | Purpose |
|----------|---------|---------|
| `toledoCenter` | `41.6528, -83.5379` | Map initial center |
| `defaultZoom` | `13.0` | Map initial zoom level |
| `spinDuration` | `1000ms` | Roulette spin animation length |
| `cameraDuration` | `1200ms` | Map fly-to animation length |
| `unvisitedWeight` | `3` | Probability multiplier for unvisited spots |

---

## Testing

```bash
# Run all tests
flutter test

# Static analysis
flutter analyze
```

Tests cover roulette logic, model validation, and provider state.

---

---

## Documentation

Comprehensive guides for developers and release managers:

- **[Store Listing & Assets](docs/STORE_LISTING.md)** — App metadata, descriptions, and screenshot checklist.
- **[Build Instructions](docs/BUILD_INSTRUCTIONS.md)** — Guide to signing, building, and obfuscating release APKs.
- **[Privacy Policy](docs/PRIVACY_POLICY.md)** — Location data usage and privacy details.
- **[Terms of Service](docs/TERMS_OF_SERVICE.md)** — Standard usage terms.

---

## Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/cool-spot`)
3. Make your changes
4. Run `flutter analyze && flutter test`
5. Open a PR

---

## License

MIT — do whatever you want with it.
