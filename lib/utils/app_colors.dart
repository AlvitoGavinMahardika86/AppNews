import 'package:flutter/material.dart';

class AppColors {
  // Light slate-blue palette
  static const Color primary = Color(0xFF315A7D);
  static const Color primaryLight = Color(0xFF6096BA);
  static const Color primaryDark = Color(0xFF203A52);

  static const Color accent = Color(0xFF6096BA);
  static const Color accentLight = Color(0xFF8AB6D6);

  // Secondary
  static const Color secondary = Color(0xFF6F9FBE);
  static const Color secondaryLight = Color(0xFFA7C8DD);

  // Background
  static const Color background = Color(0xFFF5F8FB);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEDF3F7);

  // Status
  static const Color error = Color(0xFFB84A4A);
  static const Color success = Color(0xFF4C8A68);
  static const Color warning = Color(0xFFB8874A);

  // On colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF172B3A);
  static const Color onSurface = Color(0xFF172B3A);
  static const Color onError = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF172B3A);
  static const Color textSecondary = Color(0xFF687B89);
  static const Color textHint = Color(0xFF9AAAB5);

  // Additional
  static const Color divider = Color(0xFFD8E3EA);
  static const Color cardShadow = Color(0x1A315A7D);
  static const Color shimmerBase = Color(0xFFE1EAF0);
  static const Color shimmerHighlight = Color(0xFFF5F8FB);

  // Bookmark
  static const Color bookmarkActive = Color(0xFF315A7D);
  static const Color bookmarkInactive = Color(0xFF9AAAB5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF315A7D), Color(0xFF6096BA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF203A52), Color(0xFF315A7D), Color(0xFF6096BA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Nav bar
  static const Color navBarBackground = Colors.white;
  static const Color navBarSelected = Color(0xFF315A7D);
  static const Color navBarUnselected = Color(0xFF9AAAB5);
}
