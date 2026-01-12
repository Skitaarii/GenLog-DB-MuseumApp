// Gaëtan Veuillet
// 2025
// Visitor Data Access Object - Handles all database operations related to visitor interactions

import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/visitor.dart';
import 'package:visitor_app/utils/language_manager.dart';
import 'dart:typed_data'; // For handling binary image data

class VisitorDao {
  final PostgreSQLConnection connection;

  VisitorDao(this.connection);

  // Get comprehensive exhibit details including descriptions, themes, era, images and related exhibits
  Future<ExhibitDetails?> getExhibitDetails(int exhibitId) async {
  try {
    // Get current language column (FR, EN, IT, DE) from LanguageManager
    final lang = LanguageManager().dbColumnName;
    
    // Query exhibit basic information with language-specific descriptions
    final exhibitResult = await connection.query('''
      SELECT 
        e.exhibit_id, 
        e.title, 
        sd.$lang as short_desc, 
        ld.$lang as long_desc,
        e.start_date, 
        e.final_date
      FROM Exhibits e
      LEFT JOIN Short_Desc sd ON e.short_desc_id = sd.id
      LEFT JOIN Long_Desc ld ON e.long_desc_id = ld.id
      LEFT JOIN Images i ON e.exhibit_id = i.exhibit_id
      WHERE e.exhibit_id = @exhibitId
      LIMIT 1
    ''', substitutionValues: {'exhibitId': exhibitId});

    if (exhibitResult.isEmpty) {
      return null; // Exhibit not found
    }

    final row = exhibitResult.first;

    // Get era information for the exhibit
    String? eraName;
    final eraResult = await connection.query('''
      SELECT era.era_name_$lang
      FROM Tags t
      JOIN TagEra te ON t.tag_id = te.tag_id
      JOIN Eras era ON te.era_id = era.era_id
      WHERE t.exhibit_id = @exhibitId
      LIMIT 1
    ''', substitutionValues: {'exhibitId': exhibitId});

    if (eraResult.isNotEmpty) {
      eraName = eraResult.first[0] as String;
    }

    // Get all theme tags for the exhibit
    final themesResult = await connection.query('''
      SELECT thm.thm_name_$lang
      FROM Tags t
      JOIN TagTheme tt ON t.tag_id = tt.tag_id
      JOIN Themes thm ON tt.theme_id = thm.theme_id
      WHERE t.exhibit_id = @exhibitId
    ''', substitutionValues: {'exhibitId': exhibitId});

    final themes = themesResult
        .map((row) => row[0] as String)
        .toList();

    // Get related exhibits (sharing themes or era)
    final relatedResult = await connection.query('''
      SELECT DISTINCT e2.exhibit_id, e2.title
      FROM Exhibits e2
      WHERE e2.exhibit_id != @exhibitId
      AND (
        EXISTS (
          SELECT 1 FROM Tags t2
          JOIN TagTheme tt2 ON t2.tag_id = tt2.tag_id
          WHERE t2.exhibit_id = e2.exhibit_id
          AND tt2.theme_id IN (
            SELECT tt.theme_id
            FROM Tags t
            JOIN TagTheme tt ON t.tag_id = tt.tag_id
            WHERE t.exhibit_id = @exhibitId
          )
        )
        OR
        EXISTS (
          SELECT 1 FROM Tags t2
          JOIN TagEra te2 ON t2.tag_id = te2.tag_id
          WHERE t2.exhibit_id = e2.exhibit_id
          AND te2.era_id IN (
            SELECT te.era_id
            FROM Tags t
            JOIN TagEra te ON t.tag_id = te.tag_id
            WHERE t.exhibit_id = @exhibitId
          )
        )
      )
      LIMIT 5
    ''', substitutionValues: {'exhibitId': exhibitId});

    final relatedExhibits = relatedResult
        .map((row) => RelatedExhibit(
              exhibit_id: row[0] as int,
              title: row[1] as String,
            ))
        .toList();

    // Fetch associated images for the exhibit
    final images = await getExhibitImages(exhibitId);

    // Construct and return the complete ExhibitDetails object
    return ExhibitDetails(
      exhibit_id: row.toColumnMap()['exhibit_id'] as int,
      title: row.toColumnMap()['title'] as String,
      shortDesc: row.toColumnMap()['short_desc'] as String? ?? 'No description available',
      longDesc: row.toColumnMap()['long_desc'] as String? ?? 'No detailed description available',
      startDate: row.toColumnMap()['start_date'] as DateTime?,
      finalDate: row.toColumnMap()['final_date'] as DateTime?,
      eraName: eraName,
      themes: themes,
      relatedExhibits: relatedExhibits,
      images: images, // Include fetched images
    );
  } catch (e) {
    print('Error fetching exhibit details: $e');
    return null;
  }
}

  // Submit feedback (rating and comment) for an exhibit
  Future<bool> submitFeedback({
    required int exhibitId,
    required int sessionId,
    required String comment,
    required int rating,
  }) async {
    try {
      // Verify if the session exists in the database
      final sessionCheck = await connection.query(
        'SELECT session_id FROM Session WHERE session_id = @sessionId',
        substitutionValues: {'sessionId': sessionId},
      );
      
      // Create session if it doesn't exist
      if (sessionCheck.isEmpty) {
        print('Session $sessionId does not exist, creating it...');
        await connection.execute(
          'INSERT INTO Session (session_id) VALUES (@sessionId)',
          substitutionValues: {'sessionId': sessionId},
        );
      }
      
      // Insert feedback record
      await connection.execute('''
        INSERT INTO Feedback (
          exhibit_id, 
          session_id, 
          comment, 
          rating, 
          made_at
        ) VALUES (
          @exhibitId, 
          @sessionId, 
          @comment, 
          @rating, 
          @madeAt
        )
      ''', substitutionValues: {
        'exhibitId': exhibitId,
        'sessionId': sessionId,
        'comment': comment,
        'rating': rating,
        'madeAt': DateTime.now(),
      });
      
      print('Feedback submitted successfully for exhibit $exhibitId, session $sessionId');
      return true;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Record a QR scan event in the database
  Future<bool> recordQRScan({
    required int sessionId,
    required int roomId,
    required int exhibitId,
  }) async {
    try {
      // Get the room_id from the database based on the exhibit_id
      final result = await connection.query(
        'SELECT room_id FROM room_exhibit WHERE exhibit_id = @exhibitId',
        substitutionValues: {'exhibitId': exhibitId},
      );

      if (result.isEmpty) {
        print('Exhibit not found (ID: $exhibitId)');
        return false;
      }

      final roomId = result.first.toColumnMap()['room_id'] as int;

      // Insert QR scan record
      await connection.execute('''
        INSERT INTO QR_Scan (
          session_id, 
          room_id, 
          exhibit_id, 
          scanned_at
        ) VALUES (
          @sessionId, 
          @roomId, 
          @exhibitId, 
          @scannedAt
        )
      ''', substitutionValues: {
        'sessionId': sessionId,
        'roomId': roomId,
        'exhibitId': exhibitId,
        'scannedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error recording QR scan: $e');
      return false;
    }
  }

  // Create a new visitor session globally
  Future<int> createNewSession() async {
    try {
      // Insert new session and return its ID
      final result = await connection.query('''
        INSERT INTO Session DEFAULT VALUES 
        RETURNING session_id
      ''');
      
      final sessionId = result.first[0] as int;
      print('New session created in database: $sessionId');
      return sessionId;
    } catch (e) {
      print('Error creating session: $e');
      // Fallback: try to use an existing session if creation fails
      try {
        final result = await connection.query(
          'SELECT session_id FROM Session LIMIT 1'
        );
        if (result.isNotEmpty) {
          final existingSessionId = result.first[0] as int;
          print('Using existing session: $existingSessionId');
          return existingSessionId;
        }
      } catch (e2) {
        print('Error fetching existing session: $e2');
      }
      return 1; // Final fallback to ID 1
    }
  }

  // Get scan history for a specific session
  Future<List<QRScan>> getSessionScans(int sessionId) async {
    try {
      final result = await connection.query('''
        SELECT session_id, room_id, exhibit_id, scanned_at
        FROM QR_Scan
        WHERE session_id = @sessionId
        ORDER BY scanned_at DESC
      ''', substitutionValues: {'sessionId': sessionId});

      return result
          .map((row) => QRScan(
                session_id: row[0] as int,
                room_id: row[1] as int,
                exhibit_id: row[2] as int,
                scanned_at: row[3] as DateTime,
              ))
          .toList();
    } catch (e) {
      print('Error fetching session scans: $e');
      return [];
    }
  }

  // Calculate average rating for an exhibit
  Future<double> getExhibitAverageRating(int exhibitId) async {
    try {
      final result = await connection.query('''
        SELECT AVG(rating::float) as avg_rating
        FROM Feedback
        WHERE exhibit_id = @exhibitId
      ''', substitutionValues: {'exhibitId': exhibitId});

      if (result.isEmpty || result.first[0] == null) {
        return 0.0; // No ratings yet
      }
      
      final avgValue = result.first[0];
      
      // Handle different return types from PostgreSQL
      if (avgValue is double) {
        return avgValue;
      } else if (avgValue is int) {
        return avgValue.toDouble();
      } else if (avgValue is String) {
        return double.tryParse(avgValue) ?? 0.0;
      } else if (avgValue is num) {
        return avgValue.toDouble();
      }
      
      return 0.0;
    } catch (e) {
      print('Error fetching average rating: $e');
      return 0.0;
    }
  }

  // Get all feedback entries for an exhibit
  Future<List<ExhibitFeedback>> getExhibitFeedbacks(int exhibitId) async {
    try {
      final result = await connection.query('''
        SELECT exhibit_id, comment, rating, made_at
        FROM Feedback
        WHERE exhibit_id = @exhibitId
        ORDER BY made_at DESC
      ''', substitutionValues: {'exhibitId': exhibitId});

      return result
          .map((row) => ExhibitFeedback(
                exhibit_id: row[0] as int,
                comment: row[1] as String,
                rating: row[2] as int,
                createdAt: row[3] as DateTime,
              ))
          .toList();
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }

  // Get all images associated with an exhibit
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
        imageData: row[1] as Uint8List, // Binary image data
        altText: row[2] as String,
      );
    }).toList();
  }

  // Delete a specific image from the database
  Future<void> deleteImage(int imageId) async {
    await connection.query(
      'DELETE FROM images WHERE image_id = @id',
      substitutionValues: {'id': imageId},
    );
  }
}