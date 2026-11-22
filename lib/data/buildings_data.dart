import '../models/building.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/kml_parser_service.dart';

/// Campus building data
/// Loads buildings from KML file, with fallback to hardcoded data
class BuildingsData {
  // Lead City University campus center coordinates
  static const LatLng campusCenter = LatLng(7.32607, 3.88041);

  static List<Building>? _kmlBuildings;
  static List<Building>? _fallbackBuildings;
  static Future<List<Building>>? _loading;

  // Lookup indexes for the list currently in use (rebuilt when it changes).
  static List<Building>? _indexedList;
  static Map<String, Building> _byId = const {};
  static Map<String, Building> _byName = const {};

  /// Loads buildings from the bundled KML once; concurrent callers share the
  /// same load. Falls back to the built-in list if parsing fails.
  static Future<List<Building>> loadFromKml() {
    final ready = _kmlBuildings;
    if (ready != null) return Future.value(ready);
    return _loading ??= () async {
      try {
        _kmlBuildings = await KmlParserService().parseKmlFile(
          'assets/Lead City University Campus Map.kml',
        );
        return _kmlBuildings!;
      } catch (e) {
        _loading = null; // allow a later retry
        return getAllBuildings();
      }
    }();
  }

  /// All buildings: the KML list once loaded, otherwise the built-in list.
  static List<Building> getAllBuildings() =>
      _kmlBuildings ?? (_fallbackBuildings ??= _getHardcodedBuildings());

  static void _ensureIndex() {
    final list = getAllBuildings();
    if (identical(list, _indexedList)) return;
    _indexedList = list;
    _byId = {for (final b in list) b.id: b};
    _byName = {for (final b in list) b.name.toLowerCase(): b};
  }

  /// Get hardcoded buildings (fallback data)
  static List<Building> _getHardcodedBuildings() {
    return [
      // Academic Buildings (17)
      Building(
        id: 'library',
        name: 'Library',
        type: 'Academic',
        entrancePoint: const LatLng(7.3273033, 3.8774483),
        polygonCoordinates: [
          const LatLng(7.3270960, 3.8773260),
          const LatLng(7.3267368, 3.8773850),
          const LatLng(7.3267648, 3.8776143),
          const LatLng(7.3271425, 3.8775459),
          const LatLng(7.3271319, 3.8774816),
          const LatLng(7.3272037, 3.8774655),
          const LatLng(7.3271891, 3.8773635),
          const LatLng(7.3271080, 3.8773850),
        ],
      ),
      Building(
        id: 'faculty_of_law',
        name: 'Faculty of Law',
        type: 'Academic',
        entrancePoint: const LatLng(7.3284150, 3.8811400),
        polygonCoordinates: [
          const LatLng(7.3284736, 3.8811136),
          const LatLng(7.3285015, 3.8811605),
          const LatLng(7.3284350, 3.8812101),
          const LatLng(7.3284776, 3.8812973),
          const LatLng(7.3285614, 3.8812544),
          const LatLng(7.3285866, 3.8813067),
          const LatLng(7.3289591, 3.8810760),
          const LatLng(7.3288327, 3.8808802),
        ],
      ),
      Building(
        id: 'faculty_of_engineering',
        name: 'Faculty of Engineering',
        type: 'Academic',
        entrancePoint: const LatLng(7.3282100, 3.8773517),
        polygonCoordinates: [
          const LatLng(7.3281857, 3.8774055),
          const LatLng(7.3281339, 3.8774055),
          const LatLng(7.3281126, 3.8773264),
          const LatLng(7.3280181, 3.8773532),
          const LatLng(7.3280394, 3.8774283),
          const LatLng(7.3279942, 3.8774430),
          const LatLng(7.3281033, 3.8778561),
          const LatLng(7.3282922, 3.8778011),
        ],
      ),
      Building(
        id: 'faculty_of_nursing_engineering',
        name: 'Faculty of Nursing/Engineering',
        type: 'Academic',
        entrancePoint: const LatLng(7.3256317, 3.8812150),
        polygonCoordinates: [
          const LatLng(7.3255103, 3.8810246),
          const LatLng(7.3247495, 3.8812741),
          const LatLng(7.3248878, 3.8816871),
          const LatLng(7.3256460, 3.8814082),
        ],
      ),
      Building(
        id: 'faculty_of_social_science',
        name: 'Faculty of Social Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3266017, 3.8792717),
        polygonCoordinates: [
          const LatLng(7.3262998, 3.8790220),
          const LatLng(7.3258050, 3.8790488),
          const LatLng(7.3258316, 3.8792902),
          const LatLng(7.3263237, 3.8792446),
        ],
      ),
      Building(
        id: 'faculty_of_art',
        name: 'Faculty of Art',
        type: 'Academic',
        entrancePoint: const LatLng(7.3266183, 3.8794567),
        polygonCoordinates: [
          const LatLng(7.3263344, 3.8793975),
          const LatLng(7.3258502, 3.8794324),
          const LatLng(7.3258768, 3.8796684),
          const LatLng(7.3263636, 3.8796202),
        ],
      ),
      Building(
        id: 'faculty_of_environmental_science',
        name: 'Faculty of Environmental Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3266650, 3.8796550),
        polygonCoordinates: [
          const LatLng(7.3263649, 3.8797293),
          const LatLng(7.3257410, 3.8798219),
          const LatLng(7.3257942, 3.8801169),
          const LatLng(7.3264074, 3.8800136),
        ],
      ),
      Building(
        id: 'faculty_of_natural_applied_science',
        name: 'Faculty of Natural and Applied Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3273533, 3.8775917),
        polygonCoordinates: [
          const LatLng(7.3274385, 3.8775661),
          const LatLng(7.3273853, 3.8775876),
          const LatLng(7.3274970, 3.8780033),
          const LatLng(7.3277019, 3.8779497),
          const LatLng(7.3275901, 3.8775366),
          const LatLng(7.3275423, 3.8775500),
          const LatLng(7.3275103, 3.8774628),
          const LatLng(7.3274225, 3.8774910),
        ],
      ),
      Building(
        id: 'faculty_of_dentistry',
        name: 'Faculty of Dentistry',
        type: 'Academic',
        entrancePoint: const LatLng(7.3261567, 3.8814517),
        polygonCoordinates: [
          const LatLng(7.3261702, 3.8809357),
          const LatLng(7.3257193, 3.8810926),
          const LatLng(7.3258270, 3.8813675),
          const LatLng(7.3262753, 3.8812079),
        ],
      ),
      Building(
        id: 'computer_science',
        name: 'Department of Computer Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3272567, 3.8770583),
        polygonCoordinates: [
          const LatLng(7.3270706, 3.8771782),
          const LatLng(7.3271611, 3.8771634),
          const LatLng(7.3271464, 3.8770682),
          const LatLng(7.3270573, 3.8770896),
          const LatLng(7.3270387, 3.8770132),
          const LatLng(7.3267088, 3.8770776),
          const LatLng(7.3267527, 3.8773123),
          const LatLng(7.3270813, 3.8772492),
        ],
      ),
      Building(
        id: 'college_of_medicine',
        name: 'College of Medicine',
        type: 'Academic',
        entrancePoint: const LatLng(7.3267083, 3.8811933),
        polygonCoordinates: [
          const LatLng(7.3266850, 3.8807639),
          const LatLng(7.3262221, 3.8808953),
          const LatLng(7.3263365, 3.8811850),
          const LatLng(7.3267808, 3.8810133),
        ],
      ),
      Building(
        id: 'college_of_medicine_lecture_hub',
        name: 'College of Medicine Lecture Hub',
        type: 'Academic',
        entrancePoint: const LatLng(7.3268233, 3.8800133),
        polygonCoordinates: [
          const LatLng(7.3264695, 3.8800987),
          const LatLng(7.3259455, 3.8801818),
          const LatLng(7.3260359, 3.8806164),
          const LatLng(7.3265467, 3.8805252),
        ],
      ),
      Building(
        id: 'law_theatre',
        name: 'Law Theatre',
        type: 'Academic',
        entrancePoint: const LatLng(7.3283717, 3.8817467),
        polygonCoordinates: [
          const LatLng(7.3285251, 3.8816961),
          const LatLng(7.3282112, 3.8818892),
          const LatLng(7.3285198, 3.8823613),
          const LatLng(7.3286156, 3.8823023),
          const LatLng(7.3286555, 3.8823586),
          const LatLng(7.3287646, 3.8822889),
          const LatLng(7.3287300, 3.8822245),
          const LatLng(7.3288577, 3.8821655),
        ],
      ),
      Building(
        id: 'lecture_rooms_11_13',
        name: 'Lecture Rooms 11-13',
        type: 'Academic',
        entrancePoint: const LatLng(7.3281733, 3.8771533),
        polygonCoordinates: [
          const LatLng(7.3283070, 3.8768866),
          const LatLng(7.3281261, 3.8769188),
          const LatLng(7.3282112, 3.8771950),
          const LatLng(7.3283815, 3.8771387),
        ],
      ),
      Building(
        id: 'lecture_rooms_14_16',
        name: 'Lecture Rooms 14-16',
        type: 'Academic',
        entrancePoint: const LatLng(7.3282100, 3.8773517),
        polygonCoordinates: [
          const LatLng(7.3284308, 3.8772610),
          const LatLng(7.3282286, 3.8773227),
          const LatLng(7.3283031, 3.8775856),
          const LatLng(7.3285079, 3.8775346),
        ],
      ),
      Building(
        id: 'adeline_hall',
        name: 'Adeline Hall',
        type: 'Academic',
        entrancePoint: const LatLng(7.3276283, 3.8773867),
        polygonCoordinates: [
          const LatLng(7.3278918, 3.8773907),
          const LatLng(7.3276763, 3.8774390),
          const LatLng(7.3278027, 3.8779996),
          const LatLng(7.3280328, 3.8779460),
        ],
      ),
      Building(
        id: 'conference_center',
        name: 'Conference Center',
        type: 'Academic',
        entrancePoint: const LatLng(7.3287950, 3.8813250),
        polygonCoordinates: [
          const LatLng(7.3288965, 3.8814079),
          const LatLng(7.3287874, 3.8814401),
          const LatLng(7.3287449, 3.8813368),
          const LatLng(7.3285879, 3.8813958),
          const LatLng(7.3288154, 3.8819095),
          const LatLng(7.3289723, 3.8818585),
          const LatLng(7.3288646, 3.8816064),
          const LatLng(7.3289178, 3.8815796),
          const LatLng(7.3289497, 3.8815071),
        ],
      ),
      // Administrative (2)
      Building(
        id: 'senate_building',
        name: 'Senate Building',
        type: 'Administrative',
        entrancePoint: const LatLng(7.3281833, 3.8803800),
        polygonCoordinates: [
          const LatLng(7.3285720, 3.8801858),
          const LatLng(7.3283539, 3.8803440),
          const LatLng(7.3286425, 3.8807115),
          const LatLng(7.3288606, 3.8805519),
        ],
      ),
      Building(
        id: 'radio_station',
        name: 'Radio Station',
        type: 'Administrative',
        entrancePoint: const LatLng(7.3268133, 3.8778300),
        polygonCoordinates: [
          const LatLng(7.3267010, 3.8771136),
          const LatLng(7.3265880, 3.8771324),
          const LatLng(7.3266372, 3.8774180),
          const LatLng(7.3267370, 3.8773966),
          const LatLng(7.3267117, 3.8773107),
          const LatLng(7.3267527, 3.8773123),
        ],
      ),
      // Religious (2)
      Building(
        id: 'chapel',
        name: 'Chapel',
        type: 'Religious',
        entrancePoint: const LatLng(7.3281333, 3.8814267),
        polygonCoordinates: [
          const LatLng(7.3282069, 3.8810603),
          const LatLng(7.3280553, 3.8811596),
          const LatLng(7.3283718, 3.8816665),
          const LatLng(7.3285368, 3.8815592),
        ],
      ),
      Building(
        id: 'mosque',
        name: 'Mosque',
        type: 'Religious',
        entrancePoint: const LatLng(7.3283783, 3.8771483),
        polygonCoordinates: [
          const LatLng(7.3285438, 3.8771778),
          const LatLng(7.3284081, 3.8772006),
          const LatLng(7.3285146, 3.8775560),
          const LatLng(7.3286436, 3.8775185),
        ],
      ),
      // Medical (1)
      Building(
        id: 'clinic',
        name: 'Clinic',
        type: 'Medical',
        entrancePoint: const LatLng(7.3271733, 3.8776450),
        polygonCoordinates: [
          const LatLng(7.3273049, 3.8778471),
          const LatLng(7.3271984, 3.8776620),
          const LatLng(7.3266185, 3.8779759),
          const LatLng(7.3267355, 3.8781770),
        ],
      ),
      // Residential (28)
      Building(
        id: 'champions_hostel',
        name: 'Champions Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3261133, 3.8780050),
        polygonCoordinates: [
          const LatLng(7.3262690, 3.8777360),
          const LatLng(7.3258700, 3.8777118),
          const LatLng(7.3258567, 3.8779184),
          const LatLng(7.3262504, 3.8779425),
        ],
      ),
      Building(
        id: 'wisdom_hostel',
        name: 'Wisdom Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3261133, 3.8780050),
        polygonCoordinates: [
          const LatLng(7.3257170, 3.8777440),
          const LatLng(7.3252275, 3.8776970),
          const LatLng(7.3252075, 3.8779210),
          const LatLng(7.3256930, 3.8779559),
        ],
      ),
      Building(
        id: 'independence_hostel',
        name: 'Independence Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3261133, 3.8780050),
        polygonCoordinates: [
          const LatLng(7.3258442, 3.8780800),
          const LatLng(7.3252430, 3.8779754),
          const LatLng(7.3252004, 3.8782249),
          const LatLng(7.3258043, 3.8783080),
        ],
      ),
      // Recreation & Dining (12)
      Building(
        id: 'tasty_vine',
        name: 'Tasty Vine',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3235167, 3.8820067),
        polygonCoordinates: [
          const LatLng(7.3233906, 3.8819624),
          const LatLng(7.3232443, 3.8819811),
          const LatLng(7.3233374, 3.8823540),
          const LatLng(7.3234837, 3.8823191),
        ],
      ),
      Building(
        id: 'new_tasty_vine',
        name: 'New Tasty Vine',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3238650, 3.8820367),
        polygonCoordinates: [
          const LatLng(7.3237288, 3.8819771),
          const LatLng(7.3235253, 3.8820133),
          const LatLng(7.3235865, 3.8822748),
          const LatLng(7.3237860, 3.8822239),
        ],
      ),
      Building(
        id: 'cresta',
        name: 'Cresta',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3236283, 3.8818033),
        polygonCoordinates: [
          const LatLng(7.3231378, 3.8800989),
          const LatLng(7.3228877, 3.8801096),
          const LatLng(7.3228771, 3.8799675),
          const LatLng(7.3227388, 3.8799782),
          const LatLng(7.3227707, 3.8802652),
          const LatLng(7.3231458, 3.8802464),
        ],
      ),
      Building(
        id: 'stadium',
        name: 'Stadium',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3266717, 3.8791117),
        polygonCoordinates: [
          const LatLng(7.3275005, 3.8786019),
          const LatLng(7.3267130, 3.8791705),
          const LatLng(7.3273089, 3.8807262),
          const LatLng(7.3282507, 3.8801683),
          const LatLng(7.3279421, 3.8792242),
          const LatLng(7.3276920, 3.8786824),
        ],
      ),
      Building(
        id: 'car_park',
        name: 'Car Park',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3274833, 3.8769400),
        polygonCoordinates: [
          const LatLng(7.3280742, 3.8768994),
          const LatLng(7.3273493, 3.8770054),
          const LatLng(7.3274065, 3.8774439),
          const LatLng(7.3281580, 3.8772441),
        ],
      ),
      Building(
        id: 'campus_entrance',
        name: 'Campus Entrance',
        type: 'Facilities',
        entrancePoint: const LatLng(7.3268333, 3.8766383),
        polygonCoordinates: [
          const LatLng(7.3267333, 3.8765383),
          const LatLng(7.3269333, 3.8765383),
          const LatLng(7.3269333, 3.8767383),
          const LatLng(7.3267333, 3.8767383),
        ],
      ),
      Building(
        id: 'enterprise',
        name: 'Enterprise',
        type: 'Facilities',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3240133, 3.8822950),
          const LatLng(7.3242133, 3.8822950),
          const LatLng(7.3242133, 3.8824950),
          const LatLng(7.3240133, 3.8824950),
        ],
      ),
      // Residential (28)
      Building(
        id: 'block_l',
        name: 'Block L',
        type: 'Residential',
        entrancePoint: const LatLng(7.3236283, 3.8818033),
        polygonCoordinates: [
          const LatLng(7.3234797, 3.8812358),
          const LatLng(7.3234531, 3.8812398),
          const LatLng(7.3232642, 3.8813015),
          const LatLng(7.3233055, 3.8814544),
          const LatLng(7.3233919, 3.8814168),
          const LatLng(7.3234239, 3.8815120),
          const LatLng(7.3234771, 3.8814960),
          const LatLng(7.3235595, 3.8817588),
          const LatLng(7.3236526, 3.8817347),
          const LatLng(7.3235742, 3.8814852),
        ],
      ),
      Building(
        id: 'block_c',
        name: 'Block C',
        type: 'Residential',
        entrancePoint: const LatLng(7.3231700, 3.8819467),
        polygonCoordinates: [
          const LatLng(7.3232048, 3.8813264),
          const LatLng(7.3229800, 3.8813868),
          const LatLng(7.3230079, 3.8814820),
          const LatLng(7.3231369, 3.8814458),
          const LatLng(7.3232367, 3.8817556),
          const LatLng(7.3231063, 3.8817891),
          const LatLng(7.3231436, 3.8818763),
          const LatLng(7.3233657, 3.8818132),
        ],
      ),
      Building(
        id: 'block_u',
        name: 'Block U',
        type: 'Residential',
        entrancePoint: const LatLng(7.3229733, 3.8819933),
        polygonCoordinates: [
          const LatLng(7.3230950, 3.8818906),
          const LatLng(7.3229446, 3.8814145),
          const LatLng(7.3226627, 3.8814963),
          const LatLng(7.3228249, 3.8819751),
          const LatLng(7.3229313, 3.8819402),
          const LatLng(7.3228143, 3.8816237),
          const LatLng(7.3228835, 3.8815996),
          const LatLng(7.3229872, 3.8819268),
        ],
      ),
      Building(
        id: 'block_i',
        name: 'Block I',
        type: 'Residential',
        entrancePoint: const LatLng(7.3228767, 3.8820167),
        polygonCoordinates: [
          const LatLng(7.3225908, 3.8815352),
          const LatLng(7.3224857, 3.8815607),
          const LatLng(7.3226467, 3.8820381),
          const LatLng(7.3227518, 3.8820113),
        ],
      ),
      // Recreation & Dining (12)
      Building(
        id: 'exodus',
        name: 'Exodus',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3242002, 3.8830519),
          const LatLng(7.3240379, 3.8831779),
          const LatLng(7.3248121, 3.8840175),
          const LatLng(7.3249478, 3.8838807),
        ],
      ),
      Building(
        id: 'citrus',
        name: 'Citrus',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3238855, 3.8835232),
          const LatLng(7.3237245, 3.8836640),
          const LatLng(7.3239799, 3.8839255),
          const LatLng(7.3241356, 3.8838008),
        ],
      ),
      Building(
        id: 'gym',
        name: 'Gym',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3239753, 3.8824592),
          const LatLng(7.3238569, 3.8825142),
          const LatLng(7.3240152, 3.8827636),
          const LatLng(7.3241282, 3.8827006),
        ],
      ),
      Building(
        id: 'achievers',
        name: 'Achievers',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3275317, 3.8782100),
        polygonCoordinates: [
          const LatLng(7.3273732, 3.8782607),
          const LatLng(7.3267986, 3.8786389),
          const LatLng(7.3269449, 3.8788240),
          const LatLng(7.3274929, 3.8784512),
        ],
      ),
      Building(
        id: 'tasty_delight',
        name: 'Tasty Delight',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3261133, 3.8780050),
        polygonCoordinates: [
          const LatLng(7.3261091, 3.8780401),
          const LatLng(7.3259535, 3.8780387),
          const LatLng(7.3259521, 3.8781634),
          const LatLng(7.3261011, 3.8781715),
        ],
      ),

      Building(
        id: 'sport_complex',
        name: 'Sport Complex',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3279550, 3.8811600),
        polygonCoordinates: [
          const LatLng(7.3279064, 3.8805800),
          const LatLng(7.3274009, 3.8809126),
          const LatLng(7.3276031, 3.8812345),
          const LatLng(7.3280926, 3.8808965),
        ],
      ),
      // Residential (28)
      Building(
        id: 'olive_hostel',
        name: 'Olive Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3239898, 3.8832560),
          const LatLng(7.3238727, 3.8833741),
          const LatLng(7.3246176, 3.8842109),
          const LatLng(7.3247879, 3.8840714),
        ],
      ),
      Building(
        id: 'jackson_hall',
        name: 'Jackson hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3236283, 3.8818033),
        polygonCoordinates: [
          const LatLng(7.3232214, 3.8803603),
          const LatLng(7.3230564, 3.8803845),
          const LatLng(7.3232772, 3.8810926),
          const LatLng(7.3234422, 3.8810523),
        ],
      ),
      Building(
        id: 'almond_hall',
        name: 'Almond hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3234383, 3.8818633),
        polygonCoordinates: [
          const LatLng(7.3233383, 3.8817633),
          const LatLng(7.3235383, 3.8817633),
          const LatLng(7.3235383, 3.8819633),
          const LatLng(7.3233383, 3.8819633),
        ],
      ),
      Building(
        id: 'peace_hall_1',
        name: 'Peace hall 1',
        type: 'Residential',
        entrancePoint: const LatLng(7.3232450, 3.8819050),
        polygonCoordinates: [
          const LatLng(7.3229054, 3.8809109),
          const LatLng(7.3227644, 3.8809552),
          const LatLng(7.3228642, 3.8812274),
          const LatLng(7.3229985, 3.8811831),
        ],
      ),
      Building(
        id: 'camp_david_1',
        name: 'Camp David 1',
        type: 'Residential',
        entrancePoint: const LatLng(7.3230583, 3.8819483),
        polygonCoordinates: [
          const LatLng(7.3226578, 3.8808526),
          const LatLng(7.3225221, 3.8808956),
          const LatLng(7.3226511, 3.8812992),
          const LatLng(7.3227868, 3.8812483),
        ],
      ),
      Building(
        id: 'camp_david_3',
        name: 'Camp David 3',
        type: 'Residential',
        entrancePoint: const LatLng(7.3228767, 3.8820167),
        polygonCoordinates: [
          const LatLng(7.3224609, 3.8809237),
          const LatLng(7.3223252, 3.8809599),
          const LatLng(7.3224569, 3.8813515),
          const LatLng(7.3225860, 3.8813153),
        ],
      ),
      Building(
        id: 'camp_david_5',
        name: 'Camp David 5',
        type: 'Residential',
        entrancePoint: const LatLng(7.3228767, 3.8820167),
        polygonCoordinates: [
          const LatLng(7.3222614, 3.8809827),
          const LatLng(7.3221284, 3.8810203),
          const LatLng(7.3222468, 3.8814226),
          const LatLng(7.3223931, 3.8813824),
        ],
      ),
      Building(
        id: 'peace_hall_2',
        name: 'Peace hall 2',
        type: 'Residential',
        entrancePoint: const LatLng(7.3230583, 3.8819483),
        polygonCoordinates: [
          const LatLng(7.3227817, 3.8805689),
          const LatLng(7.3226553, 3.8806024),
          const LatLng(7.3227524, 3.8808801),
          const LatLng(7.3228814, 3.8808465),
        ],
      ),
      Building(
        id: 'hibiscus_hall_1',
        name: 'Hibiscus hall 1',
        type: 'Residential',
        entrancePoint: const LatLng(7.3230583, 3.8819483),
        polygonCoordinates: [
          const LatLng(7.3225150, 3.8801978),
          const LatLng(7.3222383, 3.8802219),
          const LatLng(7.3222716, 3.8803775),
          const LatLng(7.3225323, 3.8803319),
        ],
      ),
      Building(
        id: 'hibiscus_hall_2',
        name: 'Hibiscus hall 2',
        type: 'Residential',
        entrancePoint: const LatLng(7.3230583, 3.8819483),
        polygonCoordinates: [
          const LatLng(7.3225044, 3.8801442),
          const LatLng(7.3224871, 3.8800020),
          const LatLng(7.3222184, 3.8800449),
          const LatLng(7.3222410, 3.8801924),
        ],
      ),
      Building(
        id: 'pg_hostel',
        name: 'PG Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3228767, 3.8820167),
        polygonCoordinates: [
          const LatLng(7.3220574, 3.8801133),
          const LatLng(7.3216238, 3.8803681),
          const LatLng(7.3217276, 3.8805291),
          const LatLng(7.3221452, 3.8802581),
        ],
      ),
      Building(
        id: 'genesis_hall',
        name: 'Genesis hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3235177, 3.8836847),
          const LatLng(7.3233262, 3.8838349),
          const LatLng(7.3237305, 3.8842802),
          const LatLng(7.3239141, 3.8841085),
        ],
      ),
      Building(
        id: 'cedars_hall',
        name: 'Cedars hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3242493, 3.8839301),
          const LatLng(7.3240684, 3.8840857),
          const LatLng(7.3244262, 3.8844733),
          const LatLng(7.3246191, 3.8843056),
        ],
      ),
      Building(
        id: 'mango_hall',
        name: 'Mango hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3241133, 3.8823950),
        polygonCoordinates: [
          const LatLng(7.3240232, 3.8841286),
          const LatLng(7.3238409, 3.8843043),
          const LatLng(7.3242067, 3.8846825),
          const LatLng(7.3243903, 3.8845296),
        ],
      ),
      Building(
        id: 'apple_hall',
        name: 'Apple hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3240900, 3.8823833),
        polygonCoordinates: [
          const LatLng(7.3233205, 3.8825157),
          const LatLng(7.3230943, 3.8825707),
          const LatLng(7.3233391, 3.8832775),
          const LatLng(7.3234096, 3.8832829),
          const LatLng(7.3234907, 3.8832587),
          const LatLng(7.3235572, 3.8832265),
          const LatLng(7.3234974, 3.8830790),
          const LatLng(7.3235679, 3.8830549),
          const LatLng(7.3234269, 3.8826311),
          const LatLng(7.3233657, 3.8826525),
        ],
      ),
      Building(
        id: 'lemon_1_hall',
        name: 'Lemon 1 hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3243100, 3.8823633),
        polygonCoordinates: [
          const LatLng(7.3250132, 3.8839672),
          const LatLng(7.3246807, 3.8842824),
          const LatLng(7.3247858, 3.8843977),
          const LatLng(7.3251263, 3.8840705),
        ],
      ),
      Building(
        id: 'lemon_2_hall',
        name: 'Lemon 2 Hall',
        type: 'Residential',
        entrancePoint: const LatLng(7.3244933, 3.8822817),
        polygonCoordinates: [
          const LatLng(7.3243933, 3.8821817),
          const LatLng(7.3245933, 3.8821817),
          const LatLng(7.3245933, 3.8823817),
          const LatLng(7.3243933, 3.8823817),
        ],
      ),
      Building(
        id: 'the_chronicles',
        name: 'The chronicles',
        type: 'Residential',
        entrancePoint: const LatLng(7.3246267, 3.8822267),
        polygonCoordinates: [
          const LatLng(7.3245267, 3.8821267),
          const LatLng(7.3247267, 3.8821267),
          const LatLng(7.3247267, 3.8823267),
          const LatLng(7.3245267, 3.8823267),
        ],
      ),
      Building(
        id: 'camp_david_2',
        name: 'Camp David 2',
        type: 'Residential',
        entrancePoint: const LatLng(7.3230583, 3.8819483),
        polygonCoordinates: [
          const LatLng(7.3225155, 3.8804356),
          const LatLng(7.3223798, 3.8804610),
          const LatLng(7.3225128, 3.8808620),
          const LatLng(7.3226378, 3.8808191),
        ],
      ),
      Building(
        id: 'camp_david_4',
        name: 'Camp David 4',
        type: 'Residential',
        entrancePoint: const LatLng(7.3228767, 3.8820167),
        polygonCoordinates: [
          const LatLng(7.3223146, 3.8804892),
          const LatLng(7.3221842, 3.8805227),
          const LatLng(7.3223186, 3.8809237),
          const LatLng(7.3224503, 3.8808835),
        ],
      ),
      Building(
        id: 'camp_david_6',
        name: 'Camp David 6',
        type: 'Residential',
        entrancePoint: const LatLng(7.3228767, 3.8820167),
        polygonCoordinates: [
          const LatLng(7.3221270, 3.8805536),
          const LatLng(7.3219821, 3.8805831),
          const LatLng(7.3221164, 3.8809975),
          const LatLng(7.3222521, 3.8809532),
        ],
      ),
    ];
  }

  /// Building with [id], or null. Instant (indexed) lookup.
  static Building? getBuildingById(String id) {
    _ensureIndex();
    return _byId[id];
  }

  /// Building whose name matches [name] ignoring case, or null.
  static Building? getBuildingByName(String name) {
    _ensureIndex();
    return _byName[name.toLowerCase()];
  }
}
