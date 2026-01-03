<!-- c149afb9-61cb-48c4-89b1-767271ebf69a e1b0c9be-3456-4621-9807-9f547c483e94 -->
# Frontend Design & UI Implementation Plan

## Design System

### Color Palette

- **Primary Color:** `#2e3d77` (Deep Navy Blue)
  - Primary: `#2e3d77` - Main actions, app bars, primary buttons
  - Primary Light: `#5a6ba3` - Hover states, secondary elements
  - Primary Dark: `#1a2554` - Pressed states, dark variants
- **Secondary Colors:**
  - Success/Go: `#4CAF50` - Route start, success messages
  - Warning: `#FF9800` - Important alerts
  - Error: `#F44336` - Error messages, critical alerts
  - Info: `#2196F3` - Information messages
- **Neutral Colors:**
  - Background: `#FFFFFF` (Light mode), `#121212` (Dark mode support)
  - Surface: `#F5F5F5` - Card backgrounds, elevated surfaces
  - Text Primary: `#212121` - Main text content
  - Text Secondary: `#757575` - Secondary text, hints
  - Divider: `#E0E0E0` - Borders, separators
- **Building Type Colors (Map Polygons):**
  - Academic: `#2e3d77` (Primary) with 40% opacity
  - Administrative: `#D32F2F` (Red) with 40% opacity
  - Residential: `#388E3C` (Green) with 40% opacity
  - Recreation/Dining: `#F57C00` (Orange) with 40% opacity
  - Medical: `#C2185B` (Pink) with 40% opacity
  - Religious: `#7B1FA2` (Purple) with 40% opacity
  - Facilities: `#616161` (Gray) with 40% opacity

### Typography

- **Font Family:** Roboto (Material Design default)
- **Headings:**
  - H1 (App Title): 28sp, Bold, Primary color
  - H2 (Screen Titles): 24sp, Semi-bold, Primary color
  - H3 (Section Headers): 20sp, Medium, Text primary
- **Body Text:**
  - Body Large: 16sp, Regular, Text primary
  - Body Medium: 14sp, Regular, Text primary (minimum readable size)
  - Body Small: 12sp, Regular, Text secondary
- **Special:**
  - Button Text: 14sp, Medium, White (on primary buttons)
  - Navigation Instructions: 16sp, Medium, Text primary
  - Building Names: 14sp, Medium, Text primary

### Spacing & Layout

- **Padding/Margin Scale:** 4dp, 8dp, 12dp, 16dp, 24dp, 32dp
- **Screen Padding:** 16dp horizontal, 8dp vertical
- **Card Padding:** 16dp all sides
- **Button Height:** 48dp (minimum touch target)
- **Icon Size:** 24dp (standard), 32dp (large), 48dp (extra large)
- **Border Radius:** 8dp (cards), 4dp (buttons), 24dp (fab)

### Component Library

#### Buttons

- **Primary Button:** Background `#2e3d77`, White text, 48dp height, 8dp border radius
- **Secondary Button:** Outlined, `#2e3d77` border, `#2e3d77` text
- **Text Button:** No background, `#2e3d77` text
- **FAB:** Circular, `#2e3d77` background, White icon, 56dp size

#### Cards

- **Standard Card:** White background, 8dp border radius, 4dp elevation, 16dp padding
- **Building Card:** White background, 8dp border radius, 2dp elevation, 16dp padding, clickable

#### Input Fields

- **Text Field:** Outlined style, `#2e3d77` focus color, 16dp padding
- **Search Bar:** Rounded, `#F5F5F5` background, 12dp border radius, search icon prefix

#### App Bar

- **Standard App Bar:** `#2e3d77` background, White text/icons, 56dp height
- **Transparent App Bar (Map):** Transparent background, `#2e3d77` icons

#### Bottom Sheet

- **Modal Bottom Sheet:** White background, 16dp top padding, rounded top corners (16dp)
- **Persistent Bottom Sheet:** Semi-transparent overlay, 24dp padding

## Screen Specifications

### 1. Splash Screen (`lib/screens/splash_screen.dart`)

**Layout:**

- Full-screen centered content
- App logo/icon (128dp x 128dp) at top center
- App name "Lead City Navigation" below logo (H1 style)
- Subtitle "Campus Navigation System" (Body Medium, Text secondary)
- Loading indicator at bottom (optional)
- Background: White with subtle gradient to `#2e3d77` at bottom (10% opacity)

**Behavior:**

- Auto-navigate to Home Screen after 2-3 seconds
- Smooth fade transition

### 2. Home Screen (`lib/screens/home_screen.dart`)

**Layout:**

- App Bar: "Lead City Navigation" title, `#2e3d77` background
- Body: Centered vertical layout with spacing
  - Welcome message: "Welcome to Lead City University" (H2)
  - Three primary action cards (each 120dp height):

    1. **Find Route Card**

       - Icon: `Icons.route` (48dp, `#2e3d77`)
       - Title: "Find Route" (H3)
       - Subtitle: "Navigate between buildings" (Body Small)
       - Background: White card with elevation

    1. **View Map Card**

       - Icon: `Icons.map` (48dp, `#2e3d77`)
       - Title: "View Map" (H3)
       - Subtitle: "Explore campus buildings" (Body Small)
       - Background: White card with elevation

    1. **School Infrastructure Card**

       - Icon: `Icons.business` (48dp, `#2e3d77`)
       - Title: "School Infrastructure" (H3)
       - Subtitle: "Browse all buildings" (Body Small)
       - Background: White card with elevation
- Bottom spacing: 32dp

**Interaction:**

- Cards are tappable with ripple effect
- Navigate to respective screens on tap

### 3. Find Route Screen (`lib/screens/find_route_screen.dart`)

**Layout:**

- App Bar: "Find Route" title, back button, `#2e3d77` background
- Body: Scrollable column
  - **Start Location Section:**
    - Label: "From" (Body Medium, Text secondary)
    - Search field with `Icons.location_on` prefix
    - Autocomplete suggestions appear below
  - **Destination Section:**
    - Label: "To" (Body Medium, Text secondary)
    - Search field with `Icons.place` prefix
    - Autocomplete suggestions appear below
  - **Route Preview Card** (appears after route calculation):
    - Distance: "X.X km" (H3, Primary color)
    - Estimated Time: "XX min walk" (Body Medium)
    - Route summary (optional)
    - "Start Navigation" button (Primary button, full width)
  - **Current Location Button:**
    - FAB at bottom right: `Icons.my_location` (uses current GPS)

**Interaction:**

- Autocomplete shows filtered building list as user types
- Selecting start/destination updates fields
- Calculate route on destination selection
- Show route preview on map (embedded or full-screen)
- Start Navigation button navigates to Navigation Screen

### 4. Interactive Map Screen (`lib/screens/map_screen.dart`)

**Layout:**

- Full-screen Google Maps widget
- **Top Overlay:**
  - Search bar (transparent background, rounded)
  - Filter toggle button (optional): Show/Hide buildings
- **Building Polygons:**
  - Overlaid on map with type-specific colors
  - Semi-transparent fill (40% opacity)
  - Dark border (2dp, matching color)
- **User Location Marker:**
  - Blue dot with pulsing animation
  - Accuracy circle (light blue, 20% opacity)
- **Bottom Sheet (on building tap):**
  - Building name (H3)
  - Building type (Body Medium, colored badge)
  - "Get Directions" button (Primary button)
  - "Close" button (Text button)

**Interaction:**

- Tap building polygon to show info bottom sheet
- Long press building for quick actions (optional)
- Search bar filters and highlights buildings
- Toggle button shows/hides building polygons

### 5. Building List Screen (`lib/screens/building_list_screen.dart`)

**Layout:**

- App Bar: "School Infrastructure" title, search icon, `#2e3d77` background
- **Search Bar:**
  - Prominent search field at top
  - `Icons.search` prefix
  - Clear button when text entered
- **Building List:**
  - Scrollable list of building cards
  - Each card contains:
    - Building icon (left, 40dp, type-specific color)
    - Building name (H3, left)
    - Building type badge (right, colored chip)
    - Divider at bottom
  - Empty state: "No buildings found" when search yields no results

**Interaction:**

- Search filters list in real-time
- Tap building card to show Building Details bottom sheet
- Swipe actions (optional): Quick "Navigate" action

### 6. Building Details Bottom Sheet (`lib/widgets/building_details_sheet.dart`)

**Layout:**

- Modal bottom sheet (slides up from bottom)
- **Header:**
  - Building icon (48dp, type-specific color)
  - Building name (H2)
  - Building type (Body Medium, colored badge)
- **Content:**
  - Description section (if available)
  - Coordinates (optional, Body Small)
- **Actions:**
  - "Get Directions" button (Primary, full width)
  - "Close" button (Text button, centered)

### 7. Route Preview Screen (`lib/screens/route_preview_screen.dart`)

**Layout:**

- App Bar: "Route Preview" title, back button, `#2e3d77` background
- **Map Section:**
  - Full-width map showing route polyline
  - Start marker (green, `Icons.location_on`)
  - Destination marker (red, `Icons.place`)
  - Route polyline (blue, `#2e3d77`, 6dp width)
- **Route Info Card (bottom overlay):**
  - Start location name (Body Medium)
  - Destination name (Body Medium)
  - Distance: "X.X km" (H2, Primary color)
  - Estimated time: "XX minutes" (Body Large)
  - "Start Navigation" button (Primary, full width)
  - "Cancel" button (Text button)

### 8. Navigation Screen (`lib/screens/navigation_screen.dart`)

**Layout:**

- Full-screen map with navigation overlay
- **Top Overlay:**
  - Current instruction card (white, rounded, 16dp padding):
    - Instruction text: "Turn left in 50 meters" (H3)
    - Distance to next turn (Body Large, Primary color)
    - Street name (Body Small, Text secondary)
  - Mute/Unmute button (top right, icon button)
- **Map:**
  - Route polyline (blue, `#2e3d77`, 8dp width)
  - User location marker (animated, blue dot)
  - Next turn marker (yellow, `Icons.navigation`)
  - Destination marker (red, `Icons.place`)
- **Bottom Overlay:**
  - Route summary card (collapsible):
    - Remaining distance (H3, Primary color)
    - Remaining time (Body Large)
    - ETA (Body Small)
  - "End Navigation" button (Primary, full width, red variant on long press)

**Interaction:**

- Real-time location updates
- Voice guidance announcements
- Mute/unmute toggles voice
- End Navigation returns to Home Screen
- Arrival notification: Dialog "You have arrived at [Building Name]"

### 9. Error States

**Network Error:**

- Full-screen centered message
- Icon: `Icons.wifi_off` (64dp, Text secondary)
- Message: "No internet connection" (H3)
- Subtitle: "Please check your network" (Body Medium)
- Retry button (Primary)

**GPS Error:**

- Full-screen centered message
- Icon: `Icons.gps_off` (64dp, Text secondary)
- Message: "GPS unavailable" (H3)
- Subtitle: "Please move to an open area" (Body Medium)
- Retry button (Primary)

**Route Error:**

- Inline error message below route fields
- Icon: `Icons.error_outline` (24dp, Error color)
- Message: "Unable to calculate route" (Body Medium, Error color)
- Suggestion: "Please try different locations" (Body Small)

## Navigation Flow

```
Splash Screen (2-3s)
    ↓
Home Screen
    ├─→ Find Route Screen
    │     ├─→ Route Preview Screen
    │     │     └─→ Navigation Screen
    │     └─→ (Direct to Navigation if route exists)
    │
    ├─→ Map Screen
    │     └─→ Building Details Sheet
    │           └─→ Find Route Screen (pre-filled)
    │
    └─→ Building List Screen
          └─→ Building Details Sheet
                └─→ Find Route Screen (pre-filled)
```

## Implementation Structure

```
lib/
├── main.dart
├── app.dart (MaterialApp configuration)
├── theme/
│   ├── app_theme.dart (ThemeData with #2e3d77)
│   └── app_colors.dart (Color constants)
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── find_route_screen.dart
│   ├── map_screen.dart
│   ├── building_list_screen.dart
│   ├── route_preview_screen.dart
│   └── navigation_screen.dart
├── widgets/
│   ├── building_card.dart
│   ├── building_details_sheet.dart
│   ├── route_info_card.dart
│   ├── navigation_instruction_card.dart
│   ├── search_field.dart
│   └── error_widget.dart
├── models/
│   └── building.dart (Building data model)
└── services/
    ├── navigation_service.dart
    ├── location_service.dart
    └── voice_service.dart
```

## Material Design 3 Integration

- Use Material 3 components (MaterialApp with `useMaterial3: true`)
- Implement dynamic color theming with `#2e3d77` as seed color
- Use Material 3 elevation system (0, 1, 2, 3, 4, 5)
- Implement Material 3 shape system (rounded corners, chips)
- Use Material 3 typography scale
- Support Material 3 animations and transitions

## Accessibility Considerations

- Minimum touch target: 48dp x 48dp
- Text contrast ratio: 4.5:1 minimum
- Screen reader support: Semantic labels on all interactive elements
- High contrast mode support (optional for MVP)
- Font scaling support (respects system font size)

## Performance Optimizations

- Lazy load building polygons on map
- Cache building list data
- Debounce search input (300ms)
- Optimize map rendering (limit visible polygons)
- Use const constructors where possible
- Implement image caching for icons

### To-dos

- [ ] Create app theme configuration with #2e3d77 as primary color, including color palette, typography, and Material 3 theme setup in lib/theme/app_theme.dart and lib/theme/app_colors.dart
- [ ] Implement Splash Screen with app logo, name, and auto-navigation to Home Screen after 2-3 seconds in lib/screens/splash_screen.dart
- [ ] Create Home Screen with three primary action cards (Find Route, View Map, School Infrastructure) with icons and navigation in lib/screens/home_screen.dart
- [ ] Create Building data model class with name, type, coordinates, and polygon data in lib/models/building.dart
- [ ] Create reusable BuildingCard widget component with building icon, name, type badge, and tap handling in lib/widgets/building_card.dart
- [ ] Create reusable SearchField widget with autocomplete functionality, search icon, and clear button in lib/widgets/search_field.dart
- [ ] Implement Building List Screen with searchable list of all 42 buildings, search bar, and building cards in lib/screens/building_list_screen.dart
- [ ] Create Building Details bottom sheet widget showing building information and Get Directions button in lib/widgets/building_details_sheet.dart
- [ ] Implement Interactive Map Screen with Google Maps, building polygons (type-colored), user location, and building tap interactions in lib/screens/map_screen.dart
- [ ] Create Find Route Screen with start/destination autocomplete fields, route calculation, and route preview card in lib/screens/find_route_screen.dart
- [ ] Implement Route Preview Screen showing route on map with distance, time, and Start Navigation button in lib/screens/route_preview_screen.dart
- [ ] Create Navigation Screen with real-time map, turn-by-turn instructions card, mute/unmute button, route summary, and End Navigation button in lib/screens/navigation_screen.dart
- [ ] Create error state widgets for network errors, GPS errors, and route errors with retry functionality in lib/widgets/error_widget.dart
- [ ] Implement Navigation Service for route calculation, turn-by-turn directions, and route management in lib/services/navigation_service.dart
- [ ] Create Location Service for GPS tracking, user location updates, and location permissions in lib/services/location_service.dart
- [ ] Implement Voice Service for text-to-speech navigation instructions with mute/unmute functionality using flutter_tts in lib/services/voice_service.dart
- [ ] Set up app navigation structure with routes, navigation transitions, and deep linking in lib/app.dart and update main.dart
- [ ] Integrate campus building data (42 buildings) from KML/JSON format into the app, including polygon coordinates and entrance points
- [ ] Implement building polygon rendering on map with type-specific colors, opacity, borders, and click detection in map_screen.dart
- [ ] Apply final UI polish: animations, transitions, loading states, empty states, and ensure all screens follow design system consistently