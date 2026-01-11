// Keenan Prusse
// 2025
// Analytics data models for museum visitor flow

class DwellTimeStats {
  final int exhibitId;
  final String exhibitTitle;
  final Duration medianDwell;
  final Duration averageDwell;
  final int totalVisits;
  final double averageRating;

  DwellTimeStats({
    required this.exhibitId,
    required this.exhibitTitle,
    required this.medianDwell,
    required this.averageDwell,
    required this.totalVisits,
    required this.averageRating,
  });
}

class PathSegment {
  final int fromRoomId;
  final int toRoomId;
  final String fromRoomName;
  final String toRoomName;
  final int transitionCount;

  PathSegment({
    required this.fromRoomId,
    required this.toRoomId,
    required this.fromRoomName,
    required this.toRoomName,
    required this.transitionCount,
  });
}

class EntryExitPoint {
  final int roomId;
  final String roomName;
  final int entryCount;
  final int exitCount;

  EntryExitPoint({
    required this.roomId,
    required this.roomName,
    required this.entryCount,
    required this.exitCount,
  });
}

class ExhibitPerformance {
  final int exhibitId;
  final String exhibitTitle;
  final Duration medianDwell;
  final double averageRating;
  final int totalVisits;
  final int feedbackCount;
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

class DailyStats {
  final DateTime date;
  final int totalSessions;
  final int totalScans;
  final Duration averageVisitDuration;
  final int uniqueExhibitsViewed;

  DailyStats({
    required this.date,
    required this.totalSessions,
    required this.totalScans,
    required this.averageVisitDuration,
    required this.uniqueExhibitsViewed,
  });
}

class ItineraryCompletion {
  final String itineraryName;
  final int totalStarts;
  final int totalCompletions;
  final double completionRate;
  final Map<int, int> dropOffPoints; // exhibit_id -> drop count

  ItineraryCompletion({
    required this.itineraryName,
    required this.totalStarts,
    required this.totalCompletions,
    required this.completionRate,
    required this.dropOffPoints,
  });
}

class RoomPopularity {
  final int roomId;
  final String roomName;
  final int visitCount;
  final Duration averageDwell;
  final int exhibitCount;

  RoomPopularity({
    required this.roomId,
    required this.roomName,
    required this.visitCount,
    required this.averageDwell,
    required this.exhibitCount,
  });
}

// For CSV export
class AnalyticsExportRow {
  final DateTime date;
  final int sessionId;
  final int exhibitId;
  final String exhibitTitle;
  final int roomId;
  final String roomName;
  final DateTime scannedAt;
  final Duration? dwellTime;
  final int? rating;

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

  String toCsvRow() {
    return '${date.toIso8601String()},${sessionId},${exhibitId},"${exhibitTitle}",${roomId},"${roomName}",${scannedAt.toIso8601String()},${dwellTime?.inMinutes ?? ""},${rating ?? ""}';
  }

  static String csvHeader() {
    return 'Date,Session ID,Exhibit ID,Exhibit Title,Room ID,Room Name,Scanned At,Dwell Time (min),Rating';
  }
}
