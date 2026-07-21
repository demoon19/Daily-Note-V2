class EventEntity {
  final int? id;
  final String title;
  final DateTime datetime;
  final String? location;
  final String? notes;
  final String? recurrence;

  const EventEntity({
    this.id,
    required this.title,
    required this.datetime,
    this.location,
    this.notes,
    this.recurrence,
  });
}