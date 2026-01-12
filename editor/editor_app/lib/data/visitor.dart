// 2025
// Exhibit detail and related data models for visitor experience

/// Complete exhibit information for detailed display
/// Includes descriptions, dates, themes, and related content
class ExhibitDetails {
  final int exhibit_id;
  final String title;
  final String shortDesc;     // Brief description for list views
  final String longDesc;      // Detailed description for exhibit page
  final DateTime? startDate;  // Exhibit start date (null if permanent)
  final DateTime? finalDate;  // Exhibit end date (null if permanent)
  final String? eraName;      // Historical era classification
  final List<String> themes;  // Thematic categories
  final List<RelatedExhibit> relatedExhibits; // Thematically related exhibits
  final String? imagePath;    // Optional main image path

  ExhibitDetails({
    required this.exhibit_id,
    required this.title,
    required this.shortDesc,
    required this.longDesc,
    this.startDate,
    this.finalDate,
    this.eraName,
    required this.themes,
    required this.relatedExhibits,
    this.imagePath,
  });
}

/// Simplified exhibit for displaying related items
/// Used in "You might also like" sections
class RelatedExhibit {
  final int exhibit_id;
  final String title;

  RelatedExhibit({
    required this.exhibit_id,
    required this.title,
  });
}

/// Visitor feedback for exhibits
/// Stores ratings and comments from visitors
class ExhibitFeedback {
  final int exhibit_id;
  final String comment;
  final int rating;           // Typically 1-5 star rating
  final DateTime createdAt;   // When the feedback was submitted

  ExhibitFeedback({
    required this.exhibit_id,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}

/// QR code scan tracking record
/// Logs when and where visitors scan exhibit QR codes
class QRScan {
  final int session_id;       // Visitor session identifier
  final int room_id;          // Room where scan occurred
  final int exhibit_id;       // Scanned exhibit
  final DateTime scanned_at;  // Timestamp of scan

  QRScan({
    required this.session_id,
    required this.room_id,
    required this.exhibit_id,
    required this.scanned_at,
  });
}