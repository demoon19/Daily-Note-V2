enum ChatSender { user, assistant }

class ChatMessageEntity {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessageEntity copyWith({String? text, bool? isLoading}) {
    return ChatMessageEntity(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}