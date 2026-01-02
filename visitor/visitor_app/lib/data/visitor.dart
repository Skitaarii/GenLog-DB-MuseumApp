class ExhibitDetails {
  final int exhibit_id;
  final String title;
  final String shortDesc;
  final String longDesc;
  final DateTime? startDate;
  final DateTime? finalDate;
  final String? eraName;
  final List<String> themes;
  final List<RelatedExhibit> relatedExhibits;
  final String? imagePath;

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

class RelatedExhibit {
  final int exhibit_id;
  final String title;

  RelatedExhibit({
    required this.exhibit_id,
    required this.title,
  });
}

class ExhibitFeedback {
  final int exhibit_id;
  final String comment;
  final int rating;
  final DateTime createdAt;

  ExhibitFeedback({
    required this.exhibit_id,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}

class QRScan {
  final int session_id;
  final int room_id;
  final int exhibit_id;
  final DateTime scanned_at;

  QRScan({
    required this.session_id,
    required this.room_id,
    required this.exhibit_id,
    required this.scanned_at,
  });
}