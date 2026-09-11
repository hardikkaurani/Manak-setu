import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';

/// Mobile-optimized Side-by-Side Redline Diff Viewer.
/// Directly reproduces the diff view from the web application and `manaksetu_mock_data.md`.
class DiffViewer extends StatelessWidget {
  final String originalText;
  final String recommendedText;
  final String itemTitle;
  final String statutoryAction;

  const DiffViewer({
    super.key,
    required this.originalText,
    required this.recommendedText,
    this.itemTitle = 'Specification Redline: Distribution Transformers',
    this.statutoryAction = 'Rectified obsolete Indian Standards, stripped proprietary vendor brand lock-ins, injected mandatory QCO citations, and replaced normative testing standards under GFR 144(vii).',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header & Audit Action
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SIDE-BY-SIDE REDLINE',
                      style: AppTextStyles.codeBadge.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Text(
                    'ORIGINAL DEFECTIVE NIT VS. COMPLIANT SPECIFICATION',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.compare_arrows,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      itemTitle,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUTORY AUDIT ACTION:',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statutoryAction,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 1. Original Clause (Defective) Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.nonCompliantBg.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.nonCompliantBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.nonCompliantBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6.5),
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppColors.nonCompliantBorder),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: AppColors.nonCompliantText,
                        ),
                        Text(
                          'ORIGINAL CLAUSE (DEFECTIVE)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.nonCompliantText,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge.nonCompliant(),
                  ],
                ),
              ),

              // Clause Text
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.nonCompliantBorder),
                  ),
                  child: Text(
                    originalText,
                    style: AppTextStyles.code.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              ),

              // Footer Warning
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      size: 15,
                      color: AppColors.nonCompliantText,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Violates CVC brand-neutrality, cites superseded edition, or omits mandatory ISI marks.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.nonCompliantText,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Rectified Clause (Legally Compliant) Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.verifiedBg.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.verifiedBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.verifiedBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6.5),
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppColors.verifiedBorder),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.verifiedText,
                        ),
                        Text(
                          'RECTIFIED CLAUSE (COMPLIANT)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.verifiedText,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge.ready('GFR-144 & BIS READY'),
                  ],
                ),
              ),

              // Clause Text
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.verifiedBorder),
                  ),
                  child: Text(
                    recommendedText,
                    style: AppTextStyles.code.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              ),

              // Footer Assurance
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 15,
                      color: AppColors.verifiedText,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Upgraded to latest gazetted revision, statutory ISI mark mandated, 100% brand-neutral.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.verifiedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
