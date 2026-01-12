// Veuillet Gaëtan
// 2025
// Data models for museum exhibits and related entities

import 'dart:typed_data';

/// Image associated with an exhibit
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

/// Complete details for a museum exhibit
class ExhibitDetails {
  final int exhibit_id;
  final String title;
  final String shortDesc;
  final String longDesc;
  final DateTime? startDate;
  final DateTime? finalDate;
  final String? imagePath;
  final List<ExhibitImage> images;
  final String? eraName;
  final List<String> themes;
  final List<RelatedExhibit> relatedExhibits;

  ExhibitDetails({
    required this.exhibit_id,
    required this.title,
    required this.shortDesc,
    required this.longDesc,
    this.startDate,
    this.finalDate,
    this.imagePath,
    this.images = const [],
    this.eraName,
    required this.themes,
    required this.relatedExhibits,
  });
}

/// Simplified exhibit for related items display
class RelatedExhibit {
  final int exhibit_id;
  final String title;

  RelatedExhibit({
    required this.exhibit_id,
    required this.title,
  });
}

/// Visitor feedback for an exhibit
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

/// QR code scan record
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