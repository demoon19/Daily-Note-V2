import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/todo_entity.dart';
import '../../providers/todo_providers.dart';
import '../widgets/todo_title.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
          title: const Text('To-do List', style: AppTextStyles.heading3)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller,
                    hintText: 'Tambah tugas baru...',
                    onSubmitted: () {
                      if (controller.text.trim().isEmpty) return;
                      ref.read(todoActionsProvider.notifier).addTodo(
                            TodoEntity(title: controller.text.trim()),
                          );
                      controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return const Center(child: Text('Belum ada tugas.'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoTile(
                      todo: todo,
                      onToggle: (value) => ref
                          .read(todoActionsProvider.notifier)
                          .toggleDone(todo.id!, value),
                      onDelete: () => ref
                          .read(todoActionsProvider.notifier)
                          .deleteTodo(todo.id!),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
