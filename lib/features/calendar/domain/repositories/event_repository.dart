import '../entities/event_entity.dart';

abstract class IEventRepository {
  Future<List<EventEntity>> getAll();
  Future<List<EventEntity>> getByDate(DateTime date);
  Future<int> add(EventEntity event);
  Future<void> delete(int id);
  Future<void> update(EventEntity event);
}