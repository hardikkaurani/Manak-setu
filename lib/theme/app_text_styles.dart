import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Institutional Government Typography for ManakSetu
/// Dense, restrained, and legible. Designed for technical/statutory reading.
abstract final class AppTextStyles {
  // Brand / Top Header
  static const TextStyle brandTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryContainer,
    letterSpacing: 1.5,
    height: 1.0,
  );

  // Page Headings
  static const TextStyle pageEyebrow = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: 1.8,
    height: 1.2,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Section Headers
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  static const TextStyle sectionEyebrow = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  // Card & Body Text
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Monospace for Technical Standards & Regulatory Codes
  static const TextStyle code = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.3,
  );

  static const TextStyle codeBadge = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Form Field Labels
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  // Button Labels
  static const TextStyle button = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}
