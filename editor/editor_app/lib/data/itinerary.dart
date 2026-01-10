import 'package:editor_app/data/exhibit.dart';

class Itinerary {
  final int itinerary_id;
  final String title;

  Itinerary({
    required this.itinerary_id,
    required this.title,
  });
}

class ItineraryWithExhibits {
  final int itinerary_id;
  final String title;
  final List<ExhibitLite> exhibits;

  ItineraryWithExhibits({
    required this.itinerary_id,
    required this.title,
    required this.exhibits,
  });
}