class Exhibit {
  final int exhibit_id;
  final String title;
  final DateTime? startDate;
  final DateTime? finalDate;
  final int short_desc_id;
  final int long_desc_id;

  Exhibit({
    required this.exhibit_id,
    required this.title,
    this.startDate,
    this.finalDate,
    required this.short_desc_id,
    required this.long_desc_id,
  });
}
