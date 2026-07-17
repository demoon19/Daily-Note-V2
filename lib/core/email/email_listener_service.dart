import 'dart:async';
import '../network/api_client.dart';

/// Mendengarkan email masuk via Gmail API. OAuth & client secret
/// WAJIB ditangani di backend proxy (Cloudflare Workers/Supabase
/// Edge Functions) — tidak boleh disimpan di app.
/// Gunakan push notification (Gmail Pub/Sub) jika tersedia,
/// polling interval hanya sebagai fallback.
class EmailListenerService {
  final ApiClient _apiClient;
  Timer? _pollingTimer;

  EmailListenerService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Dipanggil sekali untuk mendaftarkan push notification
  /// (jika backend sudah mendukung Gmail Pub/Sub).
  Future<void> registerPushNotification() async {
    await _apiClient.post(path: '/email/register-push');
  }

  /// Fallback: polling berkala jika push tidak tersedia.
  void startPolling({
    required void Function(List<Map<String, dynamic>> newEmails) onNewEmails,
    Duration interval = const Duration(minutes: 15),
  }) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) async {
      final response = await _apiClient.get(path: '/email/unread');
      if (response.statusCode == 200) {
        // TODO: decode response.body -> List<Map<String, dynamic>>
        onNewEmails(const []);
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}