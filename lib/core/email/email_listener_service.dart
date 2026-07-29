import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

/// Mendengarkan email masuk via Gmail API langsung dari aplikasi
/// menggunakan kredensial OAuth 2.0.
class EmailListenerService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Di Android, clientId memicu DEVELOPER_ERROR jika diisi dengan Client ID Android
    // clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: [
      gmail.GmailApi.gmailReadonlyScope,
    ],
  );

  Timer? _pollingTimer;

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (error) {
      print("Error signing in: $error");
      throw Exception("Gagal login Google: $error");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  Future<void> registerPushNotification() async {
    // Tanpa backend, kita tidak bisa dengan mudah setup webhooks push notification
    // karena localhost tidak bisa menerima webhook dari google server.
    // Jadi kita biarkan kosong dan bergantung pada polling lokal.
  }

  void startPolling({
    required void Function(List<Map<String, dynamic>> newEmails) onNewEmails,
    Duration interval = const Duration(minutes: 15),
  }) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) async {
      final isLogged = await isSignedIn();
      if (!isLogged) return;

      try {
        final client = await _googleSignIn.authenticatedClient();
        if (client == null) return;

        final gmailApi = gmail.GmailApi(client);
        // Ambil email baru (misalnya menggunakan historyId atau ambil yg belum dibaca)
        // Di sini contoh sederhana mengambil email unread dari inbox.
        final response = await gmailApi.users.messages.list('me', q: 'is:unread');
        
        final messages = response.messages;
        if (messages != null && messages.isNotEmpty) {
          List<Map<String, dynamic>> newEmailsList = [];
          for (var msg in messages.take(5)) {
            final msgDetail = await gmailApi.users.messages.get('me', msg.id!);
            newEmailsList.add({
              'id': msgDetail.id,
              'snippet': msgDetail.snippet,
              // Anda bisa menambahkan parsing payload body/header di sini
            });
          }
          onNewEmails(newEmailsList);
        }
      } catch (e) {
        print("Polling error: $e");
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}