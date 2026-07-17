class NoteEntity {
  final int? id;
  final String title;
  final String? content;
  final DateTime? createdAt;

  const NoteEntity({this.id, required this.title, this.content, this.createdAt});

  NoteEntity copyWith({int? id, String? title, String? content, DateTime? createdAt}) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}