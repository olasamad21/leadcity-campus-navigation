# API Key Setup Guide

This guide explains how to securely configure Google Maps API keys for the Lead City Navigation app.

## Security Overview

The app uses two separate Google Maps API keys:
1. **Maps SDK Key** - Used by Android native code for displaying maps (required in AndroidManifest.xml)
2. **Directions API Key** - Used by Dart code for route calculation (loaded at runtime)

## Setting Up API Keys

### Step 1: Get Your API Keys

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable the following APIs:
   - Maps SDK for Android
   - Directions API
4. Create API keys for each service
5. **IMPORTANT**: Restrict each key in Google Cloud Console:
   - Maps SDK Key: Restrict to Android apps with your package name (`com.leadcity.leadcity_navigation`) and SHA-1 certificate fingerprint
   - Directions API Key: Restrict to Directions API only

### Step 2: Configure Maps SDK Key (Android)

The Maps SDK key must be set in one of these locations (in order of priority):

#### Option A: local.properties (Recommended for Development)
1. Copy `android/local.properties.example` to `android/local.properties`
2. Add your key:
   ```
   GOOGLE_MAPS_API_KEY=your_maps_sdk_key_here
   ```
3. `local.properties` is already in `.gitignore` and won't be committed

#### Option B: gradle.properties
Add to `android/gradle.properties`:
```
GOOGLE_MAPS_API_KEY=your_maps_sdk_key_here
```

#### Option C: Environment Variable
Set before building:
```bash
export GOOGLE_MAPS_API_KEY=your_maps_sdk_key_here
```

#### Option D: Build-time Fallback
If none of the above are set, the build will use a development key (not recommended for production).

### Step 3: Configure Directions API Key (Dart)

The Directions API key is loaded at runtime. You have several options:

#### Option A: Native Method Channel (Recommended)
Implement in `android/app/src/main/kotlin/.../MainActivity.kt`:
```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.leadcity.navigation/api_key"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getApiKey") {
                // Read from secure storage, BuildConfig, or resources
                val apiKey = BuildConfig.DIRECTIONS_API_KEY // or from secure storage
                result.success(apiKey)
            } else {
                result.notImplemented()
            }
        }
    }
}
```

#### Option B: Environment Variable
Set before running:
```bash
export GOOGLE_MAPS_API_KEY=your_directions_api_key_here
flutter run
```

#### Option C: Manual Setup
In `lib/app.dart`, uncomment and set:
```dart
NavigationService.setApiKey('your_directions_api_key_here');
```

## Production Checklist

- [ ] Create separate API keys for Maps SDK and Directions API
- [ ] Restrict Maps SDK key to your app's package name and SHA-1
- [ ] Restrict Directions API key to Directions API only
- [ ] Set up build variants with different keys for debug/release
- [ ] Remove any hardcoded keys from source code
- [ ] Use secure storage or native code for Directions API key
- [ ] Test that keys work correctly
- [ ] Monitor API usage in Google Cloud Console

## Troubleshooting

### Maps not displaying
- Verify Maps SDK key is set in `local.properties` or `gradle.properties`
- Check that the key is restricted correctly in Google Cloud Console
- Ensure Maps SDK for Android is enabled in your Google Cloud project

### Route calculation failing
- Verify Directions API key is set via `NavigationService.setApiKey()`
- Check that Directions API is enabled in your Google Cloud project
- Verify the key has Directions API access

### Build errors
- Ensure `local.properties` exists (copy from `local.properties.example`)
- Check that API key property name matches exactly: `GOOGLE_MAPS_API_KEY`

