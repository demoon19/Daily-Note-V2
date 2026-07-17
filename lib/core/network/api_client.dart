import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client HTTP generik untuk komunikasi ke backend/proxy
/// (Cloudflare Workers / Supabase Edge Functions).
/// Semua request lintas fitur ke backend harus lewat class ini
/// agar tidak duplikasi konfigurasi base URL/header.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<http.Response> post({
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    return _httpClient.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> get({
    required String path,
    Map<String, String>? headers,
  }) {
    return _httpClient.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
  }
}