// Keenan Prusse
// 2025
// Analytics Data Access Object - provides curator insights

import 'package:postgres/postgres.dart';
import 'package:trying_flutter/data/analytics.dart';

class AnalyticsDao {
  final PostgreSQLConnection connection;

  AnalyticsDao(this.connection);

  // Helper function to safely convert database values to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  // Helper function to safely convert database values to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  /// Calculate median and average dwell time per exhibit
  /// Dwell time is approximated as time between consecutive scans in the same session
  Future<List<DwellTimeStats>> getExhibitDwellStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await connection.query('''
        WITH scan_sequences AS (
          SELECT 
            qs1.session_id,
            qs1.exhibit_id,
            qs1.scanned_at,
            qs2.scanned_at AS next_scan,
            EXTRACT(EPOCH FROM (qs2.scanned_at - qs1.scanned_at)) AS dwell_seconds
          FROM QR_Scan qs1
          LEFT JOIN QR_Scan qs2 
            ON qs1.session_id = qs2.session_id 
            AND qs2.scanned_at > qs1.scanned_at
            AND NOT EXISTS (
              SELECT 1 FROM QR_Scan qs3
              WHERE qs3.session_id = qs1.session_id
                AND qs3.scanned_at > qs1.scanned_at
                AND qs3.scanned_at < qs2.scanned_at
            )
          WHERE 1=1
            ${startDate != null ? "AND qs1.scanned_at >= @startDate" : ""}
            ${endDate != null ? "AND qs1.scanned_at <= @endDate" : ""}
        ),
        exhibit_stats AS (
          SELECT 
            e.exhibit_id,
            e.title,
            COUNT(DISTINCT ss.session_id) AS total_visits,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ss.dwell_seconds) AS median_dwell_sec,
            CAST(AVG(ss.dwell_seconds) AS INTEGER) AS avg_dwell_sec,  -- ⭐ Add CAST,
            COALESCE(AVG(f.rating::numeric), 0) AS avg_rating
          FROM Exhibits e
          LEFT JOIN scan_sequences ss ON e.exhibit_id = ss.exhibit_id
          LEFT JOIN Feedback f ON e.exhibit_id = f.exhibit_id
          WHERE ss.dwell_seconds IS NOT NULL
            AND ss.dwell_seconds > 0
            AND ss.dwell_seconds < 3600
          GROUP BY e.exhibit_id, e.title
        )
        SELECT 
          exhibit_id,
          title,
          median_dwell_sec,
          avg_dwell_sec,
          total_visits,
          avg_rating
        FROM exhibit_stats
        ORDER BY total_visits DESC
      ''', substitutionValues: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });

      return result.map((row) {
        return DwellTimeStats(
          exhibitId: _toInt(row[0]),
          exhibitTitle: row[1] as String,
          medianDwell: Duration(seconds: _toInt(row[2])),
          averageDwell: Duration(seconds: _toInt(row[3])),
          totalVisits: _toInt(row[4]),
          averageRating: _toDouble(row[5]),
        );
      }).toList();
    } catch (e) {
      print('Error fetching dwell stats: $e');
      return [];
    }
  }

  /// Get most common room-to-room transitions
  Future<List<PathSegment>> getPopularPaths({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      final result = await connection.query('''
        WITH path_transitions AS (
          SELECT 
            qs1.room_id AS from_room,
            qs2.room_id AS to_room,
            COUNT(*) AS transition_count
          FROM QR_Scan qs1
          JOIN QR_Scan qs2 
            ON qs1.session_id = qs2.session_id
            AND qs2.scanned_at > qs1.scanned_at
            AND NOT EXISTS (
              SELECT 1 FROM QR_Scan qs3
              WHERE qs3.session_id = qs1.session_id
                AND qs3.scanned_at > qs1.scanned_at
                AND qs3.scanned_at < qs2.scanned_at
            )
          WHERE qs1.room_id != qs2.room_id
            ${startDate != null ? "AND qs1.scanned_at >= @startDate" : ""}
            ${endDate != null ? "AND qs1.scanned_at <= @endDate" : ""}
          GROUP BY qs1.room_id, qs2.room_id
        )
        SELECT 
          pt.from_room,
          pt.to_room,
          r1.name AS from_room_name,
          r2.name AS to_room_name,
          pt.transition_count
        FROM path_transitions pt
        JOIN Room r1 ON pt.from_room = r1.room_id
        JOIN Room r2 ON pt.to_room = r2.room_id
        ORDER BY pt.transition_count DESC
        LIMIT @limit
      ''', substitutionValues: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        'limit': limit,
      });

      return result.map((row) {
        return PathSegment(
          fromRoomId: _toInt(row[0]),
          toRoomId: _toInt(row[1]),
          fromRoomName: row[2] as String,
          toRoomName: row[3] as String,
          transitionCount: _toInt(row[4]),
        );
      }).toList();
    } catch (e) {
      print('Error fetching popular paths: $e');
      return [];
    }
  }

  /// Get entry and exit points (first and last scans per session)
  Future<List<EntryExitPoint>> getEntryExitPoints({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await connection.query('''
        WITH session_bounds AS (
          SELECT 
            session_id,
            FIRST_VALUE(room_id) OVER (PARTITION BY session_id ORDER BY scanned_at) AS entry_room,
            LAST_VALUE(room_id) OVER (PARTITION BY session_id ORDER BY scanned_at 
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS exit_room
          FROM QR_Scan
          WHERE 1=1
            ${startDate != null ? "AND scanned_at >= @startDate" : ""}
            ${endDate != null ? "AND scanned_at <= @endDate" : ""}
        ),
        entry_counts AS (
          SELECT entry_room AS room_id, COUNT(DISTINCT session_id) AS entry_count
          FROM session_bounds
          GROUP BY entry_room
        ),
        exit_counts AS (
          SELECT exit_room AS room_id, COUNT(DISTINCT session_id) AS exit_count
          FROM session_bounds
          GROUP BY exit_room
        )
        SELECT 
          r.room_id,
          r.name,
          COALESCE(ec.entry_count, 0) AS entry_count,
          COALESCE(ex.exit_count, 0) AS exit_count
        FROM Room r
        LEFT JOIN entry_counts ec ON r.room_id = ec.room_id
        LEFT JOIN exit_counts ex ON r.room_id = ex.room_id
        WHERE COALESCE(ec.entry_count, 0) > 0 OR COALESCE(ex.exit_count, 0) > 0
        ORDER BY entry_count DESC, exit_count DESC
      ''', substitutionValues: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });

      return result.map((row) {
        return EntryExitPoint(
          roomId: _toInt(row[0]),
          roomName: row[1] as String,
          entryCount: _toInt(row[2]),
          exitCount: _toInt(row[3]),
        );
      }).toList();
    } catch (e) {
      print('Error fetching entry/exit points: $e');
      return [];
    }
  }

  /// Identify exhibits with interesting patterns
  Future<List<ExhibitPerformance>> getExhibitPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await connection.query('''
        WITH scan_sequences AS (
          SELECT 
            qs1.exhibit_id,
            EXTRACT(EPOCH FROM (qs2.scanned_at - qs1.scanned_at)) AS dwell_seconds
          FROM QR_Scan qs1
          LEFT JOIN QR_Scan qs2 
            ON qs1.session_id = qs2.session_id 
            AND qs2.scanned_at > qs1.scanned_at
            AND NOT EXISTS (
              SELECT 1 FROM QR_Scan qs3
              WHERE qs3.session_id = qs1.session_id
                AND qs3.scanned_at > qs1.scanned_at
                AND qs3.scanned_at < qs2.scanned_at
            )
          WHERE qs2.scanned_at IS NOT NULL
            AND EXTRACT(EPOCH FROM (qs2.scanned_at - qs1.scanned_at)) BETWEEN 1 AND 3600
            ${startDate != null ? "AND qs1.scanned_at >= @startDate" : ""}
            ${endDate != null ? "AND qs1.scanned_at <= @endDate" : ""}
        ),
        exhibit_metrics AS (
          SELECT 
            e.exhibit_id,
            e.title,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ss.dwell_seconds) AS median_dwell_sec,
            COUNT(DISTINCT ss.dwell_seconds) AS visit_count,
            COALESCE(AVG(f.rating::numeric), 0) AS avg_rating,
            COUNT(f.rating) AS feedback_count
          FROM Exhibits e
          LEFT JOIN scan_sequences ss ON e.exhibit_id = ss.exhibit_id
          LEFT JOIN Feedback f ON e.exhibit_id = f.exhibit_id
          GROUP BY e.exhibit_id, e.title
        )
        SELECT 
          exhibit_id,
          title,
          median_dwell_sec,
          avg_rating,
          visit_count,
          feedback_count
        FROM exhibit_metrics
        WHERE visit_count > 0
        ORDER BY visit_count DESC
      ''', substitutionValues: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });

      return result.map((row) {
        final medianDwell = Duration(seconds: _toInt(row[2]));
        final avgRating = _toDouble(row[3]);
        
        // Categorize performance
        String category;
        if (medianDwell.inMinutes >= 5 && avgRating >= 4.0) {
          category = 'high-engagement';
        } else if (medianDwell.inMinutes >= 5 && avgRating < 3.5) {
          category = 'confusing';
        } else if (medianDwell.inMinutes < 3 && avgRating >= 4.0) {
          category = 'clear-and-concise';
        } else if (medianDwell.inMinutes < 3 && avgRating < 3.5) {
          category = 'low-engagement';
        } else {
          category = 'moderate';
        }

        return ExhibitPerformance(
          exhibitId: _toInt(row[0]),
          exhibitTitle: row[1] as String,
          medianDwell: medianDwell,
          averageRating: avgRating,
          totalVisits: _toInt(row[4]),
          feedbackCount: _toInt(row[5]),
          performanceCategory: category,
        );
      }).toList();
    } catch (e) {
      print('Error fetching exhibit performance: $e');
      return [];
    }
  }

Future<List<DailyStats>> getDailyStats({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  try {
    final result = await connection.query('''
      WITH daily_sessions AS (
        SELECT 
          DATE(scanned_at) AS visit_date,
          session_id,
          MIN(scanned_at) AS first_scan,
          MAX(scanned_at) AS last_scan,
          COUNT(DISTINCT exhibit_id) AS unique_exhibits,
          COUNT(*) AS total_scans
        FROM QR_Scan
        WHERE 1=1
          ${startDate != null ? "AND scanned_at >= @startDate" : ""}
          ${endDate != null ? "AND scanned_at <= @endDate" : ""}
        GROUP BY DATE(scanned_at), session_id
        HAVING COUNT(*) > 1  -- ⭐ Only sessions with 2+ scans
      )
      SELECT 
        visit_date,
        COUNT(DISTINCT session_id) AS total_sessions,
        SUM(total_scans) AS total_scans,
        CAST(AVG(EXTRACT(EPOCH FROM (last_scan - first_scan))) AS INTEGER) AS avg_visit_duration_sec,
        CAST(AVG(unique_exhibits) AS INTEGER) AS avg_unique_exhibits
      FROM daily_sessions
      WHERE EXTRACT(EPOCH FROM (last_scan - first_scan)) > 0
      GROUP BY visit_date
      ORDER BY visit_date DESC
    ''', substitutionValues: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });

    return result.map((row) {
      return DailyStats(
        date: row[0] as DateTime,
        totalSessions: _toInt(row[1]),
        totalScans: _toInt(row[2]),
        averageVisitDuration: Duration(seconds: _toInt(row[3])),
        uniqueExhibitsViewed: _toInt(row[4]),
      );
    }).toList();
  } catch (e) {
    print('Error fetching daily stats: $e');
    return [];
  }
}

  Future<List<RoomPopularity>> getRoomPopularity({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await connection.query('''
        WITH room_visits AS (
          SELECT 
            qs1.room_id,
            qs1.session_id,
            EXTRACT(EPOCH FROM (qs2.scanned_at - qs1.scanned_at)) AS dwell_seconds
          FROM QR_Scan qs1
          LEFT JOIN QR_Scan qs2 
            ON qs1.session_id = qs2.session_id 
            AND qs2.scanned_at > qs1.scanned_at
            AND NOT EXISTS (
              SELECT 1 FROM QR_Scan qs3
              WHERE qs3.session_id = qs1.session_id
                AND qs3.scanned_at > qs1.scanned_at
                AND qs3.scanned_at < qs2.scanned_at
            )
          WHERE 1=1
            ${startDate != null ? "AND qs1.scanned_at >= @startDate" : ""}
            ${endDate != null ? "AND qs1.scanned_at <= @endDate" : ""}
        )
        SELECT 
          r.room_id,
          r.name,
          COUNT(DISTINCT rv.session_id) AS visit_count,
          AVG(rv.dwell_seconds) AS avg_dwell_sec,
          COUNT(DISTINCT re.exhibit_id) AS exhibit_count
        FROM Room r
        LEFT JOIN room_visits rv ON r.room_id = rv.room_id
        LEFT JOIN Room_Exhibit re ON r.room_id = re.room_id
        WHERE rv.session_id IS NOT NULL
        GROUP BY r.room_id, r.name
        ORDER BY visit_count DESC
      ''', substitutionValues: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });

      return result.map((row) {
        return RoomPopularity(
          roomId: _toInt(row[0]),
          roomName: row[1] as String,
          visitCount: _toInt(row[2]),
          averageDwell: Duration(seconds: _toInt(row[3])),
          exhibitCount: _toInt(row[4]),
        );
      }).toList();
    } catch (e) {
      print('Error fetching room popularity: $e');
      return [];
    }
  }

  /// Generate CSV export data
  Future<String> generateCsvExport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await connection.query('''
        SELECT 
          DATE(qs.scanned_at) AS visit_date,
          qs.session_id,
          qs.exhibit_id,
          e.title AS exhibit_title,
          qs.room_id,
          r.name AS room_name,
          qs.scanned_at,
          f.rating
        FROM QR_Scan qs
        JOIN Exhibits e ON qs.exhibit_id = e.exhibit_id
        JOIN Room r ON qs.room_id = r.room_id
        LEFT JOIN Feedback f ON qs.exhibit_id = f.exhibit_id AND qs.session_id = f.session_id
        WHERE 1=1
          ${startDate != null ? "AND qs.scanned_at >= @startDate" : ""}
          ${endDate != null ? "AND qs.scanned_at <= @endDate" : ""}
        ORDER BY qs.scanned_at
      ''', substitutionValues: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });

      final csvLines = <String>[AnalyticsExportRow.csvHeader()];
      
      for (final row in result) {
        final exportRow = AnalyticsExportRow(
          date: row[0] as DateTime,
          sessionId: _toInt(row[1]),
          exhibitId: _toInt(row[2]),
          exhibitTitle: row[3] as String,
          roomId: _toInt(row[4]),
          roomName: row[5] as String,
          scannedAt: row[6] as DateTime,
          rating: row[7] != null ? _toInt(row[7]) : null,
        );
        csvLines.add(exportRow.toCsvRow());
      }

      return csvLines.join('\n');
    } catch (e) {
      print('Error generating CSV: $e');
      return '';
    }
  }
}