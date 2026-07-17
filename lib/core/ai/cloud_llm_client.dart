import 'dart:convert';
import 'package:http/http.dart' as http;
import 'llm_client.dart';
import '../network/api_client.dart';

/// Implementasi fallback via proxy Edge Function (Cloudflare
/// Workers / Supabase Edge Functions). JANGAN panggil provider
/// LLM cloud langsung dari app — API key harus disembunyikan
/// di proxy sesuai strategi cost-minimal (lihat bagian 3.3 guide).
class CloudLlmClient implements LlmClient {
  final ApiClient _apiClient;

  CloudLlmClient({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  String get clientName => 'cloud_fallback_proxy';

  @override
  Future<String> generate({
    required String systemPrompt,
    required String userInput,
  }) async {
    final response = await _apiClient.post(
      path: '/llm/generate',
      body: {
        'system_prompt': systemPrompt,
        'user_input': userInput,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Cloud LLM fallback gagal: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['text'] as String? ?? '';
  }
}