import 'package:flutter/material.dart';

/// Custom Google Maps styles: muted base so campus buildings and the route
/// stand out. Businesses, transit and road icons are hidden; parks stay green.
class MapStyles {
  MapStyles._();

  /// Picks the style that matches the current theme brightness.
  static String of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const String light = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f4f5f9"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6b7287"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f4f5f9"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","stylers":[{"visibility":"on"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#dcefe1"}]},
  {"featureType":"poi.park","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#e6f2e8"}]},
  {"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"color":"#eceef5"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#e3e6ef"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9aa0b2"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#fdf3df"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#f1dfba"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#cfe0f5"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#7d93b5"}]}
]
''';

  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#121730"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a91ab"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#121730"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","stylers":[{"visibility":"on"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#16302a"}]},
  {"featureType":"poi.park","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#152a2b"}]},
  {"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"color":"#171d38"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#252c4d"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1b2140"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#6f7694"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3a3a52"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0b1a33"}]}
]
''';
}
