# Lead City University Navigation System
## Project Overview Document

**Version:** 1.0  
**Date:** December 21, 2024  
**Project Type:** Final Year Project  
**Institution:** Lead City University, Ibadan, Nigeria  
**Status:** Development Phase

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
- Real-time route calculation

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
- Internet connectivity required
- GPS-enabled Android device required
- Minimum Android API Level 21 (Android 5.0)
- Outdoor navigation only (GPS signal required)
- Google Maps API free tier limits (sufficient for campus use)

---

## 3. SYSTEM ARCHITECTURE

### 3.1 Technology Stack

**Frontend:**
- **Framework:** Flutter 3.38.5
- **Language:** Dart
- **UI Components:** Material Design 3

**Backend/Services:**
- **Maps:** Google Maps SDK for Android
- **Routing:** Google Directions API
- **Search:** Google Places API
- **Geolocation:** Google Geolocation API
- **Voice:** Flutter Text-to-Speech (flutter_tts)

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
│  │  - Navigation Controller        │   │
│  │  - Location Service             │   │
│  │  - Voice Guidance Service       │   │
│  │  - Search Service               │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │   Data Layer                    │   │
│  │  - Campus Building Data         │   │
│  │  - Building Coordinates         │   │
│  │  - Entrance Points              │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
              ↓ API Calls
┌─────────────────────────────────────────┐
│      External Services                  │
│  - Google Maps SDK                      │
│  - Google Directions API                │
│  - Google Places API                    │
│  - Device GPS                           │
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
**Timeliness:** Data collected December 2024 (current)  
**Format:** KML (industry-standard GIS format)

---

## 5. CAMPUS DATA INVENTORY

### 5.1 Buildings Mapped (42 Total)

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
- Autocomplete input for both fields
- Display route preview on map
- Show estimated distance and walking time
- "Start Navigation" button

#### Feature 6: Turn-by-Turn Navigation
- Real-time directions ("Turn left in 50 meters")
- Visual route on map
- Current location updates
- Voice guidance (TTS)
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
- Map load time: < 5 seconds
- Route calculation: < 3 seconds
- Voice guidance delay: < 1 second
- Smooth 60 FPS UI rendering

### 7.2 Usability
- Intuitive UI requiring no training
- Clear button labels and icons
- Readable text (minimum 14sp font size)
- High contrast for outdoor visibility
- Simple navigation flow (max 3 taps to any feature)

### 7.3 Reliability
- 99% uptime (dependent on Google services)
- Graceful error handling
- Network connectivity error messages
- GPS unavailable warnings

### 7.4 Security
- API key restricted to application package
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

## 9. API INTEGRATION

### 9.1 Google Maps APIs

**API Key:** AIzaSyBLGPUKURvQPmUDYcRJJkNTLk4N9tbxzHQ

**Enabled Services:**
1. **Maps SDK for Android**
   - Displays base map
   - Renders custom polygons
   - Shows user location
   - Free tier: 28,000 map loads/month

2. **Directions API**
   - Calculates walking routes
   - Provides turn-by-turn instructions
   - Free tier: 2,000 requests/month

3. **Places API**
   - Autocomplete for building search
   - Location suggestions
   - Free tier: Adequate for campus use

4. **Geolocation API**
   - Determines user location
   - GPS coordinate processing

**API Restrictions:**
- Restricted to Android apps only
- Package name: com.leadcity.leadcity_navigation
- Maps SDK for Android enabled

**Usage Estimates (Monthly):**
- Expected users: 500-2000 students
- Average sessions: 3-5 per user per month
- Total map loads: ~5,000/month (well within free tier)
- Route calculations: ~1,000/month (within free tier)

### 9.2 Error Handling

**Network Issues:**
- Display: "No internet connection. Please check your network."
- Retry button provided

**GPS Issues:**
- Display: "GPS signal unavailable. Please move to an open area."
- Fallback to manual location selection

**API Errors:**
- Graceful degradation
- User-friendly error messages
- Log errors for debugging

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

**Phase 2: Core Development (IN PROGRESS)**
- App structure setup
- Map view implementation
- Building data integration
- Basic navigation

**Phase 3: Feature Implementation**
- Route finding
- Turn-by-turn navigation
- Voice guidance
- Building search

**Phase 4: Testing & Refinement**
- On-campus testing
- Bug fixes
- UI improvements
- Performance optimization

**Phase 5: Documentation & Deployment**
- User manual
- Technical documentation
- GitHub repository
- Release APK generation

---

## 11. PROJECT TIMELINE

### 11.1 Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Environment Setup | Dec 16-18, 2024 | ✅ Complete |
| Google Cloud API Setup | Dec 21, 2024 | ✅ Complete |
| Campus Data Collection | Dec 21, 2024 | ✅ Complete |
| Code Integration | Dec 22, 2024 | 🔄 In Progress |
| Feature Implementation | Dec 23-24, 2024 | ⏳ Pending |
| Testing & Debugging | Dec 25-26, 2024 | ⏳ Pending |
| Documentation | Dec 27-28, 2024 | ⏳ Pending |
| Final Deployment | Dec 29, 2024 | ⏳ Pending |
| Project Defense | Jan 2025 | ⏳ Pending |

### 11.2 Estimated Effort
- **Total Development Time:** 10-12 days
- **Setup & Data:** 3 days (complete)
- **Core Development:** 3-4 days
- **Testing & Polish:** 2-3 days
- **Documentation:** 2 days

---

## 12. DELIVERABLES

### 12.1 Technical Deliverables
1. ✅ Functional Android APK
2. ✅ Complete source code on GitHub
3. ✅ Campus building data (KML format)
4. ✅ Google Maps API integration
5. ✅ README.md with setup instructions
6. ✅ Technical documentation

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
- Requires active internet connection (no offline mode)
- GPS signal required (outdoor use only)
- Android-only (no iOS version)
- No real-time traffic or crowd data
- Single language (English)

### 13.2 Data Limitations
- Building details limited (names only in MVP)
- No floor-by-floor indoor navigation
- Entrance points may need field verification
- No real-time building status (open/closed)

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
| Google API quota exceeded | Low | High | Monitor usage, implement caching |
| GPS accuracy issues | Medium | Medium | Use entrance markers, not building centers |
| Network connectivity problems | High | Medium | Clear error messages, manual location entry |
| Device compatibility issues | Low | Medium | Test on multiple devices, min API 21 |
| Map loading performance | Low | Low | Optimize polygon rendering |

### 15.2 Project Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Timeline delays | Medium | Medium | MVP scope strictly maintained |
| Data accuracy concerns | Low | High | Ground-truthing validation conducted |
| Scope creep | Medium | High | Clear MVP definition, defer enhancements |
| API key security breach | Low | High | Proper restrictions configured |

### 15.3 Mitigation Strategies
- Clear MVP scope to avoid feature creep
- Regular testing on campus
- API usage monitoring
- Backup development plan if APIs fail
- Documentation of all decisions

---

## 16. SUCCESS CRITERIA

### 16.1 Technical Success Metrics
- ✅ App launches without crashes on target devices
- ✅ Map loads and displays all 42 buildings
- ✅ Navigation successfully routes between any two buildings
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
4. All 42 buildings are searchable and navigable
5. System handles errors gracefully

---

## 17. DOCUMENTATION STRUCTURE

### 17.1 Code Documentation
- Inline comments for complex logic
- README.md in repository root
- API integration guide
- Setup and installation instructions
- Troubleshooting guide

### 17.2 User Documentation
- User manual (PDF)
- Feature descriptions
- Screenshots of all screens
- FAQ section
- Support contact information

### 17.3 Technical Documentation
- System architecture diagram
- Data flow diagrams
- API integration details
- Database schema (building data structure)
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

### Appendix B: Data Files
- Campus buildings KML: `Lead City University Campus Map.kml`
- Building data JSON: (Generated from KML)
- API configuration: `android/app/src/main/AndroidManifest.xml`

### Appendix C: API Credentials
- Project: LeadCity-Navigation
- API Key: AIzaSyBLGPUKURvQPmUDYcRJJkNTLk4N9tbxzHQ
- Package: com.leadcity.leadcity_navigation
- Restrictions: Android apps only, Maps SDK for Android

---

## 22. VERSION HISTORY

| Version | Date | Author | Changes |
|---------|------|--------|---------|
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