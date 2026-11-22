# Campus survey data

`campus_walk_2026-05-05.gpx` is the raw GPS trace from the walk around campus
on 5 May 2026. `lib/data/campus_graph.dart` (434 nodes, walkway edges) was
generated from it.

It is kept here as source data only; the app does not load it. It was moved
out of `assets/` so it can never be bundled into the APK by accident.

Note: the per-edge `voiceInstruction` labels in `campus_graph.dart` describe
the corner at the *start* of each edge, walked in this trace's direction.
Navigation works turns out from the route's shape instead (`detectTurns` in
`lib/utils/route_geometry.dart`).
