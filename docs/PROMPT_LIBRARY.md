# Vantage 419 — Prompt Library

Copy-paste prompts for AI coding agents, tailored to this project's architecture, conventions, and domain.

---

## Project Context (include in any prompt)

> **Vantage 419** — Premium discovery tool for Toledo, OH residents. Dark OLED map app with gamified "spin the roulette" to discover local spots.
>
> **Stack:** Flutter 3.x · Riverpod (`StateNotifier` + `Provider`) · `flutter_map` + CartoDB Dark Matter tiles · `geolocator` · `shared_preferences` · `google_fonts`
>
> **Architecture:** Feature-folder with shared core:
> ```
> lib/
> ├── core/
> │   ├── models/       → ToledoSpot, SpotCategory (enum), UserVisit
> │   ├── services/     → RouletteService, LocationService
> │   ├── theme/        → VantageColors, VantageTypography, VantageTheme
> │   └── utils/        → AppConstants, extensions
> ├── data/             → toledo_spots.dart (static spot list)
> └── features/
>     ├── map/          → MapScreen, providers/, widgets/
>     └── roulette/     → providers/, widgets/
> ```
>
> **Conventions:**
> - State management: `flutter_riverpod` — `StateNotifier<T>` + `StateNotifierProvider`
> - Theme: OLED-dark (`VantageColors`, `VantageTheme.dark`), Material 3
> - Models: manual `toJson()` / `fromJson()` factories (no code-gen)
> - Persistence: `SharedPreferences` (injected via `ProviderScope` override)
> - Error handling: custom exception classes (e.g. `LocationServiceException`)
> - Testing: `flutter_test` (no bloc_test, no mockito yet)
> - No Navigator 2.0 / go_router yet — currently single-screen with overlays

---

## Widget & UI Prompts

### 1. Create a Widget with Riverpod State

```xml
<user>
Context: Vantage 419 — gamified Toledo discovery app using Riverpod and OLED-dark theme.
Task: Create a `SpotDetailView` widget that:

- Is a ConsumerWidget reading from an existing Riverpod provider
- Displays loading, error, and data states (use `.when()` pattern)
- Shows spot name, vibeCheck, category icon/color, description, and optional address
- Uses `VantageColors` and `VantageTheme.dark` styling (dark surfaces, light text)
- Is responsive and accessible
- Includes widget test stubs

Project conventions:
- Feature folder: lib/features/spot_detail/
- Subfolder structure: providers/, widgets/
- State management: Riverpod StateNotifier
- Theme: VantageColors (core/theme/colors.dart), Material 3
- Testing: flutter_test
</user>
```

---

### 2. Create an Animated Interactive Widget

```xml
<user>
Context: Vantage 419 — the spin button triggers weighted roulette selection on a dark map.
Task: Create a `PulsingSpinButton` widget that:

- Extends the existing SpinButton in features/roulette/widgets/
- Has a continuous pulsing glow animation when idle (using VantageColors.accent)
- Plays a rotation animation during spin (match AppConstants.spinDuration)
- Disables interaction while `rouletteState.isSpinning` is true
- Uses the existing 80px size from AppConstants.spinButtonSize
- Follows the OLED-dark aesthetic (subtle glow, no harsh whites)

Conventions:
- Widget lives at lib/features/roulette/widgets/spin_button.dart
- Uses ConsumerWidget with ref.watch(rouletteProvider)
- Animations via AnimationController in a ConsumerStatefulWidget
- Colors from VantageColors (core/theme/colors.dart)
</user>
```

---

## Data Layer Prompts

### 3. Generate a Model + Persistence Layer

```xml
<user>
Context: Vantage 419 stores user data locally via SharedPreferences.
Task: Generate:

1. `UserPreferences` model with:
   - favoriteCategories (List<SpotCategory>)
   - visitRadius (double, km)
   - notificationsEnabled (bool)
   - Manual toJson() / fromJson() factories (match existing pattern in core/models/)

2. `UserPreferencesService` that:
   - Reads/writes to SharedPreferences (injected via constructor, same as RouletteService)
   - Provides load/save methods returning the model directly
   - Handles missing/corrupt data gracefully (return defaults)

3. Riverpod wiring:
   - Provider<UserPreferencesService> using ref.read(sharedPreferencesProvider)
   - StateNotifierProvider for `UserPreferencesNotifier` managing state

Place files:
- Model: lib/core/models/user_preferences.dart
- Service: lib/core/services/user_preferences_service.dart
- Provider: lib/features/settings/providers/user_preferences_provider.dart
</user>
```

---

### 4. Add a Remote Data Source (Future Phase)

```xml
<user>
Context: Vantage 419 currently uses hardcoded spot data in data/toledo_spots.dart. 
We want to prepare for Phase 2 where spots come from a backend API.
Task: Generate:

1. `SpotRemoteDataSource` — fetches spots from a REST endpoint
   - GET /spots → List<ToledoSpot>
   - GET /spots/:id → ToledoSpot
   - Uses http package, returns parsed models via existing ToledoSpot.fromJson()

2. `SpotRepository` — coordinates remote + local:
   - Tries remote first, falls back to cached data
   - Caches successful fetches to SharedPreferences
   - Returns custom Result<T> or uses try/catch with custom exceptions

3. Riverpod providers:
   - Provider<SpotRepository>
   - FutureProvider<List<ToledoSpot>> that replaces the current static import

Conventions:
- Place under lib/features/spots/data/ and lib/features/spots/providers/
- Follow existing error pattern (custom exception classes, not Either/dartz)
- Keep the static toledo_spots.dart as the fallback seed data
</user>
```

---

## Feature Development Prompts

### 5. Full Feature Scaffold

```xml
<user>
Context: We are adding a `Favorites` feature to Vantage 419.
Task: Scaffold the feature following our project structure:

lib/features/favorites/
├── providers/
│   └── favorites_provider.dart
└── widgets/
    ├── favorites_page.dart
    └── favorite_spot_card.dart

Generate:
- State class: `FavoritesState` (favoriteSpotIds: List<String>, isLoaded: bool)
- StateNotifier: `FavoritesNotifier` with add/remove/toggle/load methods
- Persistence: SharedPreferences via constructor injection (same pattern as RouletteService)
- Provider: StateNotifierProvider<FavoritesNotifier, FavoritesState>
- UI: `FavoritesPage` using ConsumerWidget with ref.watch
- Card widget: `FavoriteSpotCard` showing spot name, category icon, vibeCheck
- Widget test stubs for FavoritesPage

Conventions:
- State management: Riverpod StateNotifier (not BLoC)
- Theme: VantageColors, VantageTheme.dark, Material 3
- Persistence: SharedPreferences
- Testing: flutter_test
</user>
```

---

### 6. Add a New Roulette Mode

```xml
<user>
Context: Vantage 419 has predefined roulette modes (Hungry, Active, Surprise Me) 
defined in core/utils/constants.dart as RouletteMode.modes.
Task: Add a new roulette mode:

- Name: 'chill'
- Display: 'Chill'
- Categories: [SpotCategory.cafe, SpotCategory.entertainment]
- Color: VantageColors.categoryCafe

Then:
1. Add the mode to RouletteMode.modes list in constants.dart
2. Update CategorySelector widget to render the new mode pill
3. Verify the spin logic in RouletteService works with the new category filter
4. Add a unit test confirming spin() returns only cafe/entertainment spots for this mode

Conventions:
- No changes to the state management pattern
- Colors from VantageColors
- Test under test/features/roulette/
</user>
```

---

## Navigation Prompts

### 7. Add Navigation & Routing

```xml
<user>
Context: Vantage 419 currently uses a single MapScreen with overlay widgets (bottom sheet, 
category selector). We want to add proper navigation for new pages.
Task: Set up routing using go_router:

Routes:
- / → MapScreen (home, existing)
- /favorites → FavoritesPage (new)
- /settings → SettingsPage (new)
- /spot/:id → SpotDetailPage (deep link)

Requirements:
- Wrap app in GoRouter, replace MaterialApp with MaterialApp.router
- Keep existing ProviderScope override for SharedPreferences
- Bottom nav bar with Map, Favorites, Settings tabs
- Preserve dark OLED aesthetic (VantageColors.surface for nav bar)
- Smooth Material 3 page transitions
- Deep link support for spot/:id
- Back button handling on Android

Place router at lib/core/navigation/app_router.dart
</user>
```

---

## Testing Prompts

### 8. Provider / StateNotifier Testing

```xml
<user>
Context: Testing the RouletteNotifier in Vantage 419.
Task: Generate Riverpod provider tests:

- Initial state: currentMode == 0, isSpinning == false, selectedSpot == null, visits == []
- selectMode(1) updates currentMode to 1 and clears selectedSpot
- spin() sets isSpinning to true, then resolves with a ToledoSpot from the filtered pool
- spin() records a UserVisit and updates the visits list
- spin() returns null when pool is empty (no spots match selected categories)

Test setup:
- Create a ProviderContainer with overrides for sharedPreferencesProvider
- Use SharedPreferences.setMockInitialValues({}) for test isolation
- Mock or use real RouletteService (it's pure logic, no network)

Place tests at test/features/roulette/providers/roulette_state_provider_test.dart
Framework: flutter_test (no bloc_test)
</user>
```

---

### 9. Widget Testing

```xml
<user>
Context: Testing the MapScreen in Vantage 419.
Task: Generate widget tests for MapScreen:

- Renders FlutterMap with CartoDB dark tile layer
- Shows CategorySelector with all RouletteMode.modes
- Displays SpinButton at bottom-right
- Tapping SpinButton triggers rouletteProvider.spin()
- When rouletteState.selectedSpot != null, shows SpotBottomSheet
- SpotBottomSheet displays spot.name and spot.vibeCheck

Test setup:
- Wrap in ProviderScope with overrides
- Mock MapController and UserLocationProvider
- Use pumpAndSettle for animations

Place tests at test/features/map/map_screen_test.dart
Framework: flutter_test
</user>
```

---

## Map & Location Prompts

### 10. Add Map Feature

```xml
<user>
Context: Vantage 419 uses flutter_map with CartoDB Dark Matter tiles, centered on Toledo, OH.
Task: Add a "radius filter" to the map:

- Circular overlay showing user's selected discovery radius (default 5km)
- Semi-transparent accent color ring (VantageColors.accent at 0.15 opacity)
- Slider widget to adjust radius (1km–15km), positioned above the SpinButton
- RouletteService.spin() should filter spots within the radius from user location
- Use Haversine formula or latlong2 Distance class for calculation

Requirements:
- CircleLayer on FlutterMap centered on user location
- New provider: `discoveryRadiusProvider` (StateProvider<double>)
- Update spin logic to accept optional maxDistance parameter
- Respect existing dark theme and overlay stacking order
</user>
```

---

## Theme & Design Prompts

### 11. Create a New Themed Component

```xml
<user>
Context: Vantage 419's design system uses VantageColors (OLED-dark) and VantageTheme.dark.
Task: Create a reusable `VantageCard` widget:

- Dark surface background (VantageColors.surface)
- 16px border radius (matches existing CardTheme)
- Subtle elevation shadow
- Optional accent-colored left border strip (category color)
- Slot for title (textPrimary), subtitle (textSecondary), and trailing widget
- Glassmorphism variant with BackdropFilter for overlay contexts
- Smooth scale animation on tap (100ms, 0.97 scale)

Conventions:
- Place at lib/core/widgets/vantage_card.dart
- Use VantageColors exclusively (no hardcoded hex)
- Must work on both surface and primaryBackground
- Include usage examples in doc comments
</user>
```

---

## Usage Notes

- **State management is Riverpod**, not BLoC — use `StateNotifier`, `ConsumerWidget`, `ref.watch/read`
- **Theme is OLED-dark** — always reference `VantageColors` and `VantageTheme.dark`
- **Models use manual JSON** — no `json_serializable` or `freezed` code-gen
- **Persistence is `SharedPreferences`** — injected via `ProviderScope.overrides`
- **Error handling uses custom exceptions** — not `Either<Failure, T>` / dartz
- Adapt any output to match the folder structure: `lib/features/{name}/providers/` and `lib/features/{name}/widgets/`
- Keep this file in `docs/` as a living library — update prompts as the project evolves
