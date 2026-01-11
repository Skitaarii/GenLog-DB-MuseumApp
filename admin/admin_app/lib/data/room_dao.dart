//@ : Veuillet Gaëtan
// 2025
// Data access Object for room

import 'package:postgres/postgres.dart';
import 'package:admin_app/data/room.dart';
import 'package:admin_app/data/exhibit.dart';



class RoomDao {
  final PostgreSQLConnection connection;

  RoomDao(this.connection);

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
    // return the inserted id
    return result.first[0] as int;
  }


Future<void> updateRoom(int roomId, {required String name}) async {
  await connection.execute(
    'UPDATE Room SET name = @name WHERE room_id = @roomId',
    substitutionValues: {'name': name, 'roomId': roomId},
  );
}

Future<void> updateRoomExhibits(int roomId, List<int> exhibitIds) async {
  // Supprime les anciennes associations
  await connection.execute(
    'DELETE FROM Room_Exhibit WHERE room_id = @roomId',
    substitutionValues: {'roomId': roomId},
  );
  
  // Ajoute les nouvelles associations
  for (final exhibitId in exhibitIds) {
    await connection.execute(
      'INSERT INTO Room_Exhibit (room_id, exhibit_id) VALUES (@roomId, @exhibitId)',
      substitutionValues: {'roomId': roomId, 'exhibitId': exhibitId},
    );
  }
}

  

  Future<List<RoomWithExhibits>> getRoomsWithExhibits() async {
  final result = await connection.query('''
    SELECT r.room_id, r.name, e.exhibit_id, e.title
    FROM room r
    LEFT JOIN room_exhibit re ON re.room_id = r.room_id
    LEFT JOIN exhibits e ON e.exhibit_id = re.exhibit_id
    ORDER BY r.room_id
  '''); 

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

  //attach multiple exhibits to a room (inserts into room_exhibit)
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

  //return a lightweight list of exhibits (id + title)
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



  Future<void> deleteRoom(int roomId) async {
    await connection.query(
      '''
      DELETE FROM room WHERE room_id = @id
      ''',
      substitutionValues: {'id': roomId},
    );
  }


  Future<List<List<dynamic>>> getRoomById(int id) async {
    return await connection.query(
      '''
      SELECT * FROM room WHERE room_id = @id
      ''',
      substitutionValues: {'id': id},
    );
  }

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

