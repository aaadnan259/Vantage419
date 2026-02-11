# User Acceptance Testing (UAT) Checklist

## 1. App Launch
- [ ] **Splash Screen**: Animated logo branding appears.
- [ ] **Permissions**: Location permission dialog appears (if applicable). Denying handles gracefully.
- [ ] **Default State**: Map loads centered on Toledo. "Hungry" mode selected.

## 2. Map Interaction
- [ ] **Panning/Zooming**: Smooth interaction.
- [ ] **Markers**: Tap a marker to see callout/details.
- [ ] **Theme**: Toggling theme updates map tiles (Dark Matter <-> Light) instantly.

## 3. Roulette Feature
- [ ] **Mode Selection**: Changing mode updates category chips and map markers.
- [ ] **Spin**: Tapping spin button triggers rotation animation + haptic feedback.
- [ ] **Result**: Camera flies to selected spot. Bottom sheet opens with details.
- [ ] **History**: Visited spot is not selected again immediately (weighted logic).

## 4. Spot Details
- [ ] **Content**: Name, Vibe Check, Description display correctly.
- [ ] **Actions**:
  - "Share": Opens system share sheet.
  - "Navigate": Opens Google Maps/Waze.

## 5. Edge Cases
- [ ] **No Location**: App works without location (uses default center).
- [ ] **Offline**: Map tiles might fail gracefully (error banner).
- [ ] **No Internet**: Navigation launch handles error.
