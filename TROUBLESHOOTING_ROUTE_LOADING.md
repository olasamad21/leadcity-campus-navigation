# Troubleshooting: Route Calculation Stuck Loading

## Problem
The "Find Route" screen shows a loading indicator but never completes the route calculation.

## Root Cause
The **Google Directions API key is not configured**. When you select a start and destination building, the app tries to calculate a route using Google's Directions API, but without an API key, the request fails silently.

## Solution

### Option 1: Set API Key in Code (Quick Test)
1. Open `lib/app.dart`
2. Find line 79 (in the `_initializeApiKey()` method)
3. Uncomment and add your Directions API key:
   ```dart
   NavigationService.setApiKey('YOUR_DIRECTIONS_API_KEY_HERE');
   ```

### Option 2: Set via Environment Variable (Recommended for Development)
Before running the app, set the environment variable:
```bash
# Windows PowerShell
$env:GOOGLE_MAPS_API_KEY="your_directions_api_key_here"
flutter run

# Windows CMD
set GOOGLE_MAPS_API_KEY=your_directions_api_key_here
flutter run

# Linux/Mac
export GOOGLE_MAPS_API_KEY="your_directions_api_key_here"
flutter run
```

### Option 3: Native Method Channel (Production)
Implement the method channel in your Android MainActivity to securely provide the API key.

## How to Get a Directions API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one)
3. Enable the **Directions API**
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Restrict the key to:
   - **API restrictions**: Directions API only
   - **Application restrictions**: None (for testing) or Android apps with your package name

## What Should Happen

Once the API key is configured:
1. Select "From" location (e.g., Library)
2. Select "To" location (e.g., College of Medicine)
3. The app will:
   - Show loading indicator
   - Call Google Directions API
   - Display route preview with distance and time
   - Show "Start Navigation" button

## Error Messages

After the fix, you'll see clear error messages if something goes wrong:
- **"Directions API key not configured"** - API key is missing
- **"Unable to calculate route"** - API call failed (check internet, API key validity)
- **"Error calculating route"** - Other errors (will show details)

## Testing

After setting the API key:
1. Restart the app
2. Go to "Find Route"
3. Select two buildings
4. Route should calculate within 2-3 seconds
5. Route preview card should appear

## Notes

- The **Maps SDK key** (for displaying maps) is different from the **Directions API key** (for route calculation)
- Both keys can be the same, but it's better to use separate keys with different restrictions
- The Directions API key is used for route calculation only
- Make sure Directions API is enabled in Google Cloud Console

