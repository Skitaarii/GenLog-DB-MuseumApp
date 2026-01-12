import 'package:editor_app/data/exhibit.dart';

// 2025
// Itinerary data models for museum visit planning

/// Basic itinerary information
/// Used for lists and dropdown selections
class Itinerary {
  final int itinerary_id;
  final String title;

  Itinerary({
    required this.itinerary_id,
    required this.title,
  });
}

/// Itinerary with associated exhibits
/// Used when displaying full itinerary details to visitors
class ItineraryWithExhibits {
  final int itinerary_id;
  final String title;
  final List<ExhibitLite> exhibits; // Lightweight exhibit information

  ItineraryWithExhibits({
    required this.itinerary_id,
    required this.title,
    required this.exhibits,
  });
}