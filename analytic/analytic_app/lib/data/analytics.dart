// Keenan Prusse
// 2025
// Analytics data models for museum visitor flow and performance metrics

/// Statistics on how long visitors spend at exhibits
/// Used for engagement analysis and exhibit optimization
class DwellTimeStats {
  final int exhibitId;
  final String exhibitTitle;
  final Duration medianDwell;     // Middle value of dwell times
  final Duration averageDwell;    // Mean dwell time
  final int totalVisits;          // Number of unique visits
  final double averageRating;     // Average visitor rating (1-5)

  DwellTimeStats({
    required this.exhibitId,
    required this.exhibitTitle,
    required this.medianDwell,
    required this.averageDwell,
    required this.totalVisits,
    required this.averageRating,
  });
}

/// Visitor movement between rooms
/// Shows common paths and transition patterns
class PathSegment {
  final int fromRoomId;
  final int toRoomId;
  final String fromRoomName;
  final String toRoomName;
  final int transitionCount;      // How many times visitors moved between these rooms

  PathSegment({
    required this.fromRoomId,
    required this.toRoomId,
    required this.fromRoomName,
    required this.toRoomName,
    required this.transitionCount,
  });
}

/// Entry and exit points for visitor flow analysis
/// Identifies popular starting and ending locations
class EntryExitPoint {
  final int roomId;
  final String roomName;
  final int entryCount;           // How many visits started here
  final int exitCount;            // How many visits ended here

  EntryExitPoint({
    required this.roomId,
    required this.roomName,
    required this.entryCount,
    required this.exitCount,
  });
}

/// Comprehensive exhibit performance metrics
/// Used for categorizing exhibits by visitor engagement
class ExhibitPerformance {
  final int exhibitId;
  final String exhibitTitle;
  final Duration medianDwell;     // Median time spent at exhibit
  final double averageRating;     // Average visitor rating
  final int totalVisits;          // Total number of visits
  final int feedbackCount;        // Number of ratings/comments
  final String performanceCategory; // "high-engagement", "low-engagement", "confusing", etc.

  ExhibitPerformance({
    required this.exhibitId,
    required this.exhibitTitle,
    required this.medianDwell,
    required this.averageRating,
    required this.totalVisits,
    required this.feedbackCount,
    required this.performanceCategory,
  });
}

/// Daily aggregated visitor statistics
/// Used for trend analysis over time
class DailyStats {
  final DateTime date;
  final int totalSessions;            // Number of unique visitor sessions
  final int totalScans;               // Total QR code scans
  final Duration averageVisitDuration; // Average time spent in museum
  final int uniqueExhibitsViewed;     // Number of different exhibits seen

  DailyStats({
    required this.date,
    required this.totalSessions,
    required this.totalScans,
    required this.averageVisitDuration,
    required this.uniqueExhibitsViewed,
  });
}

/// Itinerary completion and engagement metrics
/// Tracks how visitors interact with curated paths
class ItineraryCompletion {
  final String itineraryName;
  final int totalStarts;               // How many visitors started this itinerary
  final int totalCompletions;          // How many completed the full path
  final double completionRate;         // Completion percentage (completions/starts)
  final Map<int, int> dropOffPoints;   // exhibit_id -> drop count (where visitors stopped)

  ItineraryCompletion({
    required this.itineraryName,
    required this.totalStarts,
    required this.totalCompletions,
    required this.completionRate,
    required this.dropOffPoints,
  });
}

/// Room-level visitor statistics
/// Shows which rooms are most popular and engaging
class RoomPopularity {
  final int roomId;
  final String roomName;
  final int visitCount;            // Number of visits to this room
  final Duration averageDwell;     // Average time spent in room
  final int exhibitCount;          // Number of exhibits in room

  RoomPopularity({
    required this.roomId,
    required this.roomName,
    required this.visitCount,
    required this.averageDwell,
    required this.exhibitCount,
  });
}

/// Raw data row for CSV export functionality
/// Contains all visitor interaction data for external analysis
class AnalyticsExportRow {
  final DateTime date;
  final int sessionId;
  final int exhibitId;
  final String exhibitTitle;
  final int roomId;
  final String roomName;
  final DateTime scannedAt;
  final Duration? dwellTime;       // Time spent at this exhibit (nullable)
  final int? rating;               // Visitor rating 1-5 (nullable)

  AnalyticsExportRow({
    required this.date,
    required this.sessionId,
    required this.exhibitId,
    required this.exhibitTitle,
    required this.roomId,
    required this.roomName,
    required this.scannedAt,
    this.dwellTime,
    this.rating,
  });

  /// Converts this row to CSV format
  String toCsvRow() {
    return '${date.toIso8601String()},${sessionId},${exhibitId},"${exhibitTitle}",${roomId},"${roomName}",${scannedAt.toIso8601String()},${dwellTime?.inMinutes ?? ""},${rating ?? ""}';
  }

  /// Returns CSV header row
  static String csvHeader() {
    return 'Date,Session ID,Exhibit ID,Exhibit Title,Room ID,Room Name,Scanned At,Dwell Time (min),Rating';
  }
}