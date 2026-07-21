import '../../../../core/ai/intent_models.dart';

enum ChatSender { user, assistant }

class ChatMessageEntity {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final bool isLoading;
  final List<IntentResult>? intents;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
    this.intents,
  });

  ChatMessageEntity copyWith({String? text, bool? isLoading, List<IntentResult>? intents}) {
    return ChatMessageEntity(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
      intents: intents ?? this.intents,
    );
  }
}