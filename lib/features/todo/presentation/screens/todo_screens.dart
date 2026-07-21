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
          title: Text('To-do List', style: AppTextStyles.heading3)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller,
                    hintText: 'Tambah tugas baru (cepat)...',
                    onSubmitted: () {
                      if (controller.text.trim().isEmpty) return;
                      ref.read(todoActionsProvider.notifier).addTodo(
                            TodoEntity(title: controller.text.trim()),
                          ).then((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
                          );
                        }
                      });
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

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tugas Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Judul tugas'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedDate == null 
                        ? 'Tanpa Tenggat Waktu' 
                        : 'Tenggat: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        child: const Text('Set'),
                      )
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    ref.read(todoActionsProvider.notifier).addTodo(
                          TodoEntity(
                            title: titleController.text.trim(),
                            dueDate: selectedDate,
                          ),
                        ).then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
                        );
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
