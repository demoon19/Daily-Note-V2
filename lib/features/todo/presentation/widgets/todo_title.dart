import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/todo_entity.dart';

class TodoTile extends StatelessWidget {
  final TodoEntity todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => onToggle(!todo.isDone),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: todo.isDone ? AppColors.cyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: todo.isDone ? AppColors.cyan : AppColors.textDisabled.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: todo.isDone
                    ? const Icon(Icons.check, size: 16, color: AppColors.background)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: todo.isDone ? AppColors.textDisabled : Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getSubtitleDotColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getSubtitleText(),
                        style: const TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: AppColors.textDisabled.withOpacity(0.5)),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubtitleDotColor() {
    if (todo.isDone) return AppColors.textDisabled;
    if (todo.dueDate == null) return AppColors.amber;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    
    if (due.isBefore(today)) return AppColors.rose;
    if (due.isAtSameMomentAs(today)) return AppColors.rose; // Hari ini -> merah
    return AppColors.amber; // Besok atau lusa
  }

  String _getSubtitleText() {
    if (todo.isDone) return 'Selesai';
    if (todo.dueDate == null) return 'Tanpa tenggat waktu';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    
    if (due.isBefore(today)) return 'Terlewat';
    if (due.isAtSameMomentAs(today)) return 'Hari ini';
    if (due.difference(today).inDays == 1) return 'Besok';
    
    return AppDateUtils.formatDate(todo.dueDate!);
  }
}