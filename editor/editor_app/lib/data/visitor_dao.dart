// Gaëtan Veuillet
// 2025


import 'package:postgres/postgres.dart';
import 'package:editor_app/data/visitor.dart';

class VisitorDao {
  final PostgreSQLConnection connection;

  VisitorDao(this.connection);

  //Get exhibit detail by its id
  Future<ExhibitDetails?> getExhibitDetails(int exhibitId) async {
    try {
      final exhibitResult = await connection.query('''
        SELECT 
          e.exhibit_id, 
          e.title, 
          sd.en as short_desc, 
          ld.en as long_desc,
          e.start_date, 
          e.final_date,
          i.img_path
        FROM Exhibits e
        LEFT JOIN Short_Desc sd ON e.short_desc_id = sd.id
        LEFT JOIN Long_Desc ld ON e.long_desc_id = ld.id
        LEFT JOIN Images i ON e.exhibit_id = i.exhibit_id AND i.img_path IS NOT NULL
        WHERE e.exhibit_id = @exhibitId
        LIMIT 1
      ''', substitutionValues: {'exhibitId': exhibitId});

      if (exhibitResult.isEmpty) {
        return null;
      }

      final row = exhibitResult.first;

      //Get the era
      String? eraName;
      final eraResult = await connection.query('''
        SELECT era.era_name_EN
        FROM Tags t
        JOIN TagEra te ON t.tag_id = te.tag_id
        JOIN Eras era ON te.era_id = era.era_id
        WHERE t.exhibit_id = @exhibitId
        LIMIT 1
      ''', substitutionValues: {'exhibitId': exhibitId});

      if (eraResult.isNotEmpty) {
        eraName = eraResult.first[0] as String;
      }

      //Get the themes
      final themesResult = await connection.query('''
        SELECT thm.thm_name_EN
        FROM Tags t
        JOIN TagTheme tt ON t.tag_id = tt.tag_id
        JOIN Themes thm ON tt.theme_id = thm.theme_id
        WHERE t.exhibit_id = @exhibitId
      ''', substitutionValues: {'exhibitId': exhibitId});

      final themes = themesResult
          .map((row) => row[0] as String)
          .toList();

      //Get linked exhibits 
      //TODO : MADE IT FORM SIMILAR ERA AND THEME, WE NEED TO SEE WHAT ELSE COULD BE USE
      final relatedResult = await connection.query('''
        SELECT DISTINCT e2.exhibit_id, e2.title
        FROM Exhibits e2
        WHERE e2.exhibit_id != @exhibitId
        AND (
          -- Mêmes thèmes
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
          -- Même ère
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
        imagePath: row.toColumnMap()['img_path'] as String?,
      );
    } catch (e) {
      print('Error fetching exhibit details: $e');
      return null;
    }
  }

//Feedback 
Future<bool> submitFeedback({
  required int exhibitId,
  required int sessionId,
  required String comment,
  required int rating,
}) async {
  try {
    //Verify if the session already exist
    final sessionCheck = await connection.query(
      'SELECT session_id FROM Session WHERE session_id = @sessionId',
      substitutionValues: {'sessionId': sessionId},
    );
    
    if (sessionCheck.isEmpty) {
      print('Session $sessionId does not exist, creating it...');
      //Create the session
      await connection.execute(
        'INSERT INTO Session (session_id) VALUES (@sessionId)',
        substitutionValues: {'sessionId': sessionId},
      );
    }
    
    //Once session made -> make the feedback
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

  //Qrcode
  Future<bool> recordQRScan({
    required int sessionId,
    required int roomId,
    required int exhibitId,
  }) async {
    try {
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

  //Create a new session globally

Future<int> createNewSession() async {
  try {
    final result = await connection.query('''
      INSERT INTO Session DEFAULT VALUES 
      RETURNING session_id
    ''');
    
    final sessionId = result.first[0] as int;
    print('New session created in database: $sessionId');
    return sessionId;
  } catch (e) {
    print('Error creating session: $e');
    //Only for debug, if it can't create a session, we just try to log to an existant one 
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
    return 1; // Fallback to id 1
  }
}

  //Get the historic of scan session
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

Future<double> getExhibitAverageRating(int exhibitId) async {
  try {
    final result = await connection.query('''
      SELECT AVG(rating::float) as avg_rating
      FROM Feedback
      WHERE exhibit_id = @exhibitId
    ''', substitutionValues: {'exhibitId': exhibitId});

    if (result.isEmpty || result.first[0] == null) {
      return 0.0;
    }
    
    final avgValue = result.first[0];
    
    //Be sure that the type is double (had some problem with int)
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

  //Get all the feedback to show on the exhibit page
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
}