# Vantage 419

## Discover Toledo, One Spin at a Time

A local discovery application designed to break the routine of visiting the same three places. Vantage 419 uses a weighted random selection engine to prioritize spots you haven't visited recently, making exploration feel like a game. The application supports both Light and Dark modes with a focus on premium aesthetics and smooth animations.

---

## Philosophy

Toledo has incredible spots, but habit is a powerful force. We tend to gravitate toward the familiar. Vantage 419 was built to nudge you out of that comfort zone. By tracking your visit history and applying a 3x weight to unvisited locations, the algorithm actively works to diversify your experiences. It is not just about finding a place to eat; it is about rediscovering your city.

---

## Design System

The application features a sophisticated dual-theme system designed to feel native and premium.

### YummiBite (Light Mode)
A warm, inviting palette inspired by high-end food editorials.
- **Background:** Cream
- **Primary:** Forest Green
- **Accent:** Fresh Lime
- **Typography:** Playfair Display for headers, Inter for body text.

### Midnight (Dark Mode)
A rich, immersive evening aesthetic optimized for OLED screens.
- **Background:** Deep Green
- **Accent:** Gold

---

## Mechanics

### The Roulette Engine
The core of the application is the Roulette Service. It filters spots by your selected mood (Hungry, Active, Surprise Me) and then applies a weighted random selection. If a spot has not been visited in the last 30 days, it is three times more likely to be selected than a recently visited one.

### Interaction
- **Search Pill:** A modern floating control element anchored at the bottom of the map.
- **Shuffle Deck:** A card-stack animation that builds anticipation before revealing your destination.
- **Smart Markers:** Custom map markers that scale interactively and indicate the category of the spot.

---

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Riverpod
- **Maps:** flutter_map with CartoDB Voyager tiles
- **Persistence:** shared_preferences
- **Typography:** Google Fonts

---

## Quick Start

ensure you have the Flutter SDK installed and configured.

```bash
# Clone the repository
git clone https://github.com/aaadnan259/Vantage419.git
cd Vantage419

# Install dependencies
flutter pub get

# Run the application
flutter run
```

---

## License

MIT License.
