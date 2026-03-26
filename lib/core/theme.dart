import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF3730A3);

  // Secondary
  static const secondary = Color(0xFF7C3AED);
  static const secondaryLight = Color(0xFFA78BFA);

  // Accent (time credits / gold)
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFCD34D);

  // Semantic
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Light surfaces
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightText = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);

  // Dark surfaces
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const darkText = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);

  // Gradient presets
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFF97316)],
  );

  static const cardGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F4FF), Color(0xFFF8F0FF)],
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: textTheme.labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primaryLight.withOpacity(0.2),
        labelStyle: textTheme.labelSmall?.copyWith(color: AppColors.darkText),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }
}
