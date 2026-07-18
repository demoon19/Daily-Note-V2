import '../../domain/entities/note_entity.dart';

abstract class INotesRepository {
  Future<List<NoteEntity>> getAll();
  Future<void> add(NoteEntity note);
  Future<void> update(NoteEntity note);
  Future<void> delete(int id);
}