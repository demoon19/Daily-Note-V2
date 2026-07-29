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
    parser: ref.watch(emailToScheduleParserProvider),
    router: ref.watch(intentRouterProvider),
  );
});

class GmailAuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final EmailListenerService _listenerService;
  final EmailToScheduleParser _parser;
  final IntentRouter _router;

  GmailAuthNotifier({
    required EmailListenerService listenerService,
    required EmailToScheduleParser parser,
    required IntentRouter router,
  })  : _listenerService = listenerService,
        _parser = parser,
        _router = router,
        super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _listenerService.isSignedIn();
    });
    if (state.value == true) {
      _startEmailPolling();
    }
  }

  void _startEmailPolling() {
    _listenerService.startPolling(
      onNewEmails: (newEmails) async {
        for (final email in newEmails) {
          final snippet = email['snippet'] ?? '';
          try {
            final response = await _parser.parseEmail(
              subject: snippet, 
              bodySnippet: snippet,
            );
            await _router.route(response);
          } catch (e) {
            print('Error parsing email: $e');
          }
        }
      },
    );
  }

  /// Membuka flow OAuth Gmail langsung dari device via google_sign_in.
  Future<void> connect() async {
    try {
      final success = await _listenerService.signIn();
      if (!success) {
        state = const AsyncValue.data(false);
        return;
      }
      await _checkStatus();
      if (state.value == true) {
        await _listenerService.registerPushNotification();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> disconnect() async {
    await _listenerService.signOut();
    _listenerService.stopPolling();
    await _checkStatus();
  }
}