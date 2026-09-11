import 'package:flutter/material.dart';

/// Institutional Government Color Palette for ManakSetu
/// Strictly mirrors the Next.js globals.css and BIS/CVC design language.
abstract final class AppColors {
  // Primary Institutional Navy
  static const Color primary = Color(0xFF002446); // --primary
  static const Color primaryContainer = Color(
    0xFF123A63,
  ); // --primary-container
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFD6E4FF);

  // Secondary Warm Accent / Gold / Amber
  static const Color secondary = Color(0xFF885200); // --secondary
  static const Color secondaryContainer = Color(
    0xFFFEA93E,
  ); // --secondary-container
  static const Color secondaryLight = Color(0xFFFFF3E0);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary Government Green
  static const Color tertiary = Color(0xFF002B0F); // --tertiary
  static const Color tertiaryContainer = Color(
    0xFF00431B,
  ); // --tertiary-container
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surface & Background Tones
  static const Color background = Color(0xFFF8F9FF); // --background
  static const Color foreground = Color(0xFF081D30); // --foreground
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEEF4FF);
  static const Color surfaceContainer = Color(0xFFE5EFFF);
  static const Color surfaceContainerHigh = Color(0xFFDBE9FF);

  // Structural Outlines & Dividers
  static const Color outline = Color(0xFF73777F); // --outline
  static const Color outlineVariant = Color(0xFFC3C6D0); // --outline-variant
  static const Color outlineSubtle = Color(0xFFE2E8F0);

  // Text Shades
  static const Color textPrimary = Color(0xFF081D30);
  static const Color textSecondary = Color(0xFF495057);
  static const Color textMuted = Color(0xFF73777F);
  static const Color textLight = Color(0xFF94A3B8);

  // Statutory Status Accents
  static const Color verifiedBg = Color(0xFFE8F5E9);
  static const Color verifiedText = Color(0xFF0D6832);
  static const Color verifiedBorder = Color(0xFFA5D6A7);

  static const Color reviewBg = Color(0xFFFFF8E1);
  static const Color reviewText = Color(0xFF885200);
  static const Color reviewBorder = Color(0xFFFFD54F);

  static const Color nonCompliantBg = Color(0xFFFFEDEA);
  static const Color nonCompliantText = Color(0xFFBA1A1A);
  static const Color nonCompliantBorder = Color(0xFFFF897D);

  static const Color obsoleteBg = Color(0xFFF1F5F9);
  static const Color obsoleteText = Color(0xFF475569);
  static const Color obsoleteBorder = Color(0xFFCBD5E1);

  static const Color qcoBadgeBg = Color(0xFFE0F2FE);
  static const Color qcoBadgeText = Color(0xFF0369A1);
  static const Color qcoBadgeBorder = Color(0xFFBAE6FD);
}
