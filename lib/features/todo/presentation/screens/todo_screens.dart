import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/todo_entity.dart';
import '../../providers/todo_providers.dart';
import '../widgets/todo_title.dart';

enum TodoFilter { all, today, done }

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  TodoFilter _filter = TodoFilter.all;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TO-DO LIST', style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2)),
                  const SizedBox(height: 4),
                  const Text(
                    'Tugas Kamu',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterPill(
                    'Semua',
                    TodoFilter.all,
                    todosAsync.valueOrNull?.length,
                  ),
                  _buildFilterPill('Hari ini', TodoFilter.today, null),
                  _buildFilterPill('Selesai', TodoFilter.done, null),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Add TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppTextField(
                controller: _controller,
                hintText: 'Tambah tugas cepat...',
                onSubmitted: () {
                  if (_controller.text.trim().isEmpty) return;
                  ref.read(todoActionsProvider.notifier).addTodo(
                        TodoEntity(title: _controller.text.trim()),
                      ).then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
                      );
                    }
                  });
                  _controller.clear();
                },
              ),
            ),
            const SizedBox(height: 8),

            // Todo List
            Expanded(
              child: todosAsync.when(
                data: (todos) {
                  final filteredTodos = _getFilteredTodos(todos);

                  if (filteredTodos.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada tugas di kategori ini.', style: TextStyle(color: AppColors.textDisabled)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
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
      ),
    );
  }

  List<TodoEntity> _getFilteredTodos(List<TodoEntity> todos) {
    if (_filter == TodoFilter.all) return todos;
    if (_filter == TodoFilter.done) return todos.where((t) => t.isDone).toList();
    
    // Hari ini
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return todos.where((t) {
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due.isAtSameMomentAs(today);
    }).toList();
  }

  Widget _buildFilterPill(String label, TodoFilter filter, int? count) {
    final isSelected = _filter == filter;
    final text = count != null && count > 0 && filter == TodoFilter.all ? '$label ($count)' : label;

    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.line,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.cyan : AppColors.textDisabled,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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
