import 'package:flutter/material.dart';

import '../models/why_this_standard.dart';
import '../models/knowledge_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'knowledge_state_badge.dart';

/// Modal bottom sheet presenting the technical rationale: "Why this standard?"
/// Displays matched technical requirements, verification signals, and rejected/deprioritized alternatives.
class WhyThisStandardSheet extends StatelessWidget {
  final WhyThisStandard data;
  final VoidCallback? onViewEvidence;

  const WhyThisStandardSheet({
    super.key,
    required this.data,
    this.onViewEvidence,
  });

  static void show(
    BuildContext context, {
    WhyThisStandard? data,
    WhyThisStandard? rationale,
    VoidCallback? onViewEvidence,
  }) {
    final effectiveData = rationale ?? data;
    if (effectiveData == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WhyThisStandardSheet(
        data: effectiveData,
        onViewEvidence: onViewEvidence,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TECHNICAL SELECTION RATIONALE',
                        style: AppTextStyles.pageEyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Why ${data.standardCode}?',
                        style: AppTextStyles.brandTitle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Standard title & status
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        data.standardCode,
                        style: AppTextStyles.code.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      KnowledgeStateBadge(state: data.knowledgeState),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(data.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                  const SizedBox(height: 12),

                  // Verification Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VERIFICATION SUMMARY', style: AppTextStyles.sectionEyebrow),
                        const SizedBox(height: 4),
                        Text(
                          data.verificationSummary,
                          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Matched Requirements Section
                  if (data.matchedRequirements.isNotEmpty) ...[
                    Text('MATCHED SPECIFICATION REQUIREMENTS', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: data.matchedRequirements.entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.outlineSubtle),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    entry.key.toUpperCase(),
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Alternatives Considered Section
                  if (data.alternativesConsidered.isNotEmpty) ...[
                    Text('ALTERNATIVES CONSIDERED & EXCLUSION REASONS', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 8),
                    ...data.alternativesConsidered.map((alt) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: alt.status == KnowledgeState.conflicting ||
                                    alt.status == KnowledgeState.outOfCoverage
                                ? AppColors.nonCompliantBorder
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alt.standardCode,
                                    style: AppTextStyles.code.copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                KnowledgeStateBadge(
                                  state: alt.status,
                                  isCompact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alt.title,
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                                      children: [
                                        const TextSpan(
                                          text: 'Why considered: ',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        TextSpan(text: alt.whyConsidered),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 11,
                                        color: AppColors.nonCompliantText,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Why rejected: ',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        TextSpan(text: alt.whyRejected),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],

                  // Action: View BIS Evidence if available
                  if (data.isEvidenceAvailable && onViewEvidence != null) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: const Icon(Icons.menu_book, size: 16),
                        label: const Text(
                          'INSPECT AUTHORITATIVE BIS EVIDENCE',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onViewEvidence!();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
