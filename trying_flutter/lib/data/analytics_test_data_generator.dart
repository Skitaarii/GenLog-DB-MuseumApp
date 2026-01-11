// Keenan Prusse
// 2025
// Test Data Generator for Analytics

import 'package:postgres/postgres.dart';
import 'dart:math';

class AnalyticsTestDataGenerator {
  final PostgreSQLConnection connection;
  final Random _random = Random();

  AnalyticsTestDataGenerator(this.connection);

  /// Generate realistic visitor sessions for testing analytics
  /// 
  /// Parameters:
  /// - numSessions: Number of visitor sessions to generate
  /// - daysBack: How many days back to generate data
  Future<void> generateTestSessions({
    int numSessions = 50,
    int daysBack = 30,
  }) async {
    print('Generating $numSessions test sessions over $daysBack days...');

    // Get available exhibits and rooms
    final exhibitsResult = await connection.query(
      'SELECT exhibit_id FROM Exhibits ORDER BY exhibit_id'
    );
    final exhibits = exhibitsResult.map((row) => row[0] as int).toList();

    final roomsResult = await connection.query(
      'SELECT room_id FROM Room ORDER BY room_id'
    );
    final rooms = roomsResult.map((row) => row[0] as int).toList();

    if (exhibits.isEmpty || rooms.isEmpty) {
      print('Error: No exhibits or rooms found. Please populate sample data first.');
      return;
    }

    for (int i = 0; i < numSessions; i++) {
      try {
        // Create session
        final sessionResult = await connection.query(
          'INSERT INTO Session DEFAULT VALUES RETURNING session_id'
        );
        final sessionId = sessionResult.first[0] as int;

        // Random date within the last daysBack days
        final daysAgo = _random.nextInt(daysBack);
        final visitDate = DateTime.now().subtract(Duration(days: daysAgo));
        
        // Random start time between 9 AM and 4 PM
        final startHour = 9 + _random.nextInt(7);
        final startMinute = _random.nextInt(60);
        var currentTime = DateTime(
          visitDate.year,
          visitDate.month,
          visitDate.day,
          startHour,
          startMinute,
        );

        // Generate 3-8 scans per session (realistic visitor journey)
        final numScans = 3 + _random.nextInt(6);
        final visitedExhibits = <int>{};
        
        for (int scanNum = 0; scanNum < numScans; scanNum++) {
          // Pick a random exhibit (avoid immediate repeats)
          int exhibitId;
          do {
            exhibitId = exhibits[_random.nextInt(exhibits.length)];
          } while (visitedExhibits.contains(exhibitId) && visitedExhibits.length < exhibits.length);
          
          visitedExhibits.add(exhibitId);

          // Pick a random room
          final roomId = rooms[_random.nextInt(rooms.length)];

          // Record the scan
          await connection.execute(
            '''
            INSERT INTO QR_Scan (session_id, room_id, exhibit_id, scanned_at)
            VALUES (@session_id, @room_id, @exhibit_id, @scanned_at)
            ''',
            substitutionValues: {
              'session_id': sessionId,
              'room_id': roomId,
              'exhibit_id': exhibitId,
              'scanned_at': currentTime,
            },
          );

          // Realistic dwell time: mostly 2-10 minutes, sometimes longer
          int dwellMinutes;
          final rand = _random.nextDouble();
          if (rand < 0.1) {
            dwellMinutes = 1; // Quick scan
          } else if (rand < 0.7) {
            dwellMinutes = 2 + _random.nextInt(8); // Normal dwell (2-10 min)
          } else {
            dwellMinutes = 10 + _random.nextInt(15); // Long dwell (10-25 min)
          }

          currentTime = currentTime.add(Duration(minutes: dwellMinutes));

          // 30% chance to leave feedback
          if (_random.nextDouble() < 0.3) {
            await _generateFeedback(sessionId, exhibitId, currentTime);
          }
        }

        if (i % 10 == 0) {
          print('Generated ${i + 1} / $numSessions sessions...');
        }
      } catch (e) {
        print('Error generating session $i: $e');
      }
    }

    print('✅ Test data generation complete!');
    print('Generated $numSessions visitor sessions with realistic patterns.');
  }

  /// Generate realistic feedback for an exhibit
  Future<void> _generateFeedback(int sessionId, int exhibitId, DateTime timestamp) async {
    // Rating distribution: mostly 4-5, some 3, rare 1-2
    int rating;
    final rand = _random.nextDouble();
    if (rand < 0.05) {
      rating = 1; // 5% very negative
    } else if (rand < 0.15) {
      rating = 2; // 10% negative
    } else if (rand < 0.30) {
      rating = 3; // 15% neutral
    } else if (rand < 0.65) {
      rating = 4; // 35% positive
    } else {
      rating = 5; // 35% very positive
    }

    // Generate comment based on rating
    final comments = _getCommentsForRating(rating);
    final comment = comments[_random.nextInt(comments.length)];

    await connection.execute(
      '''
      INSERT INTO Feedback (exhibit_id, session_id, comment, rating, made_at)
      VALUES (@exhibit_id, @session_id, @comment, @rating, @made_at)
      ''',
      substitutionValues: {
        'exhibit_id': exhibitId,
        'session_id': sessionId,
        'comment': comment,
        'rating': rating,
        'made_at': timestamp,
      },
    );
  }

  List<String> _getCommentsForRating(int rating) {
    switch (rating) {
      case 5:
        return [
          'Absolutely stunning! A must-see.',
          'One of the best exhibits I\'ve ever seen.',
          'Incredible detail and presentation.',
          'My favorite part of the museum!',
          'Worth the visit alone.',
          'Beautifully curated and informative.',
        ];
      case 4:
        return [
          'Very interesting and well presented.',
          'Great exhibit, learned a lot.',
          'Impressive collection.',
          'Really enjoyed this one.',
          'Well worth seeing.',
          'Fascinating history.',
        ];
      case 3:
        return [
          'Interesting but could use more context.',
          'Good but not exceptional.',
          'Worth a quick look.',
          'Some parts were better than others.',
          'Decent exhibit.',
        ];
      case 2:
        return [
          'Expected more based on the description.',
          'Could be improved with better lighting.',
          'Somewhat disappointing.',
          'Not much to see here.',
          'Needs better signage.',
        ];
      case 1:
        return [
          'Very disappointing.',
          'Not worth the time.',
          'Poor presentation.',
          'Expected much more.',
          'Needs major improvements.',
        ];
      default:
        return ['No comment'];
    }
  }

  /// Generate a realistic visitor journey with specific patterns
  /// Useful for testing path analysis
  Future<void> generatePopularPathScenario() async {
    print('Generating popular path scenario...');

    // Get rooms and exhibits
    final roomsResult = await connection.query('SELECT room_id FROM Room ORDER BY room_id');
    final rooms = roomsResult.map((row) => row[0] as int).toList();

    if (rooms.length < 3) {
      print('Need at least 3 rooms for path scenario');
      return;
    }

    // Create a popular path: Room 1 -> Room 2 -> Room 3
    // 40% of visitors follow this exact path
    for (int i = 0; i < 20; i++) {
      final sessionResult = await connection.query(
        'INSERT INTO Session DEFAULT VALUES RETURNING session_id'
      );
      final sessionId = sessionResult.first[0] as int;

      final startTime = DateTime.now().subtract(Duration(days: _random.nextInt(7)));
      var currentTime = startTime;

      // Scan room 1
      await _scanRoom(sessionId, rooms[0], currentTime);
      currentTime = currentTime.add(Duration(minutes: 5 + _random.nextInt(10)));

      // Scan room 2
      await _scanRoom(sessionId, rooms[1], currentTime);
      currentTime = currentTime.add(Duration(minutes: 5 + _random.nextInt(10)));

      // Scan room 3
      await _scanRoom(sessionId, rooms[2], currentTime);
    }

    print('✅ Popular path scenario generated!');
  }

  Future<void> _scanRoom(int sessionId, int roomId, DateTime timestamp) async {
    // Get random exhibit in this room
    final result = await connection.query(
      '''
      SELECT exhibit_id FROM Room_Exhibit 
      WHERE room_id = @room_id 
      ORDER BY RANDOM() 
      LIMIT 1
      ''',
      substitutionValues: {'room_id': roomId},
    );

    if (result.isEmpty) return;

    final exhibitId = result.first[0] as int;

    await connection.execute(
      '''
      INSERT INTO QR_Scan (session_id, room_id, exhibit_id, scanned_at)
      VALUES (@session_id, @room_id, @exhibit_id, @scanned_at)
      ''',
      substitutionValues: {
        'session_id': sessionId,
        'room_id': roomId,
        'exhibit_id': exhibitId,
        'scanned_at': timestamp,
      },
    );
  }

  /// Clear all test data (sessions, scans, feedback)
  Future<void> clearTestData() async {
    print('Clearing test data...');
    
    await connection.execute('DELETE FROM Feedback');
    await connection.execute('DELETE FROM QR_Scan');
    await connection.execute('DELETE FROM Session');
    
    print('✅ Test data cleared!');
  }
}