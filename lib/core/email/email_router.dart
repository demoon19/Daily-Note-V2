import 'email_to_schedule_parser.dart';
import '../ai/intent_router.dart';

/// Menjembatani hasil parsing email ke IntentRouter yang sama
/// dipakai oleh chat_assistant (bagian 5 guide: "Hasil parsing tetap
/// melewati intent_router.dart yang sama — tidak membuat jalur
/// khusus baru ke CalendarRepository").
class EmailRouter {
  final EmailToScheduleParser _parser;
  final IntentRouter _intentRouter;

  EmailRouter({
    required EmailToScheduleParser parser,
    required IntentRouter intentRouter,
  })  : _parser = parser,
        _intentRouter = intentRouter;

  Future<void> processIncomingEmail({
    required String subject,
    required String bodySnippet,
  }) async {
    final response = await _parser.parseEmail(
      subject: subject,
      bodySnippet: bodySnippet,
    );
    await _intentRouter.route(response);
  }
}