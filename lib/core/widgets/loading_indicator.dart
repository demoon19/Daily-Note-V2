import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Loading indicator generik dipakai lintas fitur, misalnya
/// saat menunggu response LLM (on-device/cloud) di chat_assistant.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final String? label;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 12),
          Text(label!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}