import '../entities/reminder_entity.dart';

abstract class IReminderRepository {
  Future<List<ReminderEntity>> getAll();
  Future<void> add(ReminderEntity reminder);
  Future<void> delete(int id);
}