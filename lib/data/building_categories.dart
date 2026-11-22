import '../models/building_category.dart';

/// Category for every building in the campus KML, chosen by the project owner.
///
/// Keys are building names as they appear in the KML. Lookups ignore case,
/// spacing and punctuation (see [categoryForBuildingName]).
const Map<String, BuildingCategory> _buildingCategories = {
  'Achievers': BuildingCategory.hostel,
  'Adeline Hall': BuildingCategory.facility,
  'Almond Hall': BuildingCategory.hostel,
  'Apple hall': BuildingCategory.hostel,
  'Basketball Court': BuildingCategory.sports,
  'Block C': BuildingCategory.academic,
  'Block I': BuildingCategory.hostel,
  'Block L': BuildingCategory.hostel,
  'Block U': BuildingCategory.hostel,
  'Campus Entrance': BuildingCategory.facility, // point-only place (main gate)
  'Camp David 1': BuildingCategory.hostel,
  'Camp David 2': BuildingCategory.hostel,
  'Camp David 3': BuildingCategory.hostel,
  'Camp David 4': BuildingCategory.hostel,
  'Camp David 5': BuildingCategory.hostel,
  'Camp David 6': BuildingCategory.hostel,
  'Car Park': BuildingCategory.facility,
  'Cedars hall': BuildingCategory.hostel,
  'Champions Hostel': BuildingCategory.hostel,
  'Chapel': BuildingCategory.religious,
  'Citrus': BuildingCategory.food,
  'Clinic': BuildingCategory.medical,
  'College of Medicine': BuildingCategory.academic,
  'College of Medicine Lecture Hub': BuildingCategory.lectureRoom,
  'Conference Center': BuildingCategory.facility,
  'Cresta': BuildingCategory.food,
  'Department of Computer Science': BuildingCategory.academic,
  'Enterprise': BuildingCategory.area, // point-only place (entrance to the area)
  'Enterprise field': BuildingCategory.sports,
  'Exodus': BuildingCategory.hostel,
  'Faculty of Art': BuildingCategory.academic,
  'Faculty of Dentistry': BuildingCategory.academic,
  'Faculty of Engineering': BuildingCategory.academic,
  'Faculty of Environmental Science': BuildingCategory.academic,
  'Faculty of Law': BuildingCategory.academic,
  'Faculty of Natural and Applied Science': BuildingCategory.academic,
  'Faculty of Nursing / Engineering': BuildingCategory.academic,
  'Faculty of Social science': BuildingCategory.academic,
  'Genesis hall': BuildingCategory.hostel,
  'Gym': BuildingCategory.facility,
  'Hibiscus hall 1': BuildingCategory.hostel,
  'Hibiscus hall 2': BuildingCategory.hostel,
  'Independence Hostel': BuildingCategory.hostel,
  'Jackson hall': BuildingCategory.hostel,
  'Law Theatre': BuildingCategory.lectureRoom,
  'Lecture Room 11-13': BuildingCategory.lectureRoom,
  'Lecture Room 14-16': BuildingCategory.lectureRoom,
  'Lemon 1 hall': BuildingCategory.hostel,
  'Lemon 2 hall': BuildingCategory.hostel,
  'Library': BuildingCategory.academic,
  'Mango hall': BuildingCategory.facility,
  'Mosque': BuildingCategory.religious,
  'New Tasty Vine': BuildingCategory.food,
  'Olive Hostel': BuildingCategory.hostel,
  'PG Hostel': BuildingCategory.hostel,
  'Peace hall 1': BuildingCategory.hostel,
  'Peace hall 2': BuildingCategory.hostel,
  'Radio Station': BuildingCategory.facility,
  'Rebelation hall 1': BuildingCategory.hostel,
  'Rebelation hall 2': BuildingCategory.hostel,
  'Senate Building': BuildingCategory.admin,
  'Sport Complex': BuildingCategory.sports,
  'Stadium': BuildingCategory.sports,
  'Tasty Delight': BuildingCategory.food,
  'Tasty Vine': BuildingCategory.food,
  'Wisdom Hostel': BuildingCategory.hostel,
};

String _normalize(String name) =>
    name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

final Map<String, BuildingCategory> _byNormalizedName = {
  for (final e in _buildingCategories.entries) _normalize(e.key): e.value,
};

/// The owner-assigned category for [name], or null if the building is not
/// in the list (e.g. a new placemark added to the KML later).
BuildingCategory? categoryForBuildingName(String name) =>
    _byNormalizedName[_normalize(name)];

/// Number of buildings with an assigned category.
int get assignedBuildingCategoryCount => _buildingCategories.length;
