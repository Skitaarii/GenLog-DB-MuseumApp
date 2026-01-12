// 2025
// Exhibit data models for database operations and display

/// Full exhibit model with database relationships
/// Used for detailed exhibit management and CRUD operations
class Exhibit {
  final int exhibit_id;
  final String title;
  final DateTime? startDate;     // Optional start date for temporary exhibits
  final DateTime? finalDate;     // Optional end date for temporary exhibits
  final int short_desc_id;       // Foreign key to short description table
  final int long_desc_id;        // Foreign key to detailed description table

  Exhibit({
    required this.exhibit_id,
    required this.title,
    this.startDate,
    this.finalDate,
    required this.short_desc_id,
    required this.long_desc_id,
  });
}

/// Lightweight exhibit model for lists and selection
/// Used in dropdowns, checkboxes, and quick display scenarios
class ExhibitLite {
  final int exhibit_id;
  final String title;

  ExhibitLite({
    required this.exhibit_id,
    required this.title,
  });
}