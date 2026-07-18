import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_text_styles.dart';

class MotivationWidget extends StatelessWidget {
  final String quote;

  const MotivationWidget({super.key, this.quote = 'Satu langkah kecil hari ini, hasil besar nanti.'});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(quote, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}