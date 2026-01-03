# Testing Checklist for Lead City Navigation App

## Pre-Testing Setup

### 1. API Key Configuration
- [ ] Add Google Maps API key to `android/local.properties`:
  ```
  GOOGLE_MAPS_API_KEY=your_actual_api_key_here
  ```
  (Copy from `android/local.properties.example` template)

- [ ] Verify API key is set for Directions API in Dart code:
  - Option 1: Set environment variable `GOOGLE_MAPS_API_KEY` before running
  - Option 2: Uncomment and set in `lib/app.dart` `_initializeApiKey()` method
  - Option 3: Implement native method channel (for production)

### 2. Dependencies Check
```bash
flutter pub get
```

### 3. Code Analysis
```bash
flutter analyze
```

## Testing Checklist

### ✅ Core Functionality Tests

#### Splash Screen
- [ ] App launches and shows splash screen
- [ ] App logo and name are displayed
- [ ] Automatically navigates to Home Screen after 2-3 seconds
- [ ] Smooth fade transition

#### Home Screen
- [ ] Three action cards are displayed:
  - [ ] Find Route card
  - [ ] View Map card
  - [ ] School Infrastructure card
- [ ] Cards have correct icons and colors (primary color #2e3d77)
- [ ] Tapping each card navigates to correct screen
- [ ] App bar shows "Lead City Navigation" title

#### Building List Screen
- [ ] Shows all 42 buildings
- [ ] Search bar filters buildings in real-time
- [ ] Empty state shows when no matches found
- [ ] Tapping a building shows Building Details bottom sheet
- [ ] "Get Directions" button in bottom sheet works

#### Map Screen
- [ ] Google Maps displays correctly
- [ ] All 42 building polygons are visible with correct colors
- [ ] Building polygons are clickable
- [ ] Tapping a building shows Building Details bottom sheet
- [ ] Search bar filters and navigates to buildings
- [ ] Toggle buildings button shows/hides polygons
- [ ] User location is displayed (if GPS enabled)

#### Find Route Screen
- [ ] Start and destination fields are displayed
- [ ] Autocomplete suggestions appear when typing
- [ ] Selecting buildings updates fields
- [ ] Route calculation works (requires API key)
- [ ] Route preview card shows distance and time
- [ ] "Start Navigation" button navigates to Route Preview
- [ ] Current location button works (requires GPS permission)

#### Route Preview Screen
- [ ] Map shows route polyline
- [ ] Start and end markers are displayed
- [ ] Route info card shows:
  - [ ] Distance
  - [ ] Estimated time
  - [ ] Start and destination names
- [ ] "Start Navigation" button works
- [ ] "Cancel" button returns to previous screen

#### Navigation Screen
- [ ] Real-time map updates with user location
- [ ] Route polyline is displayed
- [ ] Turn-by-turn instruction card shows current instruction
- [ ] Mute/unmute button toggles voice guidance
- [ ] Route summary shows remaining distance and time
- [ ] "End Navigation" button works
- [ ] Arrival dialog appears when reaching destination
- [ ] Voice guidance announces instructions (if not muted)

### ✅ UI/UX Tests

#### Design System
- [ ] Primary color #2e3d77 is used throughout
- [ ] Material Design 3 components are used
- [ ] Typography follows design system
- [ ] Spacing and padding are consistent
- [ ] Buttons have correct heights (48dp minimum)
- [ ] Cards have proper elevation and border radius

#### Error Handling
- [ ] Network error shows appropriate message
- [ ] GPS error shows appropriate message
- [ ] Route calculation error shows inline error
- [ ] Retry buttons work correctly

#### Performance
- [ ] App launches in < 3 seconds
- [ ] Map loads in < 5 seconds
- [ ] Route calculation completes in < 3 seconds
- [ ] UI is smooth (60 FPS)
- [ ] No lag when scrolling lists

### ✅ Bug Fixes Verification

#### Bug 1: API Key Security
- [ ] API key is NOT hardcoded in Dart service
- [ ] API key loads from environment/properties
- [ ] AndroidManifest uses placeholder (not hardcoded)

#### Bug 2: getBuildingById Return Type
- [ ] Returns null when building not found (no exception)
- [ ] Null checks work correctly in map_screen.dart

#### Bug 3: Empty Polyline Handling
- [ ] Empty route doesn't crash app
- [ ] Default bounds are used when polyline is empty

#### Bug 4: Voice Service Async Calls
- [ ] Mute/unmute works without blocking
- [ ] Dispose doesn't cause errors
- [ ] Voice stops correctly when muted

## Running Tests

### Build for Testing
```bash
# Android Debug
flutter build apk --debug

# Android Release (requires signing)
flutter build apk --release
```

### Run on Device/Emulator
```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device_id>
```

### Run Automated Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test
```

## Known Requirements

1. **Internet Connection**: Required for Google Maps and Directions API
2. **GPS Permissions**: Required for location services
3. **Google Maps API Key**: Must be configured (see API_KEY_SETUP.md)
4. **Android 5.0+**: Minimum SDK version

## Troubleshooting

### Maps not displaying
- Check API key in `local.properties`
- Verify Maps SDK is enabled in Google Cloud Console
- Check internet connection

### Route calculation failing
- Verify Directions API key is set
- Check Directions API is enabled
- Review API quota limits

### Build errors
- Run `flutter clean` then `flutter pub get`
- Check `local.properties` exists
- Verify all dependencies are installed

### GPS not working
- Check location permissions in device settings
- Ensure GPS is enabled on device
- Test in outdoor/open area



