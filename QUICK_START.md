# Quick Start Testing Guide

## Step 1: Configure API Keys

### For Maps SDK (Android):
Add to `android/local.properties`:
```
GOOGLE_MAPS_API_KEY=AIzaSyBLGPUKURvQPmUDYcRJJkNTLk4N9tbxzHQ
```

### For Directions API (Dart):
Option A - Set in code (temporary for testing):
Edit `lib/app.dart` line 51, uncomment and set:
```dart
NavigationService.setApiKey('AIzaSyBLGPUKURvQPmUDYcRJJkNTLk4N9tbxzHQ');
```

Option B - Set environment variable:
```bash
$env:GOOGLE_MAPS_API_KEY="AIzaSyBLGPUKURvQPmUDYcRJJkNTLk4N9tbxzHQ"
flutter run
```

## Step 2: Run the App

```bash
# Get dependencies
flutter pub get

# Check for issues
flutter analyze

# Run on connected device/emulator
flutter run
```

## Step 3: Test Basic Flow

1. ✅ Splash screen appears → auto-navigates to Home
2. ✅ Home screen shows 3 cards
3. ✅ Tap "View Map" → Map displays with building polygons
4. ✅ Tap "School Infrastructure" → Building list appears
5. ✅ Search for a building → Results filter
6. ✅ Tap "Find Route" → Can select start/destination

## Current Status

✅ **Completed:**
- All screens implemented
- All widgets created
- All services implemented
- Theme system with #2e3d77 primary color
- 42 buildings data integrated
- Bug fixes applied

⚠️ **Needs Configuration:**
- API keys must be set (see above)
- GPS permissions will be requested at runtime
- Internet connection required for maps/routes

## Next Steps

1. Set API keys (see Step 1)
2. Connect Android device or start emulator
3. Run `flutter run`
4. Test navigation flow
5. Verify map displays correctly
6. Test route calculation

For detailed testing, see `TESTING_CHECKLIST.md`



