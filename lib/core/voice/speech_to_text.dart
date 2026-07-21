import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Wrapper tipis di atas package `speech_to_text` agar seluruh
/// fitur (home/chat_assistant) memakai instance yang sama,
/// bukan inisialisasi sendiri-sendiri.
class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => print('SpeechToText error: $error'),
      onStatus: (status) => print('SpeechToText status: $status'),
    );
    return _isInitialized;
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required void Function(String recognizedText) onResult,
  }) async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) return;
    }
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: 'id_ID', // Memastikan pengenalan suara berbahasa Indonesia
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}