class TodoEntity {
  final int? id;
  final String title;
  final bool isDone;
  final DateTime? dueDate;

  const TodoEntity({
    this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
  });

  TodoEntity copyWith({
    int? id,
    String? title,
    bool? isDone,
    DateTime? dueDate,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}