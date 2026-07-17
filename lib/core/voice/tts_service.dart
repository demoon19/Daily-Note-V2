import 'package:flutter_tts/flutter_tts.dart';

/// Opsional: text-to-speech untuk greeting/motivasi harian.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init({String language = 'id-ID'}) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}