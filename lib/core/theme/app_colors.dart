import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool dark = false;

  // Deep Teal Primary Palette (brand - constant in both themes)
  static const Color primary = Color(0xFF0F4C44);
  static const Color primaryDark = Color(0xFF0A3630);
  static const Color primaryLight = Color(0xFF1B6B60);
  static const Color accent = Color(0xFF147A6D);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFE11D48);
  static const Color warning = Color(0xFFF59E0B);
  static const Color textOnPrimary = Colors.white;

  // Adaptive surfaces - resolve per current brightness
  static Color get primarySoft =>
      dark ? const Color(0xFF14322C) : const Color(0xFFE8F5F1);
  static Color get primaryTint =>
      dark ? const Color(0xFF1D443C) : const Color(0xFFD4EFE8);
  static Color get background =>
      dark ? const Color(0xFF0A100F) : const Color(0xFFF8FAF9);
  static Color get surface => dark ? const Color(0xFF0F1817) : Colors.white;
  static Color get surfaceVariant =>
      dark ? const Color(0xFF16201E) : const Color(0xFFF1F5F4);

  static Color get textPrimary =>
      dark ? const Color(0xFFE6EEEC) : const Color(0xFF111827);
  static Color get textSecondary =>
      dark ? const Color(0xFFB6C2BF) : const Color(0xFF4B5563);
  static Color get textMuted =>
      dark ? const Color(0xFF7F8F8B) : const Color(0xFF9CA3AF);

  static Color get border =>
      dark ? const Color(0xFF26322F) : const Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFF0F4C44);
}