// Veuillet Gaëtan
// 2025
// Exhibit data models

/// Full exhibit model with all database fields
/// Used for detailed exhibit management and operations
class Exhibit {
  final int exhibit_id;
  final String title;
  final DateTime? startDate;
  final DateTime? finalDate;
  final int short_desc_id; // Reference to description table
  final int long_desc_id;  // Reference to detailed description table

  Exhibit({
    required this.exhibit_id,
    required this.title,
    this.startDate,
    this.finalDate,
    required this.short_desc_id,
    required this.long_desc_id,
  });
}

/// Lightweight exhibit model for lists and dropdowns
/// Contains only essential display information
class ExhibitLite {
  final int exhibit_id;
  final String title;

  ExhibitLite({
    required this.exhibit_id,
    required this.title,
  });
}