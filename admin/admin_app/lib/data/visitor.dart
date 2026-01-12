// Exhibit data models for museum application
// Defines core data structures for exhibit information and visitor interactions

/// Complete exhibit details model containing all information for exhibit display
/// Used on exhibit detail pages and when loading comprehensive exhibit data
class ExhibitDetails {
  final int exhibit_id;                // Unique identifier for the exhibit
  final String title;                  // Display name of the exhibit
  final String shortDesc;              // Brief description (1-2 sentences)
  final String longDesc;               // Detailed description (full content)
  final DateTime? startDate;           // Exhibit start date (optional)
  final DateTime? finalDate;           // Exhibit end date (optional)
  final String? eraName;               // Historical era classification (optional)
  final List<String> themes;           // List of thematic categories
  final List<RelatedExhibit> relatedExhibits; // Exhibits with shared themes/era
  final String? imagePath;             // URL or path to exhibit image (optional)

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

/// Lightweight exhibit model for related exhibits display
/// Used when showing exhibits linked by theme or era (navigation purposes only)
class RelatedExhibit {
  final int exhibit_id;      // Unique identifier for the related exhibit
  final String title;        // Display name of the related exhibit

  RelatedExhibit({
    required this.exhibit_id,
    required this.title,
  });
}

/// Visitor feedback model for exhibit ratings and comments
/// Stores user-submitted reviews and ratings for exhibits
class ExhibitFeedback {
  final int exhibit_id;      // Exhibit that received feedback
  final String comment;      // Visitor's written feedback (may be empty)
  final int rating;          // 1-5 star rating
  final DateTime createdAt;  // When feedback was submitted

  ExhibitFeedback({
    required this.exhibit_id,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}

/// QR scan tracking model for visitor movement analytics
/// Records each QR code scan with session, location, and timestamp
class QRScan {
  final int session_id;      // Visitor session identifier
  final int room_id;         // Room where scan occurred
  final int exhibit_id;      // Exhibit that was scanned
  final DateTime scanned_at; // Timestamp of scan event

  QRScan({
    required this.session_id,
    required this.room_id,
    required this.exhibit_id,
    required this.scanned_at,
  });
}