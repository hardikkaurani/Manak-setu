import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Prominent mobile-friendly audit scorecard displaying compliance evaluation,
/// critical defects count, high-risk violations count, and immediate rectification warning.
class AuditScorecard extends StatelessWidget {
  final int score;
  final String status;
  final int criticalCount;
  final int highCount;
  final String summaryText;
  final VoidCallback onBuildSpecification;
  final VoidCallback? onViewDecisionTrace;

  const AuditScorecard({
    super.key,
    required this.score,
    required this.status,
    required this.criticalCount,
    required this.highCount,
    required this.summaryText,
    required this.onBuildSpecification,
    this.onViewDecisionTrace,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfCoverage = status == 'OUT_OF_COVERAGE' || status == 'UNKNOWN';
    final accentColor = isOutOfCoverage ? AppColors.reviewText : AppColors.nonCompliantText;
    final accentBg = isOutOfCoverage ? AppColors.reviewBg : AppColors.nonCompliantBg;
    final accentBorder = isOutOfCoverage ? AppColors.reviewBorder : AppColors.nonCompliantBorder;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentBg.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              border: Border(
                bottom: BorderSide(color: accentBorder),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOutOfCoverage ? Icons.help_outline : Icons.gavel,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOutOfCoverage ? 'COVERAGE INTELLIGENCE' : 'COMPLIANCE EVALUATION',
                      style: AppTextStyles.caption.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                isOutOfCoverage
                    ? StatusBadge.review(status)
                    : StatusBadge.nonCompliant(status),
              ],
            ),
          ),

          // Main Score & KPI Metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Big percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.nonCompliantBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.nonCompliantBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$score%',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.nonCompliantText,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUTORY COMPLIANCE INDEX',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'High Statutory Audit Risk',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.nonCompliantText,
                            ),
                          ),
                          Text(
                            'Retrieval & Statutory Rule Confidence: $score%',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // KPI Metric Boxes (Critical & High-Risk)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.nonCompliantBg.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.nonCompliantBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$criticalCount',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.nonCompliantText,
                                  ),
                                ),
                                const Icon(
                                  Icons.error_outline,
                                  size: 16,
                                  color: AppColors.nonCompliantText,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Critical Defects',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.nonCompliantText,
                              ),
                            ),
                            Text(
                              'Brand bias violations',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.reviewBg.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.reviewBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$highCount',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.reviewText,
                                  ),
                                ),
                                const Icon(
                                  Icons.warning_amber_outlined,
                                  size: 16,
                                  color: AppColors.reviewText,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'High-Risk Violations',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.reviewText,
                              ),
                            ),
                            Text(
                              'Obsolete standards cited',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Statutory Warning Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.report_problem,
                        color: AppColors.nonCompliantText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summaryText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Direct Action Buttons
                PrimaryButton(
                  label: 'BUILD COMPLIANT SPECIFICATION →',
                  icon: Icons.edit_document,
                  onPressed: onBuildSpecification,
                ),
                if (onViewDecisionTrace != null) ...[
                  const SizedBox(height: 8),
                  SecondaryButton(
                    label: 'VIEW AUDIT DECISION TRACE & EVIDENCE CHAIN',
                    icon: Icons.account_tree_outlined,
                    onPressed: onViewDecisionTrace!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
