class Exhibit {
  final int exhibit_id;
  final String title;
  final DateTime? startDate;
  final DateTime? finalDate;

  Exhibit({
    required this.exhibit_id,
    required this.title,
    this.startDate,
    this.finalDate,
  });
}
