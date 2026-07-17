/// Interface abstrak untuk semua implementasi LLM client
/// (on-device maupun cloud). Tidak ada fitur yang boleh
/// memanggil implementasi konkret secara langsung — selalu
/// lewat interface ini melalui intent_parser_service.dart.
abstract class LlmClient {
  /// Mengirim [prompt] (system + user gabungan atau terpisah)
  /// dan mengembalikan raw string hasil generasi LLM.
  /// Implementasi WAJIB mengembalikan teks mentah (bukan sudah
  /// di-parse) agar validasi JSON dilakukan di layer yang sama
  /// (intent_parser_service.dart).
  Future<String> generate({
    required String systemPrompt,
    required String userInput,
  });

  /// Nama identifier client, berguna untuk logging/debugging
  /// (mis. "on_device_gemma" atau "cloud_gemini_flash").
  String get clientName;
}