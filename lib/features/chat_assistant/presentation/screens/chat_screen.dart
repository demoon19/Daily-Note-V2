import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/voice/speech_to_text.dart';
import '../../providers/chat_providers.dart';
import '../widget/chat_bubble.dart';

final speechToTextServiceProvider =
    Provider<SpeechToTextService>((ref) => SpeechToTextService());

final isListeningProvider = StateProvider<bool>((ref) => false);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleMic() async {
    final service = ref.read(speechToTextServiceProvider);
    final isListening = ref.read(isListeningProvider);

    if (isListening) {
      await service.stopListening();
      ref.read(isListeningProvider.notifier).state = false;
      return;
    }

    ref.read(isListeningProvider.notifier).state = true;
    await service.startListening(
      onResult: (recognizedText) {
        _controller.text = recognizedText;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isListening = ref.watch(isListeningProvider);

    ref.listen(chatMessagesProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant', style: AppTextStyles.heading3)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Ketik atau ucapkan sesuatu untuk memulai...'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        ChatBubble(message: messages[index]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AppTextField(
              controller: _controller,
              hintText: 'Tulis pesan...',
              isListening: isListening,
              onMicPressed: _toggleMic,
              onSubmitted: _send,
            ),
          ),
        ],
      ),
    );
  }
}