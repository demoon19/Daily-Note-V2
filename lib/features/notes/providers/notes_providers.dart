import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../todo/providers/todo_providers.dart' show appDatabaseProvider;
import '../data/repositories/notes_repository_impl.dart';
import '../domain/entities/note_entity.dart';
import '../data/repositories/notes_repository.dart';

final notesRepositoryProvider = Provider<INotesRepository>((ref) {
  return NotesRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final notesListProvider = FutureProvider.autoDispose<List<NoteEntity>>((ref) async {
  return ref.watch(notesRepositoryProvider).getAll();
});

class NotesActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final INotesRepository _repository;
  final Ref _ref;
  NotesActionsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addNote(NoteEntity note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.add(note));
    _ref.invalidate(notesListProvider);
  }

  Future<void> deleteNote(int id) async {
    await _repository.delete(id);
    _ref.invalidate(notesListProvider);
  }
}

final notesActionsProvider = StateNotifierProvider<NotesActionsNotifier, AsyncValue<void>>((ref) {
  return NotesActionsNotifier(ref.watch(notesRepositoryProvider), ref);
});