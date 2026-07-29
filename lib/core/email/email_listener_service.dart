import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:shared_preferences/shared_preferences.dart';

String _decodeBase64(String str) {
  String normalized = str.replaceAll('-', '+').replaceAll('_', '/');
  switch (normalized.length % 4) {
    case 1: break; // invalid
    case 2: normalized += '=='; break;
    case 3: normalized += '='; break;
  }
  try {
    return utf8.decode(base64.decode(normalized));
  } catch (e) {
    return '';
  }
}

String _extractPlainText(gmail.MessagePart part) {
  if (part.mimeType == 'text/plain' && part.body?.data != null) {
    return _decodeBase64(part.body!.data!);
  }
  if (part.mimeType == 'text/html' && part.body?.data != null) {
    // LLM is perfectly capable of extracting intent from raw HTML
    return _decodeBase64(part.body!.data!);
  }
  if (part.parts != null) {
    String htmlFallback = '';
    for (var subPart in part.parts!) {
      final text = _extractPlainText(subPart);
      if (text.isNotEmpty) {
        // Prefer plain text, but save html as fallback if we only find html
        if (subPart.mimeType == 'text/html') {
          htmlFallback = text;
        } else {
          return text; 
        }
      }
    }
    return htmlFallback;
  }
  return '';
}

/// Mendengarkan email masuk via Gmail API langsung dari aplikasi
/// menggunakan kredensial OAuth 2.0.
class EmailListenerService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      gmail.GmailApi.gmailReadonlyScope,
      'https://www.googleapis.com/auth/calendar.events',
      'email',
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

  Future<void> fetchNow(void Function(List<Map<String, dynamic>> newEmails) onNewEmails) async {
    final isLogged = await isSignedIn();
    if (!isLogged) throw Exception("Sesi habis, silakan login ulang.");

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception("Client OAuth null. Harap ceklis izin membaca email saat login Google.");

    final prefs = await SharedPreferences.getInstance();
    final processedIds = prefs.getStringList('processed_email_ids') ?? [];

    final gmailApi = gmail.GmailApi(client);
    // Mengambil semua email (dibaca atau belum) dari 7 hari terakhir
    final response = await gmailApi.users.messages.list('me', q: 'newer_than:7d');
    
    final messages = response.messages;
    if (messages != null && messages.isNotEmpty) {
      List<Map<String, dynamic>> newEmailsList = [];
      List<String> newlyProcessedIds = [];
      
      for (var msg in messages.take(10)) {
        if (processedIds.contains(msg.id)) continue;

        final msgDetail = await gmailApi.users.messages.get('me', msg.id!);
        
        // Extract Subject
        String subject = '';
        final headers = msgDetail.payload?.headers;
        if (headers != null) {
          final subjectHeader = headers.cast<gmail.MessagePartHeader?>().firstWhere(
            (h) => h?.name?.toLowerCase() == 'subject', 
            orElse: () => null
          );
          subject = subjectHeader?.value ?? '';
        }

        // Extract Body Text recursively
        String bodyText = msgDetail.snippet ?? '';
        if (msgDetail.payload != null) {
          final extracted = _extractPlainText(msgDetail.payload!);
          if (extracted.isNotEmpty) {
            bodyText = extracted;
          } else if (msgDetail.payload!.body?.data != null) {
            bodyText = _decodeBase64(msgDetail.payload!.body!.data!);
          }
        }

        newEmailsList.add({
          'id': msgDetail.id,
          'subject': subject,
          'body': bodyText,
        });
        
        newlyProcessedIds.add(msg.id!);
      }
      
      if (newEmailsList.isNotEmpty) {
        onNewEmails(newEmailsList);
        
        // Simpan ID agar tidak diproses lagi
        processedIds.addAll(newlyProcessedIds);
        // Batasi memori cache ID (simpan maks 100 ID terbaru)
        if (processedIds.length > 100) {
          processedIds.removeRange(0, processedIds.length - 100);
        }
        await prefs.setStringList('processed_email_ids', processedIds);
      }
    }
  }

  void startPolling({
    required void Function(List<Map<String, dynamic>> newEmails) onNewEmails,
    Duration interval = const Duration(minutes: 15),
  }) {
    _pollingTimer?.cancel();
    
    Future<void> fetchEmails() async {
      try {
        await fetchNow(onNewEmails);
      } catch (e) {
        print("Polling error: $e");
      }
    }

    // Eksekusi penarikan email secara langsung saat fungsi dipanggil pertama kali
    fetchEmails();
    
    // Lalu jalankan berulang sesuai interval
    _pollingTimer = Timer.periodic(interval, (_) => fetchEmails());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}