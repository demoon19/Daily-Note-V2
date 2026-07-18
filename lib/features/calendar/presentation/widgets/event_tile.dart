import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/event_entity.dart';

class EventTile extends StatelessWidget {
  final EventEntity event;
  final VoidCallback? onDelete;

  const EventTile({super.key, required this.event, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AppCard(
        accentColor: AppColors.calendarAccent,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.calendarAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTextStyles.heading3),
                  Text(
                    '${AppDateUtils.formatTime(event.datetime)}'
                    '${event.location != null ? ' • ${event.location}' : ''}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}