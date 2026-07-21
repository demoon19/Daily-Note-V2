import 'package:flutter/material.dart';
import '../../../../core/ai/intent_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    
    // Check if it's an intent box message
    final isIntentBox = message.intents != null && message.intents!.isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: isIntentBox ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.cyan : AppColors.surface,
          border: Border.all(color: isUser ? AppColors.cyan : AppColors.line),
          borderRadius: BorderRadius.only(
            topLeft: isUser ? const Radius.circular(16) : Radius.zero,
            topRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: message.isLoading
            ? const LoadingIndicator(size: 16)
            : isIntentBox 
                ? _buildIntentBox(message.intents!)
                : Text(
                    message.text, 
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isUser ? Colors.black : Colors.white,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
      ),
    );
  }

  Widget _buildIntentBox(List<IntentResult> intents) {
    final actionable = intents.where((i) => i.type != IntentType.chat).toList();
    if (actionable.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terdeteksi ${actionable.length} intent dari kalimat kamu:',
          style: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...actionable.map((intent) => _buildIntentCard(intent)),
      ],
    );
  }

  Widget _buildIntentCard(IntentResult intent) {
    Color badgeColor;
    String badgeText = intent.type.name.toUpperCase();
    String subtitle = '';

    switch (intent.type) {
      case IntentType.calendar:
        badgeColor = AppColors.cyan;
        subtitle = intent.datetime != null ? 'Waktu: ${intent.datetime}' : 'Jadwal baru';
        break;
      case IntentType.expense:
        badgeColor = AppColors.rose;
        subtitle = intent.amount != null ? 'Kategori: ${intent.category ?? 'Transportasi'}' : 'Pengeluaran baru';
        break;
      case IntentType.reminder:
        badgeColor = AppColors.amber;
        subtitle = 'Terhubung ke agenda di atas';
        break;
      case IntentType.todo:
        badgeColor = AppColors.teal;
        subtitle = 'Tugas baru';
        break;
      case IntentType.note:
        badgeColor = AppColors.violet;
        subtitle = 'Catatan baru';
        break;
      default:
        badgeColor = AppColors.line;
    }

    String displayTitle = intent.title ?? '';
    if (intent.type == IntentType.expense && intent.amount != null) {
      displayTitle = '$displayTitle — ${CurrencyFormatter.format(intent.amount!)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: AppTextStyles.fontMono.fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}