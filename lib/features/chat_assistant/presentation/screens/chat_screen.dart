import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('AI Assistant', style: AppTextStyles.heading3),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  ChatBubble(message: messages[index]),
            ),
          ),
          _buildInputBar(isListening),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isListening) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 12, top: 11, bottom: 11),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.teal.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 8),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: isListening ? 'Mendengarkan...' : 'Ketik atau ucapkan sesuatu...',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _hasText ? _send : _toggleMic,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.teal, AppColors.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: isListening ? [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Icon(
                      _hasText 
                          ? Icons.arrow_forward 
                          : (isListening ? Icons.mic : Icons.mic_none),
                      color: const Color(0xFF04121A),
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}