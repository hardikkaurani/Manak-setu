import 'package:flutter/material.dart';

import '../models/amendment_diff.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'knowledge_state_badge.dart';

/// Modal bottom sheet presenting "What Changed?" — Edition history, supersession transitions,
/// and gazetted amendments for an Indian Standard.
class AmendmentDiffSheet extends StatelessWidget {
  final AmendmentDiff diff;

  const AmendmentDiffSheet({
    super.key,
    required this.diff,
  });

  static void show(BuildContext context, {required AmendmentDiff diff}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AmendmentDiffSheet(diff: diff),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    Icons.history_edu_outlined,
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
                        'EDITION & AMENDMENT HISTORY',
                        style: AppTextStyles.pageEyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'What Changed: ${diff.standardCode}',
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
                  Text(diff.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                  const SizedBox(height: 14),

                  // Edition Lifecycle Transition Banner
                  Text('LIFECYCLE TRANSITION', style: AppTextStyles.sectionEyebrow),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (diff.previousEdition != null) ...[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('SUPERSEDED EDITION', style: AppTextStyles.caption.copyWith(fontSize: 9.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      diff.previousEdition!,
                                      style: AppTextStyles.codeBadge.copyWith(
                                        color: AppColors.nonCompliantText,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: AppColors.verifiedText, size: 16),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ACTIVE REVISION', style: AppTextStyles.caption.copyWith(fontSize: 9.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    diff.currentEdition,
                                    style: AppTextStyles.codeBadge.copyWith(
                                      color: AppColors.verifiedText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (diff.supersessionTransition != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            diff.supersessionTransition!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gazette Amendments Timeline
                  Text('GAZETTED AMENDMENTS (${diff.amendments.length})', style: AppTextStyles.sectionEyebrow),
                  const SizedBox(height: 8),
                  if (diff.amendments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'No formal gazetted amendments published for this edition to date.',
                        style: AppTextStyles.bodySmall,
                      ),
                    )
                  else
                    ...diff.amendments.map((amd) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
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
                                Text(
                                  amd.amendmentNumber,
                                  style: AppTextStyles.codeBadge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                KnowledgeStateBadge(state: amd.state, isCompact: true),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Gazette Ref: ${amd.gazetteReference} · Enacted: ${amd.dateOrYear}',
                              style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              amd.scopeSummary,
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 11.5, height: 1.35),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 14),

                  // Honest Diff Notice
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.reviewBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.reviewBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            diff.diffNotice,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
}
