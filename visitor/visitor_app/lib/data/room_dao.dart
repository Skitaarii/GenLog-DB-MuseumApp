// Veuillet Gaëtan
// 2025
// Data Access Object for room management

import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/room.dart';
import 'package:visitor_app/data/exhibit.dart';

/// Handles all database operations related to rooms and room-exhibit relationships
class RoomDao {
  final PostgreSQLConnection connection;

  RoomDao(this.connection);

  // CRUD Operations for Rooms

  /// Creates a new room and returns its assigned ID
  Future<int> insertRoom({
    required String name,
  }) async {
    final result = await connection.query(
      '''
      INSERT INTO room(name)
      VALUES (@name)
      RETURNING room_id
      ''',
      substitutionValues: {
        'name': name,
      },
    );
    return result.first[0] as int;
  }

  /// Updates basic room information
  Future<void> updateRoom(int roomId, {required String name}) async {
    await connection.execute(
      'UPDATE Room SET name = @name WHERE room_id = @roomId',
      substitutionValues: {'name': name, 'roomId': roomId},
    );
  }

  /// Replaces all exhibits in a room (clears existing ones first)
  Future<void> updateRoomExhibits(int roomId, List<int> exhibitIds) async {
    // Remove all existing exhibit associations
    await connection.execute(
      'DELETE FROM Room_Exhibit WHERE room_id = @roomId',
      substitutionValues: {'roomId': roomId},
    );
    
    // Add new exhibit associations
    for (final exhibitId in exhibitIds) {
      await connection.execute(
        'INSERT INTO Room_Exhibit (room_id, exhibit_id) VALUES (@roomId, @exhibitId)',
        substitutionValues: {'roomId': roomId, 'exhibitId': exhibitId},
      );
    }
  }

  /// Gets all rooms with their associated exhibits
  /// Used for floor maps and navigation
  Future<List<RoomWithExhibits>> getRoomsWithExhibits() async {
    final result = await connection.query('''
      SELECT r.room_id, r.name, e.exhibit_id, e.title
      FROM room r
      LEFT JOIN room_exhibit re ON re.room_id = r.room_id
      LEFT JOIN exhibits e ON e.exhibit_id = re.exhibit_id
      ORDER BY r.room_id
    '''); 

    // Group exhibits by room using a map
    final Map<int, RoomWithExhibits> rooms = {};

    for (final row in result) {
      final roomId = row[0] as int;
      final roomName = row[1] as String;

      rooms.putIfAbsent(
        roomId,
        () => RoomWithExhibits(
          room_id: roomId,
          name: roomName,
          exhibits: [],
        ),
      );

      // Add exhibit if it exists (LEFT JOIN might return null)
      if (row[2] != null) {
        rooms[roomId]!.exhibits.add(
          ExhibitLite(
            exhibit_id: row[2] as int,
            title: row[3] as String,
          ),
        );
      }
    }
    return rooms.values.toList();
  }

  /// Attaches multiple exhibits to a room
  /// Used during room creation or exhibit assignment
  Future<void> insertRoomExhibits(int roomId, List<int> exhibitIds) async {
    for (final exId in exhibitIds) {
      await connection.query(
        '''
        INSERT INTO room_exhibit(room_id, exhibit_id)
        VALUES (@room_id, @exhibit_id)
        ''',
        substitutionValues: {
          'room_id': roomId,
          'exhibit_id': exId,
        },
      );
    }
  }

  /// Gets all exhibits in the system (lightweight version)
  /// Used for dropdowns and selection lists
  Future<List<ExhibitLite>> getAllExhibits() async {
    final result = await connection.query(
      'SELECT exhibit_id, title FROM exhibits ORDER BY exhibit_id',
    );

    return result.map((row) {
      return ExhibitLite(
        exhibit_id: row[0] as int,
        title: row[1] as String,
      );
    }).toList();
  }

  /// Deletes a room and its exhibit associations (cascade handled by DB)
  Future<void> deleteRoom(int roomId) async {
    await connection.query(
      '''
      DELETE FROM room WHERE room_id = @id
      ''',
      substitutionValues: {'id': roomId},
    );
  }

  /// Gets raw room data by ID
  Future<List<List<dynamic>>> getRoomById(int id) async {
    return await connection.query(
      '''
      SELECT * FROM room WHERE room_id = @id
      ''',
      substitutionValues: {'id': id},
    );
  }

  /// Gets all rooms without exhibit details
  Future<List<Room>> getAllRooms() async {
    final result = await connection.query(
      'SELECT room_id, name FROM room',
    );

    return result.map((row){
      return Room(
        room_id: row[0] as int,
        name : row[1] as String,
      );
    }).toList();
  }
}