import '../ai/intent_parser_service.dart';
import '../ai/intent_models.dart';

/// Mengubah isi email (subject + body ringkas) menjadi IntentResult
/// via IntentParserService dengan flag source: "email". Hasil tetap
/// melewati intent_router.dart yang sama — TIDAK membuat jalur
/// khusus baru ke CalendarRepository.
class EmailToScheduleParser {
  final IntentParserService _intentParserService;

  EmailToScheduleParser({required IntentParserService intentParserService})
      : _intentParserService = intentParserService;

  Future<IntentParseResponse> parseEmail({
    required String subject,
    required String bodySnippet,
  }) {
    final combinedInput = 'Subjek: $subject\nIsi: $bodySnippet';
    return _intentParserService.parse(combinedInput, source: 'email');
  }
}