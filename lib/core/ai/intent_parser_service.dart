import 'llm_client.dart';
import 'intent_models.dart';

/// Orkestrasi utama LLM Intent Engine.
/// Alur WAJIB (lihat bagian 3.1 & 4.1 guide):
/// on-device parse -> validate JSON -> jika gagal -> cloud fallback
/// -> validate lagi -> jika gagal juga -> minta klarifikasi ke user.
class IntentParserService {
  final LlmClient onDeviceClient;
  final LlmClient cloudClient;

  IntentParserService({
    required this.onDeviceClient,
    required this.cloudClient,
  });

  static const String _baseSystemPrompt = '''
Kamu adalah parser intent untuk aplikasi asisten pribadi "Daily Note".
Balas HANYA dengan JSON valid sesuai skema berikut, TANPA teks tambahan
di luar JSON:

{
  "intents": [
    {
      "type": "calendar | todo | note | expense | reminder | chat",
      "title": "string",
      "datetime": "ISO8601 string atau null",
      "location": "string atau null",
      "notes": "string atau null",
      "amount": "number atau null",
      "category": "string atau null",
      "trigger_offset_minutes": "number atau null",
      "linked_intent_ref": "number index intent lain atau null"
    }
  ]
}

- PENTING: Lakukan NORMALISASI pada kalimat input dari user. Jika user menggunakan bahasa gaul, typo, kalimat tidak baku, singkatan, atau kalimat yang sulit dipahami, pahami dan perbaiki maksud aslinya terlebih dahulu sebelum menentukan intent dan mengeksekusi perintahnya (contoh: "bkin jdwal mkan sng jam 1" -> maksud aslinya "Buat jadwal makan siang jam 13:00" -> intent "calendar").
- JADWAL MASA LALU: Jika event, email, atau acara yang diminta ternyata sudah lewat/terjadi di masa lalu, TETAP masukkan sebagai intent "calendar" untuk keperluan dokumentasi. Jangan abaikan acara yang sudah lewat.
- RENTANG WAKTU (DATE RANGE): Jika acara memiliki rentang tanggal (misalnya "25 Juli hingga 28 Juli"), set field "datetime" ke TANGGAL MULAI PALING AWAL. Lalu, TULISKAN secara eksplisit keterangan rentang waktu dan jam pelaksanaannya di dalam field "notes" (contoh: "Pelaksanaan: 25 Juli - 28 Juli, mulai hingga selesai").
- Gunakan zona waktu perangkat untuk field datetime.
- Jika reminder tidak menyebutkan waktu eksplisit, default
  trigger_offset_minutes = 30.
- Jika input tidak mengandung intent actionable, kembalikan
  satu intent dengan type "chat" dan isi balasan percakapan
  biasa di field "notes".
- Jangan pernah mengubah nama field di atas.
''';

  /// [source] opsional: "email" untuk menyesuaikan prompt agar
  /// fokus ekstraksi jadwal (dipakai oleh email_to_schedule_parser.dart).
  Future<IntentParseResponse> parse(
    String userInput, {
    String source = 'text',
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    final systemPrompt = source == 'email'
        ? '$_baseSystemPrompt\n(Waktu saat ini: $nowStr)\nFokus ekstraksi tanggal/waktu/acara dari isi '
            'email berikut, abaikan konten promosi/spam.'
        : '$_baseSystemPrompt\n(Waktu saat ini: $nowStr)';

    // 1. Coba on-device dulu (no cost, default)
    try {
      final rawOnDevice = await onDeviceClient.generate(
        systemPrompt: systemPrompt,
        userInput: userInput,
      );
      final parsed = _tryParse(rawOnDevice);
      if (parsed != null) return parsed;
    } catch (_) {
      // lanjut ke fallback cloud
    }

    // 2. Fallback ke cloud jika on-device gagal / JSON invalid
    try {
      final rawCloud = await cloudClient.generate(
        systemPrompt: systemPrompt,
        userInput: userInput,
      );
      final parsed = _tryParse(rawCloud);
      if (parsed != null) return parsed;
    } catch (_) {
      // lanjut ke klarifikasi
    }

    // 3. Kedua metode gagal -> minta klarifikasi ke user
    return IntentParseResponse(
      intents: [
        IntentResult(
          type: IntentType.chat,
          notes: 'Maaf, saya kurang paham maksudnya. '
              'Bisa tolong jelaskan ulang?',
        ),
      ],
    );
  }

  IntentParseResponse? _tryParse(String raw) {
    final response = IntentParseResponse.fromJsonString(raw.trim());
    if (response.intents.isEmpty) return null;
    return response;
  }
}