import 'llm_client.dart';

/// Implementasi default, no-cost, jalan sepenuhnya di device.
/// Gunakan package seperti `flutter_gemma` atau `fllama` untuk
/// menjalankan model kecil (Gemma 2B / Phi-3-mini).
class OnDeviceLlmClient implements LlmClient {
  bool _isModelLoaded = false;

  @override
  String get clientName => 'on_device_gemma';

  /// Panggil sekali saat app start (mis. di main.dart atau
  /// providers/home_providers.dart) sebelum generate() dipakai.
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    // TODO: inisialisasi model via flutter_gemma / fllama, contoh:
    // await FlutterGemmaPlugin.instance.init(modelPath: 'assets/models/gemma-2b.bin');
    _isModelLoaded = true;
  }

  @override
  Future<String> generate({
    required String systemPrompt,
    required String userInput,
  }) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    // TODO: ganti dengan pemanggilan nyata ke package on-device LLM.
    // Contoh pola (flutter_gemma):
    // final response = await FlutterGemmaPlugin.instance.getResponse(
    //   prompt: '$systemPrompt\n\n$userInput',
    // );
    // return response;

    throw UnimplementedError(
      'Hubungkan ke package on-device LLM (flutter_gemma/fllama) di sini.',
    );
  }
}