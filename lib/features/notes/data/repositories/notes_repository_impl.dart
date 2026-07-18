import 'package:drift/drift.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/ai/intent_router.dart' show NotesRepository;
import '../../../../../core/ai/intent_models.dart';
import '../../domain/entities/note_entity.dart';
import 'notes_repository.dart';

class NotesRepositoryImpl implements INotesRepository, NotesRepository {
  final AppDatabase _db;
  NotesRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<NoteEntity>> getAll() async {
    final rows = await _db.select(_db.notes).get();
    return rows
        .map((r) => NoteEntity(id: r.id, title: r.title, content: r.content, createdAt: r.createdAt))
        .toList();
  }

  @override
  Future<void> add(NoteEntity note) async {
    await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            title: note.title,
            content: Value(note.content),
          ),
        );
  }

  @override
  Future<void> update(NoteEntity note) async {
    await (_db.update(_db.notes)..where((t) => t.id.equals(note.id!))).write(
      NotesCompanion(title: Value(note.title), content: Value(note.content)),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> addNote(IntentResult intent) async {
    await add(NoteEntity(
      title: intent.title ?? 'Catatan baru',
      content: intent.notes,
    ));
  }
}