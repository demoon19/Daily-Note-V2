import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../email_listener_service.dart';
import '../email_to_schedule_parser.dart';
import '../../ai/providers/llm_providers.dart';
import '../../ai/providers/intent_router_provider.dart';
import '../../network/api_client.dart';
import '../../ai/intent_router.dart';

final emailApiClientProvider = Provider<ApiClient>((ref) {
  // Sama dengan apiClientProvider di llm_providers.dart — pakai proxy
  // Edge Function yang sama untuk OAuth Gmail & LLM cloud fallback.
  return ApiClient(baseUrl: 'https://your-edge-function.example.workers.dev');
});

final emailListenerServiceProvider = Provider<EmailListenerService>((ref) {
  return EmailListenerService(apiClient: ref.watch(emailApiClientProvider));
});

final emailToScheduleParserProvider = Provider<EmailToScheduleParser>((ref) {
  return EmailToScheduleParser(
    intentParserService: ref.watch(intentParserServiceProvider),
  );
});

/// Status koneksi akun Gmail. State bertipe bool (true = terhubung),
/// diambil dari endpoint proxy backend, BUKAN dari token yang disimpan
/// lokal (sesuai aturan 3.2: client secret/token tidak boleh di app).
final gmailAuthStatusProvider =
    StateNotifierProvider<GmailAuthNotifier, AsyncValue<bool>>((ref) {
  return GmailAuthNotifier(
    apiClient: ref.watch(emailApiClientProvider),
    listenerService: ref.watch(emailListenerServiceProvider),
  );
});

class GmailAuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final ApiClient _apiClient;
  final EmailListenerService _listenerService;

  GmailAuthNotifier({
    required ApiClient apiClient,
    required EmailListenerService listenerService,
  })  : _apiClient = apiClient,
        _listenerService = listenerService,
        super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _apiClient.get(path: '/email/auth-status');
      return response.statusCode == 200 && response.body.contains('"connected":true');
    });
  }

  /// Membuka flow OAuth Gmail. Browser/WebView diarahkan ke endpoint
  /// proxy backend yang menangani OAuth consent screen + exchange
  /// authorization code -> refresh token (disimpan di server, bukan app).
  Future<void> connect() async {
    // TODO: buka url_launcher ke '/email/oauth-start' milik backend proxy,
    // lalu setelah redirect kembali, panggil _checkStatus() lagi.
    // Contoh:
    // await launchUrl(Uri.parse('${_apiClient.baseUrl}/email/oauth-start'));
    await _checkStatus();
    if (state.value == true) {
      await _listenerService.registerPushNotification();
    }
  }

  Future<void> disconnect() async {
    await _apiClient.post(path: '/email/disconnect');
    await _checkStatus();
  }
}