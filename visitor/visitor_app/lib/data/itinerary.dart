// Gaëtan Veuillet
// 2025
// Itinerary models for visitor app
// Defines data structures for itinerary management

import 'package:visitor_app/data/exhibit.dart';

/// Basic itinerary model containing only core identification information
/// Used for simple list displays where exhibit details are not needed
class Itinerary {
  final int itinerary_id;      // Unique identifier for the itinerary
  final String title;          // Display name of the itinerary

  Itinerary({
    required this.itinerary_id,
    required this.title,
  });
}

/// Complete itinerary model with associated exhibits included
/// Used when full itinerary details including contained exhibits are required
class ItineraryWithExhibits {
  final int itinerary_id;      // Unique identifier for the itinerary
  final String title;          // Display name of the itinerary
  final List<ExhibitLite> exhibits; // List of exhibits contained in this itinerary

  ItineraryWithExhibits({
    required this.itinerary_id,
    required this.title,
    required this.exhibits,
  });
}