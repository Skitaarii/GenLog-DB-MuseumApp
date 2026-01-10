// Gaëtan Veuillet
// 2025
// Itinerary models for visitor app

import 'package:visitor_app/data/exhibit.dart';

/// Basic itinerary model with just ID and title
class Itinerary {
  final int itinerary_id;
  final String title;

  Itinerary({
    required this.itinerary_id,
    required this.title,
  });
}

/// Complete itinerary model with associated exhibits
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