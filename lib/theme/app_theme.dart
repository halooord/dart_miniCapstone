import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0B0D11);
  static const surface = Color(0xFF171A22);
  static const surfaceAlt = Color(0xFF20242E);
  static const border = Color(0xFF303440);
  static const orange = Color(0xFFFF8038);
  static const orangeSoft = Color(0xFFFFB177);
  static const text = Color(0xFFF7F7F8);
  static const muted = Color(0xFF979CA9);
  static const success = Color(0xFF7DE0AE);
}

ThemeData buildTheme() {
  const outline = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide(color: AppColors.border),
  );
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      primary: AppColors.orange,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 19,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.text,
        fontSize: 35,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: AppColors.text,
        fontSize: 26,
        fontWeight: FontWeight.w900,
        height: 1.15,
        letterSpacing: -.7,
      ),
      titleLarge: TextStyle(
          color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(
          color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.45),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: TextStyle(color: AppColors.muted),
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.orange, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: TextStyle(color: AppColors.text),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: AppColors.border,
  );
}
