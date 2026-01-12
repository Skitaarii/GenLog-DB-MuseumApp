// Veuillet Gaëtan
// 2025
// Room data models for museum layout

import 'package:visitor_app/data/exhibit.dart';

/// Basic room information
class Room {
  final int room_id;
  final String name;

  Room({
    required this.room_id,
    required this.name,
  });
}

/// Room with its associated exhibits - used for floor navigation
class RoomWithExhibits {
  final int room_id;
  final String name;
  final List<ExhibitLite> exhibits; // Lightweight exhibit info for room display

  RoomWithExhibits({
    required this.room_id,
    required this.name,
    required this.exhibits,
  });
}