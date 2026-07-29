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
  }) async {
    final combinedInput = 'Subjek: $subject\nIsi: $bodySnippet';
    final response = await _intentParserService.parse(combinedInput, source: 'email');
    
    // Sisipkan teks asli email ke dalam catatan acara
    for (int i = 0; i < response.intents.length; i++) {
      final intent = response.intents[i];
      if (intent.type == IntentType.calendar || intent.type == IntentType.todo) {
        final currentNotes = intent.notes ?? '';
        final appendedNotes = '$currentNotes\n\n--- Isi Email Asli ---\nSubjek: $subject\n\n$bodySnippet'.trim();
        response.intents[i] = intent.copyWith(notes: appendedNotes);
      }
    }
    
    return response;
  }
}