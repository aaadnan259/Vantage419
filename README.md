# Vantage 419 [![Flutter CI](https://github.com/aaadnan259/Vantage419/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/aaadnan259/Vantage419/actions/workflows/flutter_ci.yml)

## Discover Toledo, One Spin at a Time

A local discovery application designed to break the routine. Vantage 419 uses weighted random selection to prioritize spots you haven't visited recently, making exploration feel like a game. 

Features a dual-theme design system (YummiBite & Midnight) optimized for mobile.

---

## 🚀 Quick Start

Ensure you have Flutter 3.10+ installed.

```bash
# 1. Clone
git clone https://github.com/aaadnan259/Vantage419.git
cd Vantage419

# 2. Setup
flutter pub get
dart run flutter_launcher_icons

# 3. Run
flutter run
```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev) `2.6.1`
- **Maps**: [flutter_map](https://pub.dev/packages/flutter_map) `8.2.2` with CartoDB tiles
- **Network**: `cached_network_image`
- **Persistence**: `shared_preferences`
- **Design**: Google Fonts (Playfair Display, Inter)

---

## 📂 Project Structure

- `lib/core/` — Services, Models, Repositories, Theme
- `lib/features/` — Feature-based modules (Map, Roulette)
- `assets/data/` — JSON data sources
- `test/` — Unit and Widget tests

---

## 🧪 Testing

Run the full test suite (33 tests):

```bash
flutter test
```

## 📦 Deployment

Build for Android (Release):

```bash
flutter build apk --release
```

---

## License

MIT License.
