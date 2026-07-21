import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading2,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelSmall: AppTextStyles.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF04141A),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
      ),
      dividerColor: AppColors.divider,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      primaryColor: AppColors.primary,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        titleTextStyle: AppTextStyles.heading2.copyWith(color: const Color(0xFF0F172A)),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: const Color(0xFF0F172A)),
        displayMedium: AppTextStyles.heading2.copyWith(color: const Color(0xFF0F172A)),
        displaySmall: AppTextStyles.heading3.copyWith(color: const Color(0xFF0F172A)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF0F172A)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF334155)),
        labelSmall: AppTextStyles.caption.copyWith(color: const Color(0xFF64748B)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF94A3B8)),
      ),
      dividerColor: const Color(0xFFE2E8F0),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected) ? AppColors.primary : Colors.grey),
        trackColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected) ? AppColors.primary.withOpacity(0.5) : Colors.grey.shade300),
      ),
      listTileTheme: ListTileThemeData(
        textColor: const Color(0xFF0F172A),
        iconColor: const Color(0xFF0F172A),
      ),
    );
  }
}
