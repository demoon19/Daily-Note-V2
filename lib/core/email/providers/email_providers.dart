import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../email_listener_service.dart';
import '../email_to_schedule_parser.dart';
import '../../ai/providers/llm_providers.dart';
import '../../ai/providers/intent_router_provider.dart';
import '../../ai/intent_router.dart';

final emailListenerServiceProvider = Provider<EmailListenerService>((ref) {
  return EmailListenerService();
});

final emailToScheduleParserProvider = Provider<EmailToScheduleParser>((ref) {
  return EmailToScheduleParser(
    intentParserService: ref.watch(intentParserServiceProvider),
  );
});

/// Status koneksi akun Gmail. State bertipe bool (true = terhubung),
/// menggunakan Google Sign In plugin.
final gmailAuthStatusProvider =
    StateNotifierProvider<GmailAuthNotifier, AsyncValue<bool>>((ref) {
  return GmailAuthNotifier(
    listenerService: ref.watch(emailListenerServiceProvider),
  );
});

class GmailAuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final EmailListenerService _listenerService;

  GmailAuthNotifier({
    required EmailListenerService listenerService,
  })  : _listenerService = listenerService,
        super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _listenerService.isSignedIn();
    });
  }

  /// Membuka flow OAuth Gmail langsung dari device via google_sign_in.
  Future<void> connect() async {
    await _listenerService.signIn();
    await _checkStatus();
    if (state.value == true) {
      await _listenerService.registerPushNotification();
    }
  }

  Future<void> disconnect() async {
    await _listenerService.signOut();
    await _checkStatus();
  }
}