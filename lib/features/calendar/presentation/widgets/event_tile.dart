import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/event_entity.dart';

class EventTile extends StatelessWidget {
  final EventEntity event;
  final bool isFirst;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const EventTile({
    super.key,
    required this.event,
    this.isFirst = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderAccent = _getAccentColor(event.id ?? 0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 45,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppDateUtils.formatTime(event.datetime),
                style: AppTextStyles.caption.copyWith(
                  fontFamily: AppTextStyles.fontMono.fontFamily,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
          // Timeline Line
          Column(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 24, left: 6, right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst ? AppColors.cyan : Colors.transparent,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.line.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Event Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line.withOpacity(0.8)),
                ),
                child: Stack(
                  children: [
                    // Left glow/border
                    Positioned(
                      left: 0,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: borderAccent,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getSubtitle(),
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textDisabled),
                              onPressed: onEdit,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          if (onEdit != null && onDelete != null) const SizedBox(width: 12),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.rose),
                              onPressed: onDelete,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    String sub = '';
    if (event.location != null && event.location!.isNotEmpty) {
      sub += '📍 ${event.location}';
    }
    if (event.recurrence != null && event.recurrence != 'none') {
      if (sub.isNotEmpty) sub += ' • ';
      sub += 'Berulang ${event.recurrence}';
    }
    return sub.isEmpty ? 'Jadwal' : sub;
  }

  Color _getAccentColor(int id) {
    const colors = [AppColors.cyan, AppColors.rose, AppColors.teal, AppColors.violet, AppColors.amber];
    return colors[id % colors.length];
  }
}