// Room models for museum application
// Defines data structures for room management and room-exhibit relationships

import 'package:editor_app/data/exhibit.dart';

/// Basic room model containing only core identification information
/// Used for simple list displays where exhibit details are not needed
class Room {
  final int room_id;      // Unique identifier for the room
  final String name;      // Display name of the room

  Room({
    required this.room_id,
    required this.name,
  });
}

/// Complete room model with associated exhibits included
/// Used when full room details including contained exhibits are required
class RoomWithExhibits {
  final int room_id;                // Unique identifier for the room
  final String name;                // Display name of the room
  final List<ExhibitLite> exhibits; // List of exhibits contained in this room

  RoomWithExhibits({
    required this.room_id,
    required this.name,
    required this.exhibits,
  });
}