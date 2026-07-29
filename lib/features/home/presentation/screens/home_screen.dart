import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/home_providers.dart';
import '../../../calendar/providers/calendar_providers.dart';
import '../../../summary/providers/summary_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../calendar/domain/entities/event_entity.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _getGreeting(DateTime time) {
    final hour = time.hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _getMotivationalQuote(DateTime date) {
    const quotes = [
      '"Progres kecil hari ini, hasil besar minggu ini."',
      '"Satu langkah kecil lebih baik daripada tidak sama sekali."',
      '"Fokus pada produktivitas, bukan kesibukan."',
      '"Jangan tunggu sempurna untuk mulai sesuatu."',
      '"Waktu adalah modal terbesarmu, manfaatkanlah."',
      '"Lakukan sekarang, atau menyesal nanti."',
      '"Setiap tantangan adalah peluang untuk tumbuh."',
      '"Tetap semangat! Hari ini adalah kanvas kosongmu."',
      '"Bukan tentang siapa yang tercepat, tapi siapa yang konsisten."',
    ];
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return quotes[random.nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);
    final quote = _getMotivationalQuote(now);
    final dateStr =
        '${AppDateUtils.formatDayName(now)}, ${AppDateUtils.formatDate(now)}';

    final homeSummaryAsync = ref.watch(homeSummaryProvider);
    final eventsAsync = ref.watch(eventsByDateProvider);
    final weeklySummaryAsync = ref.watch(weeklySummaryProvider);

    final summary = homeSummaryAsync.valueOrNull;
    final events = eventsAsync.valueOrNull ?? [];
    final weeklySummary = weeklySummaryAsync.valueOrNull;

    final agendaCount = summary?.totalEventsToday ?? 0;
    final todoCount = summary?.totalPendingTodos ?? 0;
    final expense = summary?.totalExpenseToday ?? 0;

    // Sort and filter events (only upcoming today, or just today's events if none upcoming)
    final upcomingEvents = events.where((e) => e.datetime.isAfter(now)).toList()
      ..sort((a, b) => a.datetime.compareTo(b.datetime));

    final displayEvents = upcomingEvents.isNotEmpty
        ? upcomingEvents.take(3).toList()
        : events.take(3).toList();

    int weeklyCompleted = weeklySummary?.totalTodosCompleted ?? 0;
    int weeklyPending = weeklySummary?.dailyBreakdown
            .fold<int>(0, (sum, d) => sum + (d.totalTodosPending)) ??
        0;
    int weeklyTotal = weeklyCompleted + weeklyPending;
    double weeklyPct = weeklyTotal > 0 ? (weeklyCompleted / weeklyTotal) : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 90),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: AppTextStyles.eyebrow.copyWith(color: AppColors.teal),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: AppColors.teal),
                  onPressed: () {
                    context.push('/settings');
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Greeting Card
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0x242DD4BF),
                    Color(0x0F38BDF8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.teal.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting 👋', style: AppTextStyles.eyebrow),
                  const SizedBox(height: 6),
                  Text(
                    quote,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kamu punya $agendaCount agenda dan $todoCount tugas menunggu. Mulai dari yang paling dekat waktunya, yuk.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Stats
            Row(
              children: [
                _buildStatChip(
                    agendaCount.toString(), 'Agenda hari ini', AppColors.teal),
                const SizedBox(width: 10),
                _buildStatChip(
                    todoCount.toString(), 'Todo aktif', AppColors.cyan),
                const SizedBox(width: 10),
                _buildStatChip(_formatShortCurrency(expense), 'Pengeluaran',
                    AppColors.rose),
              ],
            ),
            const SizedBox(height: 16),

            // Agenda
            Text('AGENDA BERIKUTNYA',
                style: AppTextStyles.eyebrow
                    .copyWith(color: AppColors.textDisabled)),
            const SizedBox(height: 9),
            if (displayEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('Tidak ada agenda hari ini.',
                    style:
                        TextStyle(color: AppColors.textDisabled, fontSize: 13)),
              )
            else
              ...displayEvents.map((e) => _buildAgendaItem(e, AppColors.teal)),

            const SizedBox(height: 16),
            Text('RINGKASAN MINGGUAN',
                style: AppTextStyles.eyebrow
                    .copyWith(color: AppColors.textDisabled)),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '$weeklyCompleted tugas selesai · $weeklyPending rencana meleset',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.surface3,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: weeklyPct,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: const LinearGradient(
                                  colors: [AppColors.teal, AppColors.cyan],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(weeklyPct * 100).toInt()}%',
                          style: AppTextStyles.caption.copyWith(
                              fontFamily: AppTextStyles.fontMono.fontFamily)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return CurrencyFormatter.format(amount).replaceAll('Rp ', '');
  }

  Widget _buildStatChip(String numText, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              numText,
              style: AppTextStyles.heading2
                  .copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaItem(
      EventEntity e, Color dotColor) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedDateProvider.notifier).state = e.datetime;
        context.push('/calendar');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                AppDateUtils.formatTime(e.datetime),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontMono.fontFamily,
                  fontSize: 11,
                  color: AppColors.cyan,
                ),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  if ((e.location ?? '').isNotEmpty)
                    Text(e.location!,
                        style: const TextStyle(
                            fontSize: 10.5, color: AppColors.textDisabled)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
