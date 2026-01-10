import 'package:trying_flutter/data/exhibit.dart';


class Room {
  final int room_id;
  final String name;

  Room({
    required this.room_id,
    required this.name,
  });
}

class RoomWithExhibits {
  final int room_id;
  final String name;
  final List<ExhibitLite> exhibits;

  RoomWithExhibits({
    required this.room_id,
    required this.name,
    required this.exhibits,
  });
}