import 'package:flutter/material.dart';

import '../models/decision_trace.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'evidence_sheet.dart';
import 'knowledge_state_badge.dart';

/// Modal bottom sheet presenting the 8-stage Decision Trace & Evidence Chain.
/// Represents an institutional engineering audit trail showing:
/// Tender Clause -> Extracted Requirements -> Retrieved Candidates -> Selection & Exclusions
/// -> Selected Standard & Lifecycle -> Authoritative Evidence -> Verification State -> Human Review.
class DecisionTraceSheet extends StatelessWidget {
  final DecisionTrace trace;

  const DecisionTraceSheet({
    super.key,
    required this.trace,
  });

  static void show(BuildContext context, {required DecisionTrace trace}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DecisionTraceSheet(trace: trace),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
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
                    Icons.account_tree_outlined,
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
                        'STATUTORY AUDIT & REASONING CHAIN',
                        style: AppTextStyles.pageEyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Decision Trace: ${trace.selectedStandard?.code ?? "Statutory Scrutiny"}',
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

          // 8-Stage Audit Stepper
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage 1: Tender Clause
                  _buildTraceStage(
                    stageNumber: 1,
                    stageTitle: 'TENDER SPECIFICATION CLAUSE',
                    icon: Icons.description_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tender: ${trace.tenderTitle} (${trace.tenderId})',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Entity: ${trace.department}',
                          style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trace.inputClause,
                            style: AppTextStyles.code.copyWith(fontSize: 11, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stage 2: Extracted Technical Requirements
                  _buildTraceStage(
                    stageNumber: 2,
                    stageTitle: 'EXTRACTED TECHNICAL REQUIREMENTS',
                    icon: Icons.list_alt_outlined,
                    child: Column(
                      children: trace.extractedRequirements.map((req) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.parameter,
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'Specified: ${req.specifiedValue}',
                                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      req.note,
                                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              KnowledgeStateBadge(state: req.state, isCompact: true),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Stage 3: Retrieved Candidates & Ranking Signals
                  _buildTraceStage(
                    stageNumber: 3,
                    stageTitle: 'RETRIEVED CANDIDATES & RANKING SIGNALS',
                    icon: Icons.manage_search,
                    child: Column(
                      children: trace.retrievedCandidates.map((cand) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cand.isSelected ? const Color(0xFFEFF6FF) : AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: cand.isSelected ? AppColors.primary : AppColors.outlineVariant,
                              width: cand.isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cand.isSelected ? AppColors.primary : AppColors.outline,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '#${cand.rank}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      cand.standardCode,
                                      style: AppTextStyles.code.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'Signal: ${(cand.retrievalScore * 100).toStringAsFixed(0)}%',
                                      style: AppTextStyles.codeBadge.copyWith(fontSize: 9.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(cand.title, style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
                              const SizedBox(height: 4),
                              Text(
                                'Consideration: ${cand.considerationReason}',
                                style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textSecondary),
                              ),
                              if (cand.rejectionReason != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Exclusion reason: ${cand.rejectionReason!}',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.nonCompliantText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Stage 4: Selection & Exclusion Justification
                  _buildTraceStage(
                    stageNumber: 4,
                    stageTitle: 'SELECTION & EXCLUSION JUSTIFICATION',
                    icon: Icons.rule_folder_outlined,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                trace.selectedStandard != null
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                size: 14,
                                color: trace.selectedStandard != null
                                    ? AppColors.verifiedText
                                    : AppColors.reviewText,
                              ),
                              const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                trace.selectedStandard != null
                                    ? 'SELECTED: ${trace.selectedStandard!.code}'
                                    : 'NO STANDARD RESOLVED (OUT-OF-COVERAGE)',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: trace.selectedStandard != null
                                      ? AppColors.verifiedText
                                      : AppColors.reviewText,
                                ),
                              ),
                            ),
                          ],
                        ),
                          const SizedBox(height: 4),
                          Text(
                            trace.selectionReason,
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11.5, height: 1.35),
                          ),
                          if (trace.exclusionReasons.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'EXCLUSION RATIONALE:',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                            const SizedBox(height: 3),
                            ...trace.exclusionReasons.map((ex) => Text('• $ex', style: AppTextStyles.caption.copyWith(fontSize: 10.5))),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Stage 5: Standard Lifecycle & Gazette State
                  _buildTraceStage(
                    stageNumber: 5,
                    stageTitle: 'STANDARD LIFECYCLE & GAZETTE STATE',
                    icon: Icons.verified_outlined,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trace.selectedStandard?.code ?? 'OUT-OF-COVERAGE',
                                style: AppTextStyles.code.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'Revision: ${trace.selectedStandard?.edition ?? "Manual Gazette Resolution Required"}',
                                style: AppTextStyles.caption.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: trace.lifecycleState == 'CURRENT' ? AppColors.verifiedBg : AppColors.obsoleteBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: trace.lifecycleState == 'CURRENT' ? AppColors.verifiedBorder : AppColors.obsoleteBorder,
                            ),
                          ),
                          child: Text(
                            trace.lifecycleState,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: trace.lifecycleState == 'CURRENT' ? AppColors.verifiedText : AppColors.obsoleteText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stage 6: Authoritative BIS Evidence
                  _buildTraceStage(
                    stageNumber: 6,
                    stageTitle: 'AUTHORITATIVE BIS EVIDENCE & CITATIONS',
                    icon: Icons.menu_book,
                    child: trace.evidence != null
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trace.evidence!.citationDisplay,
                                  style: AppTextStyles.codeBadge.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Source File: ${trace.evidence!.sourceFile}',
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    trace.evidence!.textExcerpt,
                                    style: AppTextStyles.code.copyWith(fontSize: 10.5, height: 1.35),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.open_in_new, size: 12),
                                    label: const Text('OPEN FULL EVIDENCE SHEET', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                                    onPressed: () {
                                      EvidenceSheet.show(
                                        context,
                                        evidence: trace.evidence!,
                                        title: '${trace.selectedStandard?.code ?? "Statutory"} Evidence',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text('Evidence indexed in local regulatory store.', style: AppTextStyles.caption),
                  ),

                  // Stage 7: Statutory Verification State
                  _buildTraceStage(
                    stageNumber: 7,
                    stageTitle: 'STATUTORY VERIFICATION STATE',
                    icon: Icons.shield_outlined,
                    child: Row(
                      children: [
                        KnowledgeStateBadge(state: trace.verificationState),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trace.verificationState.description,
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stage 8: Final Recommendation & Human Approval Gate
                  _buildTraceStage(
                    stageNumber: 8,
                    stageTitle: 'FINAL RECOMMENDATION & HUMAN APPROVAL GATE',
                    icon: Icons.how_to_reg,
                    isLast: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trace.finalRecommendation,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Officer Review Status:',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFF59E0B)),
                              ),
                              child: Text(
                                trace.humanApprovalState,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildTraceStage({
    required int stageNumber,
    required String stageTitle,
    required IconData icon,
    required Widget child,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Node with Line
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$stageNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Stage Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          stageTitle,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 10.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
