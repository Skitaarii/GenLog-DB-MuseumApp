// Veuillet Gaëtan
// 2025
// Data Access Object for Room management
// Handles database operations for rooms and their exhibit associations

import 'package:postgres/postgres.dart';
import 'package:editor_app/data/room.dart';
import 'package:editor_app/data/exhibit.dart';

class RoomDao {
  final PostgreSQLConnection connection;

  RoomDao(this.connection);

  // Insert a new room into the database
  // Returns the newly created room ID
  Future<int> insertRoom({
    required String name,
  }) async {
    // Insert and return the new room id
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
    // Return the inserted ID for further operations
    return result.first[0] as int;
  }

  // Update an existing room's name
  Future<void> updateRoom(int roomId, {required String name}) async {
    await connection.execute(
      'UPDATE Room SET name = @name WHERE room_id = @roomId',
      substitutionValues: {'name': name, 'roomId': roomId},
    );
  }

  // Update exhibits associated with a room
  // Ensures each exhibit is only linked to one room at a time
  Future<void> updateRoomExhibits(int roomId, List<int> exhibitIds) async {
    // Remove all exhibits currently in this room
    await connection.execute(
      'DELETE FROM Room_Exhibit WHERE room_id = @roomId',
      substitutionValues: {'roomId': roomId},
    );

    for (final exhibitId in exhibitIds) {
      // Ensure exhibit is not linked to any other room (one-to-one relationship)
      await connection.execute(
        'DELETE FROM Room_Exhibit WHERE exhibit_id = @exhibitId',
        substitutionValues: {'exhibitId': exhibitId},
      );

      // Insert the unique association
      await connection.execute(
        '''
        INSERT INTO Room_Exhibit (room_id, exhibit_id)
        VALUES (@roomId, @exhibitId)
        ''',
        substitutionValues: {
          'roomId': roomId,
          'exhibitId': exhibitId,
        },
      );
    }
  }

  // Get all rooms with their associated exhibits
  // Uses LEFT JOIN to include rooms with no exhibits
  Future<List<RoomWithExhibits>> getRoomsWithExhibits() async {
    final result = await connection.query('''
      SELECT r.room_id, r.name, e.exhibit_id, e.title
      FROM room r
      LEFT JOIN room_exhibit re ON re.room_id = r.room_id
      LEFT JOIN exhibits e ON e.exhibit_id = re.exhibit_id
      ORDER BY r.room_id
    '''); 

    // Map to group exhibits by room
    final Map<int, RoomWithExhibits> rooms = {};

    for (final row in result) {
      final roomId = row[0] as int;
      final roomName = row[1] as String;

      // Create room entry if it doesn't exist
      rooms.putIfAbsent(
        roomId,
        () => RoomWithExhibits(
          room_id: roomId,
          name: roomName,
          exhibits: [],
        ),
      );

      // Add exhibit to room if present (LEFT JOIN may return null)
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

  // Attach multiple exhibits to a room
  // Inserts records into the room_exhibit junction table
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

  // Return a lightweight list of all exhibits (id + title)
  // Used for dropdowns and selection lists
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

  // Delete a room and its exhibit associations (cascade)
  Future<void> deleteRoom(int roomId) async {
  await connection.transaction((ctx) async {
    await ctx.execute(
      'DELETE FROM room_exhibit WHERE room_id = @id',
      substitutionValues: {'id': roomId},
    );

    await ctx.execute(
      'DELETE FROM room WHERE room_id = @id',
      substitutionValues: {'id': roomId},
    );
  });
}


  // Get room details by ID (returns raw query results)
  Future<List<List<dynamic>>> getRoomById(int id) async {
    return await connection.query(
      '''
      SELECT * FROM room WHERE room_id = @id
      ''',
      substitutionValues: {'id': id},
    );
  }

  // Get all rooms without exhibit details
  // Used for simple lists where exhibit info is not needed
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