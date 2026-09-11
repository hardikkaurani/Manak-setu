import 'package:flutter/material.dart';

import '../models/knowledge_state.dart';
import '../models/standard.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'knowledge_state_badge.dart';

/// Modal bottom sheet presenting a dense, professional side-by-side comparison
/// for 2 to 3 Indian Standards to assist procurement officers in technical evaluation.
class StandardsComparisonSheet extends StatelessWidget {
  final List<Standard> standards;

  const StandardsComparisonSheet({
    super.key,
    required this.standards,
  });

  static void show(BuildContext context, {required List<Standard> standards}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StandardsComparisonSheet(standards: standards),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (standards.isEmpty) {
      return const SizedBox.shrink();
    }

    final colWidth = standards.length == 2 ? 160.0 : 135.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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
                    Icons.compare_arrows,
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
                        'STANDARDS COMPARATIVE ANALYSIS',
                        style: AppTextStyles.pageEyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Comparing ${standards.length} Standards',
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

          // Scrollable Comparative Matrix
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Standard Codes & Badges
                      _buildComparisonRow(
                        label: 'STANDARD',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.code,
                                style: AppTextStyles.code.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              KnowledgeStateBadge(
                                state: s.status == 'CURRENT'
                                    ? KnowledgeState.verified
                                    : KnowledgeState.conflicting,
                                isCompact: true,
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      // Title Row
                      _buildComparisonRow(
                        label: 'TITLE',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return Text(
                            s.title,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          );
                        }).toList(),
                      ),

                      // Division Row
                      _buildComparisonRow(
                        label: 'DIVISION',
                        colWidth: colWidth,
                        cells: standards.map((s) => Text(s.division, style: AppTextStyles.bodySmall)).toList(),
                      ),

                      // Edition & Revision
                      _buildComparisonRow(
                        label: 'EDITION',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return Text(
                            s.edition ?? (s.year != null ? '${s.year}' : 'Active Edition'),
                            style: AppTextStyles.codeBadge.copyWith(
                              color: s.isObsolete ? AppColors.nonCompliantText : AppColors.primary,
                            ),
                          );
                        }).toList(),
                      ),

                      // Lifecycle Status
                      _buildComparisonRow(
                        label: 'STATUS',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return Text(
                            s.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: s.status == 'CURRENT' ? AppColors.verifiedText : AppColors.nonCompliantText,
                            ),
                          );
                        }).toList(),
                      ),

                      // QCO Mandate
                      _buildComparisonRow(
                        label: 'QCO STATUS',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return s.mandatoryQco != null
                              ? Text(
                                  s.mandatoryQco!,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                )
                              : Text('Not governed by QCO', style: AppTextStyles.caption);
                        }).toList(),
                      ),

                      // Scope Summary
                      _buildComparisonRow(
                        label: 'SCOPE',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return Text(
                            s.scope ?? 'Scope details available in BIS catalog.',
                            style: AppTextStyles.caption.copyWith(fontSize: 10.5, height: 1.3),
                          );
                        }).toList(),
                      ),

                      // Raw Materials
                      _buildComparisonRow(
                        label: 'RAW MATERIALS',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          if (s.rawMaterials.isEmpty) return Text('None mandated', style: AppTextStyles.caption);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: s.rawMaterials.map((m) => Text('• $m', style: AppTextStyles.caption.copyWith(fontSize: 10))).toList(),
                          );
                        }).toList(),
                      ),

                      // Testing Protocols
                      _buildComparisonRow(
                        label: 'TEST METHODS',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          if (s.testingMethods.isEmpty) return Text('Standard test regime', style: AppTextStyles.caption);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: s.testingMethods.map((t) => Text('• $t', style: AppTextStyles.caption.copyWith(fontSize: 10))).toList(),
                          );
                        }).toList(),
                      ),

                      // Evidence Citation
                      _buildComparisonRow(
                        label: 'EVIDENCE',
                        colWidth: colWidth,
                        cells: standards.map((s) {
                          return s.evidence != null
                              ? Text(
                                  s.evidence!.citationDisplay,
                                  style: AppTextStyles.codeBadge.copyWith(fontSize: 9.5, color: AppColors.primary),
                                )
                              : Text('Evidence indexed in library', style: AppTextStyles.caption);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required double colWidth,
    required List<Widget> cells,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineSubtle)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Label Column
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cells
          ...cells.map((c) {
            return Container(
              width: colWidth,
              padding: const EdgeInsets.only(right: 12),
              child: c,
            );
          }),
        ],
      ),
    );
  }
}
