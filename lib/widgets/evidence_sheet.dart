import 'package:flutter/material.dart';

import '../models/evidence.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';

/// Modal bottom sheet displaying authoritative BIS evidence for a specific finding.
class EvidenceSheet extends StatelessWidget {
  final Evidence evidence;
  final String title;
  final String? subtitle;

  const EvidenceSheet({
    super.key,
    required this.evidence,
    required this.title,
    this.subtitle,
  });

  static Future<void> show(
    BuildContext context, {
    required Evidence evidence,
    required String title,
    String? subtitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EvidenceSheet(evidence: evidence, title: title, subtitle: subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDefectiveVsReplacement =
        evidence.defectiveStandardCode != null &&
        evidence.replacementStandardCode != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: AppColors.primaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIS STATUTORY EVIDENCE',
                        style: AppTextStyles.pageEyebrow.copyWith(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: AppTextStyles.sectionTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.textMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Scrollable Evidence Details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Defective vs Replacement Comparison if applicable
                  if (hasDefectiveVsReplacement) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUTORY AUDIT REVISION STATUS',
                            style: AppTextStyles.sectionEyebrow,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CITED DEFECTIVE:',
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: 3),
                                    StatusBadge.nonCompliant(
                                      evidence.defectiveStandardCode!,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppColors.outline,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'MANDATED REPLACEMENT:',
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: 3),
                                    StatusBadge.verified(
                                      evidence.replacementStandardCode!,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Document Citation Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'EVIDENCE CITATION',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.verifiedBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: AppColors.verifiedText,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'GAZETTED RECORD',
                                    style: AppTextStyles.codeBadge.copyWith(
                                      color: AppColors.verifiedText,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildCitationRow(
                          'Governing Standard',
                          evidence.standardCode,
                        ),
                        if (evidence.clause != null)
                          _buildCitationRow(
                            'Section / Clause',
                            evidence.clause!,
                          ),
                        if (evidence.page != null)
                          _buildCitationRow(
                            'Document Page',
                            'Page ${evidence.page!}',
                          ),
                        if (evidence.table != null)
                          _buildCitationRow(
                            'Table / Schedule',
                            evidence.table!,
                          ),
                        _buildCitationRow(
                          'Source File',
                          evidence.sourceFile,
                          isMono: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quoted Text Excerpt
                  Text(
                    'VERBATIM STATUTORY EXCERPT',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      '“${evidence.textExcerpt}”',
                      style: AppTextStyles.body.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Close CTA
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('DISMISS EVIDENCE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isMono
                  ? AppTextStyles.code.copyWith(fontSize: 11)
                  : AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
