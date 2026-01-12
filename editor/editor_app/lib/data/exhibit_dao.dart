// Veuillet Gaëtan
// 2025
// Data Access Object for Exhibit entity with image support

import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:editor_app/data/exhibit.dart';
import 'dart:typed_data';
import 'dart:convert';

/// Image model for storing exhibit photos with metadata
class ExhibitImage {
  final int? imageId;
  final Uint8List imageData;
  final String altText;

  ExhibitImage({
    this.imageId,
    required this.imageData,
    required this.altText,
  });
}

class Room {
  final int room_id;
  final String name;

  Room({
    required this.room_id,
    required this.name,
  });
}

/// DAO for exhibit management including multilingual descriptions and images
/// WARNING: Current description system only supports English
class ExhibitDao {
  final PostgreSQLConnection connection;

  ExhibitDao(this.connection);

  /// Creates a new exhibit and returns its generated ID
  Future<int> insertExhibit({
    required String title,
    DateTime? startDate,
    DateTime? finalDate,
    required int shortDescId,
    required int longDescId,
  }) async {
    final result = await connection.query(
      '''
      INSERT INTO exhibits(title, short_desc_id, long_desc_id, start_date, final_date)
      VALUES (@title, @short_desc_id, @long_desc_id, @start_date, @final_date)
      RETURNING exhibit_id
      ''',
      substitutionValues: {
        'title': title,
        'short_desc_id': shortDescId,
        'long_desc_id': longDescId,
        'start_date': startDate,
        'final_date': finalDate,
      },
    );
    return result.first[0] as int;
  }

  // TODO: Implement multilingual description support
  // Currently only works with English ('en' column)

  /// Gets existing short description ID or creates new English entry
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

  /// Gets existing long description ID or creates new English entry
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

  /// Updates all exhibit fields including descriptions
  Future<void> update({
    required int exhibitId,
    required String title,
    required DateTime? startDate,
    required DateTime? finalDate,
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

  /// Permanently deletes an exhibit (cascades to all related table)
  Future<void> deleteExhibit(int exhibitId) async {
  final conn = connection;

  await conn.query(
    '''
    DELETE FROM TagEra 
    WHERE tag_id IN (SELECT tag_id FROM Tags WHERE exhibit_id = @id)
    ''',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    '''
    DELETE FROM TagTheme
    WHERE tag_id IN (SELECT tag_id FROM Tags WHERE exhibit_id = @id)
    ''',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Tags WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Room_Exhibit WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Itinerary_Exhibit WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM QR_Scan WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Feedback WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Related_exhibits WHERE exhibit1_id = @id OR exhibit2_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Favorites WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Images WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

  await conn.query(
    'DELETE FROM Exhibits WHERE exhibit_id = @id',
    substitutionValues: {'id': exhibitId},
  );

}


  /// Gets raw exhibit data by ID (returns PostgreSQL rows)
  Future<List<List<dynamic>>> getExhibitById(int id) async {
    return await connection.query(
      '''
      SELECT * FROM exhibits WHERE exhibit_id = @id
      ''',
      substitutionValues: {'id': id},
    );
  }

  /// Retrieves all exhibits without description text
  Future<List<Exhibit>> getAllExhibits() async {
    final result = await connection.query(
      'SELECT exhibit_id, title, short_desc_id, long_desc_id, start_date, final_date FROM exhibits',
    );

    return result.map((row){
      return Exhibit(
        exhibit_id: row[0] as int,
        title: row[1] as String,
        short_desc_id: row[2] as int,
        long_desc_id: row[3] as int,
        startDate: row[4] as DateTime?,
        finalDate: row[5] as DateTime?,
      );
    }).toList();
  }

  /// Inserts an image for an exhibit using base64 encoding for binary data
  Future<void> insertImage({
    required int exhibitId,
    required Uint8List imageData,
    required String altText,
  }) async {
    final base64Image = base64Encode(imageData);
    await connection.query(
      '''
      INSERT INTO images(exhibit_id, img_data, alt_text)
      VALUES (@exhibit_id, decode(@img_data, 'base64'), @alt_text)
      ''',
      substitutionValues: {
        'exhibit_id': exhibitId,
        'img_data': base64Image,
        'alt_text': altText,
      },
    );
  }

  /// Retrieves all images associated with an exhibit
  Future<List<ExhibitImage>> getExhibitImages(int exhibitId) async {
    final result = await connection.query(
      '''
      SELECT image_id, img_data, alt_text
      FROM images
      WHERE exhibit_id = @exhibit_id
      ORDER BY image_id
      ''',
      substitutionValues: {'exhibit_id': exhibitId},
    );

    return result.map((row) {
      return ExhibitImage(
        imageId: row[0] as int,
        imageData: row[1] as Uint8List,
        altText: row[2] as String,
      );
    }).toList();
  }

  /// Deletes a specific image by its ID
  Future<void> deleteImage(int imageId) async {
    await connection.query(
      'DELETE FROM images WHERE image_id = @id',
      substitutionValues: {'id': imageId},
    );
  }

  Future<List<Room>> getExhibitRooms(int exhibitId) async {
  final result = await connection.query(
    '''
    SELECT r.room_id, r.name 
    FROM Room r
    JOIN Room_Exhibit re ON r.room_id = re.room_id
    WHERE re.exhibit_id = @exhibitId
    ''',
    substitutionValues: {'exhibitId': exhibitId},
  );
  
  return result.map((row) => Room(
    room_id: row[0] as int,
    name: row[1] as String,
  )).toList();
}
}