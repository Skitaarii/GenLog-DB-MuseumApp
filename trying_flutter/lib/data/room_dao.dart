//@ : Veuillet Gaëtan
// 2025
// Data Access Object for User entity
// WHAT DA HELL IS GOING ON

import 'package:postgres/postgres.dart';
import 'package:trying_flutter/data/room.dart';

class RoomDao {
  final PostgreSQLConnection connection;

  RoomDao(this.connection);

  Future<void> insertRoom({
    required String name,
  }) async {
    await connection.query(
      '''
      INSERT INTO room(name)
      VALUES (@name)
      ''',
      substitutionValues: {
        'name': name,
      },
    );
  }

  /*
  Future<void> insertExhibit({
    required String title,
    DateTime? startDate,
    DateTime? finalDate,
    required int shortDescId,
    required int longDescId,
  }) async {
    await connection.query(
      '''
      INSERT INTO exhibits(title, short_desc_id, long_desc_id, start_date, final_date)
      VALUES (@title, @short_desc_id, @long_desc_id, @start_date, @final_date)
      ''',
      substitutionValues: {
        'title': title,
        'short_desc_id': shortDescId,
        'long_desc_id': longDescId,
        'start_date': startDate,
        'final_date': finalDate,
      },
    );
  }

*/
/*
Future<int> getOrCreateShortDescId(String text) async {
  final result = await connection.query(
    'SELECT id FROM short_desc WHERE en = @en', 
    substitutionValues: {'en': text},
  );
  if (result.isNotEmpty) return result.first[0] as int;

  final insert = await connection.query(
    'INSERT INTO short_desc(en) VALUES (@en) RETURNING id',
    substitutionValues: {'en': text},
  );
  return insert.first[0] as int;
}

Future<int> getOrCreateLongDescId(String text) async {
  final result = await connection.query(
    'SELECT id FROM long_desc WHERE en = @en', 
    substitutionValues: {'en': text},
  );
  if (result.isNotEmpty) return result.first[0] as int;

  final insert = await connection.query(
    'INSERT INTO long_desc(en) VALUES (@en) RETURNING id',
    substitutionValues: {'en': text},
  );
  return insert.first[0] as int;
}

*/
/*
  Future<void> update({
    required int exhibitId,
    required String title,
    required DateTime startDate,
    required DateTime finalDate,
    required String shortDesc,
    required String longDesc,
  }) async {
    
    final shortDescId = await getOrCreateShortDescId(shortDesc);
    final longDescId = await getOrCreateLongDescId(longDesc);

    await connection.query(
      '''
      UPDATE exhibits
      SET 
          title = @title,
          start_date = @start_date,
          final_date = @final_date,
          short_desc_id = @short_desc_id,
          long_desc_id = @long_desc_id
      WHERE exhibit_id = @exhibit_id
      ''',
      substitutionValues: {
        'title': title,
        'start_date': startDate,
        'final_date': finalDate,
        'short_desc_id': shortDescId,
        'long_desc_id': longDescId,
        'exhibit_id': exhibitId,
      },
    );
  }

  */
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

