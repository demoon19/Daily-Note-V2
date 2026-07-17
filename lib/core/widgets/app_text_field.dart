import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Text field generik dipakai lintas fitur, termasuk input bar
/// utama di home/chat_assistant (mendukung tombol mic voice input).
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final int maxLines;
  final VoidCallback? onMicPressed;
  final VoidCallback? onSubmitted;
  final bool isListening;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.obscureText = false,
    this.maxLines = 1,
    this.onMicPressed,
    this.onSubmitted,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: onMicPressed != null
            ? IconButton(
                icon: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: isListening
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                onPressed: onMicPressed,
              )
            : null,
      ),
    );
  }
}