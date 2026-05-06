# Lead City Navigation — Project Roadmap (Defense-Ready)

**Project:** Lead City University Campus Navigation System (Flutter/Android)  
**Roadmap goal:** Be **project defense-ready** with working demo + testing evidence + clean repository (no secrets).  

---

## Current status snapshot

### Implemented (in code)
- **Screens (7/7)**: Splash, Home, Map, Building List, Find Route, Route Preview, Navigation (`lib/screens/*`).  
- **Campus data**: KML asset included + parser + fallback to hardcoded buildings (`assets/Lead City University Campus Map.kml`, `lib/services/kml_parser_service.dart`, `lib/data/buildings_data.dart`).  
- **Routing**: Google Directions API client + polyline + step instructions (`lib/services/navigation_service.dart`).  
- **Voice guidance**: Text-to-speech service (`lib/services/voice_service.dart`).  
- **Location**: GPS + streaming updates (`lib/services/location_service.dart`).  
- **Map overlays**: Polygons + custom markers + search-to-zoom (`lib/screens/map_screen.dart`).  

### Implemented but **not yet verified in the field** (needs evidence)
- **KML accuracy**: building count, polygon alignment, entrance matching, centroid fallback.  
- **Navigation accuracy**: GPS drift tolerance, instruction switching logic, arrival threshold, voice cadence.  
- **Performance**: map load speed with all polygons, memory usage, battery usage during navigation.  

### Known product gaps (acceptable if documented)
- **“Use Current Location” on Find Route** is UI-only (doesn’t set origin / calculate from raw GPS yet) (`lib/screens/find_route_screen.dart`).  
- **Search autocomplete** is local building-list suggestions (not Google Places).  
- **Offline mode** is not supported (internet required for maps + routing).  

---

## Critical path milestones (Defense-ready)

### Milestone 1 — Secure config + app runs on device (1 day)
- [ ] **Remove all real API keys from repo & docs** (use placeholders only).\n- [ ] Confirm Maps SDK key loads from `android/local.properties`.\n- [ ] Confirm Directions API key is provided via a secure dev mechanism (env var / native channel) and not hardcoded.\n- [ ] Run app on emulator + 1 physical Android device.\n
**Evidence:** screenshot of map rendering + route preview.

### Milestone 2 — KML validation (1–2 days)
- [ ] Confirm buildings load from KML on device (target **42 buildings**).\n- [ ] Validate polygons render and are clickable.\n- [ ] Validate entrance points (or centroid fallback) behave reasonably.\n- [ ] Validate “special cases” (e.g., hostel entrance naming) are handled.\n
**Evidence:** screenshots of 5–10 key buildings on map + short note of any mismatches and fixes.

### Milestone 3 — Navigation validation (2–4 days)
- [ ] Test 6–10 **start → destination** pairs on campus.\n- [ ] Verify: route draws, instructions advance, voice speaks, arrival triggers.\n- [ ] Record GPS accuracy notes (good/bad spots).\n- [ ] Measure basic performance: startup time, map load time, route calc time.\n
**Evidence:** test table + short demo video (2–3 minutes).

### Milestone 4 — Defense package (1–2 days)
- [ ] Presentation slides: problem, dataset/KML method, architecture, demo, results, limitations, future work.\n- [ ] Demo script (5–10 minutes) + backup plan (screenshots/video).\n- [ ] Final documentation pass (Quick start + testing checklist + troubleshooting).\n
**Evidence:** slide deck + demo script + printed/ready-to-submit report sections.

---

## Testing plan (what to actually run)

### Manual functional tests (minimum set)
- [ ] Map screen loads, buildings visible, tap opens building details.\n- [ ] Building list search filters correctly.\n- [ ] Find Route: pick start + destination, route calculates, preview displays.\n- [ ] Navigation: location updates, instruction changes, mute/unmute, end nav.\n- [ ] Error handling: no internet, GPS off/denied, missing API key.\n
### Data integrity tests (KML)
- [ ] Count buildings parsed.\n- [ ] Spot-check 10 buildings for polygon alignment.\n- [ ] Entrances: spot-check 10 buildings for entrance position.\n
### Performance checks (defense-level)
- [ ] Startup time and map render time noted.\n- [ ] Route calculation time noted.\n

---

## Documentation deliverables

- [ ] **README / Quick Start**: setup, API key configuration, run steps, troubleshooting.\n- [ ] **User guide**: screenshots of all screens + usage flow.\n- [ ] **Technical write-up**: architecture, KML methodology, coordinate conversion, trade-offs.\n- [ ] **Testing evidence pack**: test table + screenshots + demo video link/file.\n

---

## Risks & mitigations

- **API key leakage**: remove keys from repo, restrict keys in Google Cloud Console, rotate if exposed.\n- **GPS accuracy variability**: document limitations; test in multiple campus areas; tune arrival threshold if needed.\n- **Network dependence**: include clear UI errors + “demo fallback” screenshots/video.\n- **Data mismatch (KML)**: maintain fallback dataset; log discrepancies; fix KML names where possible.\n

---

## Definition of Done (Defense-ready)

- [ ] No real secrets/API keys in git history/workspace docs.\n- [ ] App runs on at least 2 Android devices (or 1 device + emulator) without crashes.\n- [ ] KML buildings load and display; at least 10 buildings verified visually.\n- [ ] At least 6 real navigation test cases completed on campus with results recorded.\n- [ ] Demo video recorded + slide deck ready.\n- [ ] Quick start + troubleshooting docs match actual setup.\n

---

**Last Updated:** 2026-04-13  
**Next action:** Complete Milestone 1 (secure configuration + device run)  