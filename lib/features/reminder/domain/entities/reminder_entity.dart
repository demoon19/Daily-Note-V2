class ReminderEntity {
  final int? id;
  final String title;
  final DateTime triggerAt;
  final int? linkedEventId;

  const ReminderEntity({
    this.id,
    required this.title,
    required this.triggerAt,
    this.linkedEventId,
  });
}