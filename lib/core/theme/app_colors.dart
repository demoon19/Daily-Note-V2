import 'package:flutter/material.dart';

/// Semua warna dipakai lintas fitur — jangan hardcode Color(...)
/// langsung di widget fitur, selalu rujuk ke sini.
class AppColors {
  AppColors._();

  // Base (dark theme sebagai default)
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFF00CEC9);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF6B6B6B);

  // Semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF1C40F);
  static const Color error = Color(0xFFE74C3C);

  // Per-fitur accent (opsional, dipakai untuk badge/kategori)
  static const Color calendarAccent = Color(0xFF6C5CE7);
  static const Color todoAccent = Color(0xFF00B894);
  static const Color notesAccent = Color(0xFFFDCB6E);
  static const Color expenseAccent = Color(0xFFE17055);
  static const Color reminderAccent = Color(0xFF0984E3);

  static const Color border = Color(0xFF333333);
  static const Color divider = Color(0xFF2A2A2A);
}