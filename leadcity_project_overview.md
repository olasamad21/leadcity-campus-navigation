# Lead City University Navigation System
## Project Overview Document

**Version:** 2.0  
**Date:** May 16, 2026  
**Project Type:** Final Year Project  
**Institution:** Lead City University, Ibadan, Nigeria  
**Status:** Active development — core routing implemented on-device (campus graph + Dijkstra)

---

## 1. EXECUTIVE SUMMARY

### 1.1 Project Purpose
Development of a GIS-based mobile campus navigation system to assist students, visitors, and staff in navigating the Lead City University campus with turn-by-turn directions and voice guidance.

### 1.2 Problem Statement
- New students struggle to locate buildings and facilities on campus
- Visitors have difficulty finding specific departments and offices
- No centralized digital map of campus infrastructure
- Time wasted asking for directions and getting lost
- Inefficient campus navigation during orientation periods

### 1.3 Proposed Solution
A mobile Android application that provides:
- Interactive campus map with building identification
- Turn-by-turn navigation between campus locations
- Voice-guided directions
- Searchable building directory
- On-device route calculation over a campus walkway graph (no third-party routing API)

---

## 2. PROJECT SCOPE

### 2.1 In Scope (MVP Features)
✅ Interactive Google Maps-based campus map  
✅ 42 campus buildings digitally mapped with polygons  
✅ Building entrance markers for precise navigation  
✅ Turn-by-turn walking directions  
✅ Voice guidance (text-to-speech)  
✅ Building search with autocomplete  
✅ Building information display (name, type)  
✅ Route preview before navigation  
✅ Mute/unmute voice guidance  
✅ Android mobile application  
✅ Custom shortest-path routing (Dijkstra) on a GPS-derived campus path network  
✅ Turn instructions driven by graph edge metadata (proximity-based voice cues during navigation)  

### 2.2 Out of Scope (Future Enhancements)
❌ iOS application (Phase 2)  
❌ Detailed building floor plans  
❌ Real-time user location tracking history  
❌ Offline map functionality  
❌ User accounts and profiles  
❌ Building operating hours  
❌ Accessibility features for disabled users  
❌ Indoor navigation  
❌ Parking availability  
❌ Event notifications  

### 2.3 Constraints
- Internet connectivity typically required for Google Maps base tiles (standard SDK behaviour); **route solving itself does not call external routing APIs**
- GPS-enabled Android device required for live navigation and snapping to the graph
- Minimum Android API Level 21 (Android 5.0)
- Outdoor navigation only (GPS signal required for reliable live positioning)
- Google Maps SDK usage remains subject to platform quotas (map display only — **not** Directions/Places)

---

## 3. SYSTEM ARCHITECTURE

### 3.1 Technology Stack

**Frontend:**
- **Framework:** Flutter 3.38.5
- **Language:** Dart
- **UI Components:** Material Design 3

**Backend/Services:**
- **Maps:** Google Maps SDK for Android (`google_maps_flutter`) — base map, polygons, markers, polylines
- **Routing:** **On-device custom engine** — weighted campus graph + **Dijkstra shortest paths** (`CampusRoutingService`), orchestrated by `NavigationService` (no Directions HTTP API)
- **Search:** **Local** building directory — autocomplete over KML-loaded / fallback building lists (no Places API)
- **Geolocation:** Device GPS via **`geolocator`** (no Google Geolocation API)
- **Voice:** Flutter Text-to-Speech (`flutter_tts`); proximity-triggered cues via `VoiceNavigationController`

**Development Tools:**
- **IDE:** Visual Studio Code / Android Studio
- **Version Control:** Git + GitHub
- **Build System:** Gradle
- **Package Manager:** Flutter pub

**Platform:**
- **Target:** Android 5.0+ (API 21+)
- **Package Name:** com.leadcity.leadcity_navigation

### 3.2 System Components

```
┌─────────────────────────────────────────┐
│         Mobile Application              │
│  (Flutter - Android)                    │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐   │
│  │   Presentation Layer            │   │
│  │  - Splash Screen                │   │
│  │  - Home Screen                  │   │
│  │  - Map View                     │   │
│  │  - Navigation Screen            │   │
│  │  - Building List                │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │   Business Logic Layer          │   │
│  │  - NavigationService            │   │
│  │  - CampusRoutingService         │   │
│  │    (Dijkstra on walkway graph)   │   │
│  │  - LocationService (GPS)        │   │
│  │  - VoiceService / VoiceNav      │   │
│  │  - KML parser (buildings)       │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │   Data Layer                    │   │
│  │  - Campus graph (nodes/edges)   │   │
│  │  - Building polygons & entrances│   │
│  │    (KML asset + fallback Dart)  │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
              ↓ Map tiles / SDK (routing local)
┌─────────────────────────────────────────┐
│      External / Platform Services       │
│  - Google Maps SDK (display only)       │
│  - Device GPS + OS location permissions │
└─────────────────────────────────────────┘
```

---

## 4. DATA COLLECTION METHODOLOGY

### 4.1 Approach: Hybrid Remote Sensing

**Method:** Satellite imagery digitization with ground-truthing validation

**Justification:**
- Standard GIS practice used in OpenStreetMap and professional mapping
- High-resolution satellite imagery available via Google Maps
- Efficient resource allocation for MVP development
- Fit-for-purpose accuracy for pedestrian navigation (±5-10m)
- Local campus knowledge enables accurate building identification

### 4.2 Data Collection Process

**Phase 1: Remote Digitization**
1. Google My Maps used for digitization platform
2. Building footprints traced from Google Maps satellite imagery (2024)
3. Building polygons created with 4-8 coordinate points per building
4. Main entrance points marked based on:
   - Building orientation toward main pathways
   - Architectural features (doors, signage)
   - Local campus knowledge
   - Logical accessibility analysis

**Phase 2: Ground-Truthing (Validation)**
- Initial GPS testing conducted to validate satellite imagery accuracy
- Selective on-site GPS measurements confirmed ±5m deviation
- Validates remote sensing methodology for remaining buildings

**Phase 3: Data Export**
- KML (Keyhole Markup Language) format export
- Professional GIS-compatible data structure
- 42 buildings digitized with polygon and entrance coordinates

### 4.3 Data Quality

**Spatial Accuracy:** ±5-10 meters (appropriate for pedestrian wayfinding)  
**Completeness:** 42 campus buildings (100% of major facilities)  
**Timeliness:** Building footprints digitized December 2024; walkway routing graph updated May 2026 (see §4.4)  
**Format:** KML (industry-standard GIS format)

### 4.4 Campus walkway graph (routing network)

**Purpose:** Pedestrian routes follow actual paths on campus, not arbitrary straight lines or commercial road networks.

**Current implementation (codebase):**
- A **CampusGraph** is defined in Dart (`lib/data/campus_graph.dart`): hundreds of **nodes** (GPS points) and **edges** (walkway segments) with **Haversine-derived lengths** in metres.
- Edge records may carry optional **voice instructions** (e.g. turn left/right) used for turn-by-turn and TTS.
- The graph was produced from a **systematic campus GPS walk / trace** (GPX-derived workflow), summarized in-code as **434 nodes**, **424 path edges**, **335 junction connections**, covering **~8.2 km** of captured paths (metadata as of May 2026).

**Routing algorithm:** `CampusRoutingService` runs **Dijkstra's algorithm** on this graph (non-negative edge weights = segment lengths). Start/end building entrances are **snapped to the nearest graph node**, then the shortest path is decoded into a polyline and instruction list for the UI and voice layer.

---

## 5. CAMPUS DATA INVENTORY

### 5.1 Buildings mapped

Building footprints and entrance coordinates are loaded at runtime from the bundled KML asset **`assets/Lead City University Campus Map.kml`** (parsed by `KmlParserService`), with a **hardcoded Dart fallback** if parsing fails. The inventory below reflects the original digitization target (**42 major facilities**); the live app always reflects whatever placemarks are present in the shipped KML.

### 5.2 Buildings list (target inventory — 42)

**Academic Buildings (17):**
1. Library
2. Faculty of Law
3. Faculty of Engineering
4. Faculty of Nursing/Engineering (shared)
5. Faculty of Social Science
6. Faculty of Art
7. Faculty of Environmental Science
8. Faculty of Natural and Applied Science
9. Faculty of Dentistry
10. Department of Computer Science
11. College of Medicine
12. College of Medicine Lecture Hub
13. Law Theatre
14. Lecture Rooms 11-13
15. Lecture Rooms 14-16
16. Adeline Hall
17. Conference Center

**Administrative (2):**
18. Senate Building
19. Radio Station

**Religious (2):**
20. Chapel
21. Mosque

**Medical (1):**
22. Clinic

**Residential (3):**
23. Champions Hostel
24. Wisdom Hostel
25. Independence Hostel

**Recreation & Dining (4):**
26. Tasty Vine (Cafeteria)
27. New Tasty Vine
28. Cresta (Restaurant)
29. Stadium

**Facilities (1):**
30. Car Park

**Note:** Each building includes:
- Polygon coordinates (building footprint)
- Main entrance GPS coordinates
- Building name
- Building type/classification

---

## 6. FUNCTIONAL REQUIREMENTS

### 6.1 User Stories

**US-001: As a new student**  
I want to search for a building by name  
So that I can find where my classes are located

**US-002: As a visitor**  
I want to get turn-by-turn directions to a building  
So that I don't get lost on campus

**US-003: As a staff member**  
I want to see all buildings on an interactive map  
So that I can quickly identify campus facilities

**US-004: As a user navigating**  
I want voice guidance during navigation  
So that I don't have to constantly look at my phone

**US-005: As a user**  
I want to view building information when I click on it  
So that I know what facilities are inside

### 6.2 Core Features

#### Feature 1: Splash Screen
- Display app logo and name
- 2-3 second duration
- Automatic transition to home screen

#### Feature 2: Home Screen
- Clean UI with navigation options
- Buttons: "Find Route", "View Map", "School Infrastructure"
- Easy access to main features

#### Feature 3: Interactive Map View
- Google Maps base layer
- 42 building polygons overlaid as colored shapes
- Clickable buildings show name
- Toggle buildings ON/OFF (optional in MVP)
- Zoom and pan functionality
- User location marker

#### Feature 4: Building Search
- Searchable list of all 42 buildings
- Autocomplete as user types
- Tap building to view on map or navigate

#### Feature 5: Route Finding
- Select start and destination from building list
- Autocomplete input for both fields (local search, no Places API)
- **On-device** shortest path via campus graph + **Dijkstra**
- Display route preview on map (polyline along walkway nodes)
- Show estimated distance and walking time (distance sum on graph; time from assumed walking speed in code)
- "Start Navigation" button
- **No-path handling:** if entrances snap to disconnected components or data gaps exist, the app shows that **no route is available** (must not assume connectivity)

#### Feature 6: Turn-by-Turn Navigation
- **Graph-based** maneuver prompts where edges define voice text; live navigation uses **proximity** to maneuver nodes for staged prompts (e.g. approach vs. "now")
- Visual route on map; user location updates from GPS
- Voice guidance (TTS) via `VoiceNavigationController`
- Mute/unmute toggle
- Arrival notification

#### Feature 7: Building Information
- Building name
- Building type (Academic/Admin/etc.)
- Simplified details in MVP (enhanced post-launch)

---

## 7. NON-FUNCTIONAL REQUIREMENTS

### 7.1 Performance
- App launch time: < 3 seconds
- Map load time: < 5 seconds (network-dependent)
- **Route calculation:** typically **well under 1 second** (in-memory graph search on device)
- Voice guidance delay: < 1 second after proximity thresholds
- Smooth 60 FPS UI rendering

### 7.2 Usability
- Intuitive UI requiring no training
- Clear button labels and icons
- Readable text (minimum 14sp font size)
- High contrast for outdoor visibility
- Simple navigation flow (max 3 taps to any feature)

### 7.3 Reliability
- Map display availability tied to Google Maps SDK / connectivity; **routing logic does not depend on Directions API uptime**
- Graceful error handling when **no graph path** exists between snapped endpoints
- Network connectivity messages where map tiles fail to load
- GPS unavailable warnings

### 7.4 Security
- **Maps SDK API key** injected at build time from `android/local.properties` (`GOOGLE_MAPS_API_KEY`) into the Android manifest — restrict by package / signing certificate in Google Cloud
- No routing API keys required for core pathfinding (graph is embedded in the app)
- No storage of personal user data
- No authentication required (public app)

### 7.5 Compatibility
- Android 5.0+ (API 21+)
- Screen sizes: 4.7" - 6.7" phones
- Portrait orientation primary
- Works on various Android manufacturers

---

## 8. USER INTERFACE DESIGN

### 8.1 Screen Flow

```
Splash Screen (2s)
      ↓
Home Screen
   ├─→ Find Route
   │     ├─→ Select Start Location (Autocomplete)
   │     ├─→ Select Destination (Autocomplete)
   │     ├─→ Route Preview
   │     └─→ Start Navigation
   │           └─→ Live Navigation (Voice + Visual)
   │
   ├─→ View Map
   │     ├─→ Interactive Map with Buildings
   │     ├─→ Click Building → Info Popup
   │     └─→ Toggle Buildings ON/OFF
   │
   └─→ School Infrastructure
         ├─→ Searchable Building List
         ├─→ Tap Building → Building Details
         └─→ "Get Directions" Button
```

### 8.2 Design Principles

**MVP Design Focus:**
- Functionality over visual flair
- Clear, simple, functional layouts
- Standard Material Design components
- High readability
- Minimal learning curve

**Color Scheme (Suggested):**
- Primary: Blue (#2196F3) - navigation/actions
- Secondary: Green (#4CAF50) - success/go
- Academic buildings: Blue polygons
- Admin buildings: Red polygons
- Facilities: Gray polygons

---

## 9. MAP & LOCATION INTEGRATION

### 9.1 Google Maps SDK (display layer only)

**Purpose:** Render the campus base map, building polygons, user marker, and route polyline.

**API key configuration (Android):**
- Key read from `android/local.properties` as `GOOGLE_MAPS_API_KEY` and passed into the manifest via Gradle `manifestPlaceholders` (`android/app/build.gradle.kts`).
- Restrict in Google Cloud Console by Android package **`com.leadcity.leadcity_navigation`** and signing certificate(s).

**Enabled product:**
- **Maps SDK for Android** — map tiles, overlays, camera controls.

**Not used for routing (current codebase):**
- ~~Directions API~~ — replaced by **on-device Dijkstra** over `campusGraph`.
- ~~Places API~~ — building search is **in-app** over parsed KML / local lists.
- ~~Geolocation API~~ — fixes come from **`geolocator`** + OS permissions.

**Quota note:** Usage is driven by **map loads / tile traffic**, not per-route HTTP calls. Monitor Maps Platform billing as usual.

### 9.2 Legacy API key hook (`NavigationService.setApiKey`)

`NavigationService` retains an optional `GOOGLE_MAPS_API_KEY` compile-time flag / `setApiKey` for backwards compatibility with older startup samples; **pathfinding does not consume this key**. Operational Maps rendering relies on the **native Android Maps key** described above.

### 9.3 Automated testing (routing)

Unit tests exercise graph routing and voice-controller behaviour using isolated small graphs — see `test/campus_routing_test.dart`.

### 9.4 Error handling

**Network issues:**
- Map tiles may fail to load without connectivity — surface a clear message and retry where appropriate.

**GPS issues:**
- Prompt user to enable location services / permissions; fall back to selecting buildings manually for preview routes where applicable.

**No route on graph:**
- Treat as a **data / connectivity-of-graph** problem (snapped start/end not connected); display **route unavailable** and avoid silent failure.

**Maps SDK errors:**
- User-readable messaging and logs for debugging (invalid/restricted API key, billing, etc.).

---

## 10. DEVELOPMENT METHODOLOGY

### 10.1 Approach
- **Methodology:** Agile (iterative development)
- **MVP Strategy:** Build core features first, enhance later
- **Testing:** Manual testing with real devices on campus
- **Version Control:** Git with feature branches

### 10.2 Development Phases

**Phase 1: Setup & Data (COMPLETED ✓)**
- Environment configuration
- Google Cloud API setup
- Campus data collection and digitization

**Phase 2: Core map & data (COMPLETED ✓)**
- Flutter app structure, themed UI shell
- Map view with KML-driven buildings
- Location permissions and GPS read (`LocationService`)

**Phase 3: Routing & navigation (COMPLETED ✓ — iterative refinement ongoing)**
- Campus walkway graph data (`campus_graph.dart`)
- **Dijkstra** shortest-path routing (`CampusRoutingService`)
- Route preview, live navigation screen, polyline rendering
- Voice guidance pipeline (`VoiceService`, `VoiceNavigationController`)

**Phase 4: Testing & Refinement (IN PROGRESS)**
- On-campus field testing
- Graph completeness / instruction coverage improvements
- Bug fixes, UX polish, performance passes

**Phase 5: Documentation & Deployment (ONGOING)**
- User manual & technical docs aligned with on-device routing
- Release APK / distribution

---

## 11. PROJECT TIMELINE

### 11.1 Milestones

| Milestone | Target / as of | Status |
|-----------|------------------|--------|
| Environment Setup | Dec 2024 | ✅ Complete |
| Maps SDK key & Android build pipeline | Dec 2024 – 2025 | ✅ Complete |
| Campus building KML digitization | Dec 2024 | ✅ Complete |
| Walkway graph capture & graph integration | May 2026 | ✅ Complete |
| Custom Dijkstra routing & route preview | May 2026 | ✅ Complete |
| Live navigation + voice cues | May 2026 | ✅ Complete (tuning ongoing) |
| Field validation & edge-case handling | 2026 | 🔄 In Progress |
| Documentation / thesis chapters sync | 2026 | 🔄 In Progress |
| Final APK & defense | Per academic calendar | ⏳ Scheduled |

### 11.2 Estimated Effort

Initial MVP scaffolding was on the order of **days–weeks**; the **custom graph + routing layer** is a substantial additional engineering and data-collection effort (GPS tracing, graph authoring, instruction QA). Ongoing effort focuses on **accuracy**, **coverage**, and **usability** rather than core algorithm work.

---

## 12. DELIVERABLES

### 12.1 Technical Deliverables
1. ✅ Functional Android APK
2. ✅ Complete source code on GitHub
3. ✅ Campus building data (KML) + parsed in-app models  
4. ✅ **Custom campus routing engine** (walkway graph + Dijkstra) integrated with Maps SDK for display  
5. ✅ README.md with setup instructions  
6. ✅ Technical documentation (keep aligned with routing architecture)

### 12.2 Academic Deliverables
1. ✅ Project report (written document)
2. ✅ System architecture diagrams
3. ✅ User manual
4. ✅ Demo video (2-3 minutes)
5. ✅ Presentation slides
6. ✅ Project defense preparation

### 12.3 Demonstration Materials
1. ✅ Live app demo on Android device
2. ✅ Video walkthrough of features
3. ✅ Campus data visualization
4. ✅ Screenshots of all screens
5. ✅ GitHub repository link

---

## 13. KNOWN LIMITATIONS (MVP)

### 13.1 Technical Limitations
- **Base map** typically requires network access for Google tiles (no dedicated offline map pack in MVP)
- GPS signal required for dependable live navigation (outdoor use)
- Android-only (no iOS build in current scope)
- **Routes are only as good as the walkway graph:** gaps, missing shortcuts, or disconnected subgraphs yield **no route** or suboptimal paths until data is fixed
- Snap-to-nearest-node behaviour can mis-assign starts/ends if GPS drifts or entrances sit far from the captured network
- Single language (English)

### 13.2 Data Limitations
- Building details remain simplified (names / types in MVP)
- No floor-by-floor indoor navigation
- Entrance coordinates should be validated against real doors over time
- Graph edges must be maintained when campus paths change (construction, barriers)

### 13.3 Functional Limitations
- No user accounts or personalization
- No saved favorite locations
- No offline map caching
- No accessibility features
- No real-time location sharing

---

## 14. FUTURE ENHANCEMENTS (POST-MVP)

### 14.1 Phase 2 Features
- iOS application development
- Offline map functionality
- Building floor plans
- Indoor navigation (Bluetooth beacons)
- Real-time building occupancy
- Event notifications (lectures, seminars)

### 14.2 Phase 3 Features
- User accounts and profiles
- Saved favorite locations
- Location sharing with friends
- Parking space availability
- Campus bus tracking
- Accessibility features (wheelchair routes)

### 14.3 Data Enhancements
- Detailed building descriptions
- Department/office listings
- Operating hours
- Contact information
- Building photos
- Faculty/staff directories

### 14.4 Advanced Features
- Augmented Reality (AR) navigation
- Multi-language support
- Voice commands ("Navigate to library")
- Integration with university information system
- Class schedule integration
- Emergency alert system

---

## 15. RISK MANAGEMENT

### 15.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| ~~Google Directions quota~~ | — | — | **Removed:** routing is local |
| Incomplete / disconnected graph | Medium | High | Field-walk QA; expand edges; clear UX when unroutable |
| GPS accuracy / snap-to-graph errors | Medium | Medium | Entrance pins; future map-matching / smoothing |
| Network connectivity (map tiles) | High | Medium | Explicit errors; consider offline strategies later |
| Device compatibility | Low | Medium | Test min SDK devices |
| Maps SDK billing / key misconfiguration | Low | High | Restrict keys; monitor Cloud console |

### 15.2 Project Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Timeline delays | Medium | Medium | Freeze MVP scope; prioritize graph coverage |
| Data accuracy concerns | Medium | High | Ground-truth walks; supervisor review |
| Scope creep | Medium | High | Defer Phase 2 items |
| Maps API key exposure | Low | High | Keys only in `local.properties`; never commit secrets |

### 15.3 Mitigation Strategies
- Clear MVP scope to avoid feature creep
- Regular **walk-the-campus** validation against the graph
- Monitor **Maps SDK** usage / billing in Google Cloud
- Treat **unroutable pairs** as actionable graph QA tickets (not merely “API failures”)
- Keep documentation and thesis materials aligned with the **on-device routing** design

---

## 16. SUCCESS CRITERIA

### 16.1 Technical Success Metrics
- ✅ App launches without crashes on target devices
- ✅ Map loads and displays campus buildings from KML (target inventory: **42** major facilities)
- ✅ Navigation routes between buildings **whenever the walkway graph contains a path** between snapped entrance nodes
- ✅ Voice guidance functions correctly
- ✅ Search finds buildings accurately
- ✅ App runs smoothly (no lag or freezing)

### 16.2 User Experience Metrics
- ✅ Users can navigate from A to B in < 5 taps
- ✅ Voice guidance is clear and audible
- ✅ Buildings are easily identifiable on map
- ✅ Search returns results in < 1 second
- ✅ No user training required

### 16.3 Academic Success Metrics
- ✅ Demonstrates understanding of GIS concepts
- ✅ Shows proficiency in mobile development
- ✅ Professional-quality documentation
- ✅ Successful project defense
- ✅ Meets all final year project requirements

### 16.4 Acceptance Criteria
**The project is considered successful when:**
1. A student can open the app and navigate from the main gate to any building without prior knowledge
2. The system provides accurate directions to building entrances
3. Voice guidance works without user interaction
4. All buildings exposed by the app’s building list are searchable; routing succeeds subject to graph connectivity
5. System handles errors gracefully

---

## 17. DOCUMENTATION STRUCTURE

### 17.1 Code Documentation
- Inline comments for complex logic
- README.md in repository root
- **Maps SDK key setup** (`local.properties`) and troubleshooting for tile load failures
- **Routing data:** maintaining `campus_graph.dart` / walkway capture workflow

### 17.2 User Documentation
- User manual (PDF)
- Feature descriptions
- Screenshots of all screens
- FAQ section
- Support contact information

### 17.3 Technical Documentation
- System architecture diagram
- Data flow diagrams (**GPS → graph → Dijkstra → polyline / instructions → UI / TTS**)
- Maps SDK integration & security notes
- Building / graph data structures (in-memory models — no server database)
- Deployment guide

### 17.4 Academic Documentation
- Project proposal
- Literature review
- Methodology chapter
- Implementation chapter
- Testing and results
- Conclusion and recommendations

---

## 18. DEPLOYMENT PLAN

### 18.1 Build Configuration
- **Build Type:** Release APK
- **Minimum SDK:** API 21 (Android 5.0)
- **Target SDK:** API 34 (Android 14)
- **Signing:** Debug key for testing, release key for production
- **ProGuard:** Enabled for code obfuscation

### 18.2 Distribution Strategy

**Phase 1: Internal Testing**
- Deploy to 5-10 test users
- Gather feedback
- Fix critical bugs

**Phase 2: Campus Pilot**
- Share APK with student beta testers
- Monitor usage and errors
- Collect user feedback

**Phase 3: Official Release**
- Google Play Store submission (optional)
- Campus-wide announcement
- APK download from university website

### 18.3 Installation Methods
1. **Direct APK Installation**
   - Download APK file
   - Enable "Install from Unknown Sources"
   - Install and run

2. **Google Play Store (Future)**
   - Developer account required
   - App review process (1-3 days)
   - Automatic updates

---

## 19. MAINTENANCE PLAN

### 19.1 Post-Launch Support

**Immediate (First Month):**
- Monitor for crashes and bugs
- Respond to user feedback
- Quick fixes for critical issues

**Ongoing:**
- Update building data as campus changes
- Add new buildings when constructed
- Improve entrance point accuracy based on feedback

### 19.2 Update Strategy

**Minor Updates (Bug Fixes):**
- As needed, when issues discovered
- Version numbering: 1.0.1, 1.0.2, etc.

**Major Updates (New Features):**
- Every 3-6 months
- Version numbering: 1.1.0, 1.2.0, etc.
- Include Phase 2/3 features

### 19.3 Data Maintenance
- Review building data annually
- Update coordinates if buildings are renovated
- Add new campus facilities
- Remove demolished buildings

---

## 20. PROJECT CONTACTS

### 20.1 Development Team
- **Developer:** [Your Name]
- **Institution:** Lead City University
- **Department:** [Your Department]
- **Email:** [Your Email]
- **Project Supervisor:** [Supervisor Name]

### 20.2 Technical Support
- **GitHub Repository:** [To be created]
- **Issue Tracking:** GitHub Issues
- **Documentation:** README.md and Wiki

---

## 21. APPENDICES

### Appendix A: Technology References
- Flutter Documentation: https://docs.flutter.dev
- Google Maps Platform: https://developers.google.com/maps
- Android Development: https://developer.android.com
- Dart Language: https://dart.dev

### Appendix B: Data & routing source files
- Campus buildings KML: `assets/Lead City University Campus Map.kml`
- Parsed building models: `lib/data/buildings_data.dart`, `lib/models/building.dart`, `lib/services/kml_parser_service.dart`
- Walkway graph & routing: `lib/data/campus_graph.dart`, `lib/services/campus_routing_service.dart`, `lib/services/navigation_service.dart`
- Voice navigation: `lib/services/voice_navigation_controller.dart`, `lib/services/voice_service.dart`
- Android Maps key wiring: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`

### Appendix C: Credentials & secrets
- Create **`GOOGLE_MAPS_API_KEY`** in `android/local.properties` (never commit real keys to Git)
- Cloud Console: enable **Maps SDK for Android**; restrict key by package + SHA-1
- No Directions / Places keys required for routing in the current architecture

---

## 22. VERSION HISTORY

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | May 16, 2026 | [Your Name] | Document updated for **on-device Dijkstra routing**, campus walkway graph, local search; Maps SDK scoped to display-only; revised risks & milestones |
| 1.0 | Dec 21, 2024 | [Your Name] | Initial project overview document |

---

## 23. APPROVAL & SIGN-OFF

**Document Status:** Draft / Final  
**Reviewed By:** [Supervisor Name]  
**Approved By:** [Department Head]  
**Date:** _______________

---

**END OF DOCUMENT**

*This document serves as the comprehensive project overview for the Lead City University Campus Navigation System. It should be referenced throughout development and updated as requirements evolve.*