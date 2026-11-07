import 'package:flutter/material.dart';

/// All the colors the app uses, in one place.
class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const success = Color(0xFF10B981);
  static const warn = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const purple = Color(0xFF8B5CF6);

  // Light theme
  static const bg = Color(0xFFF9FAFB);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFE5E7EB);

  // Dark theme
  static const darkBg = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
}

/// Card background that adapts to light / dark mode.
Color cardOf(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark ? AppColors.darkCard : AppColors.card;

/// Thin border color that adapts to light / dark mode.
Color lineOf(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark ? Colors.white12 : AppColors.line;

/// Faded text color (used for subtitles and hints).
Color mutedOf(BuildContext c, [double alpha = 0.6]) =>
    Theme.of(c).colorScheme.onSurface.withValues(alpha: alpha);
