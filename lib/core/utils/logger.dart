import 'package:flutter/foundation.dart';

/// Logger sederhana dipakai lintas fitur agar konsisten,
/// terutama untuk debugging alur LLM (on-device -> cloud fallback).
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    if (kDebugMode) {
      print('[$tag] ⚠️ $message');
    }
  }

  static void error(String message,
      {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[$tag] ❌ $message');
      if (error != null) print('  error: $error');
      if (stackTrace != null) print('  stackTrace: $stackTrace');
    }
  }

  /// Khusus logging alur intent parsing, membantu debug
  /// kapan on-device gagal dan fallback cloud dipanggil.
  static void logIntentFlow(String stage, {String? detail}) {
    debug('IntentFlow: $stage${detail != null ? ' — $detail' : ''}',
        tag: 'INTENT');
  }
}