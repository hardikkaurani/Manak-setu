import 'package:flutter/material.dart';

import '../models/boq_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'section_card.dart';
import 'status_badge.dart';

/// Institutional Bill of Quantities (BoQ) Scrutiny Card.
/// Displays item-by-item audit findings against BIS Standards, QCOs, and CVC rules.
class BoQAuditCard extends StatefulWidget {
  final BoQAuditResult result;
  final VoidCallback? onBuildSpecification;

  const BoQAuditCard({
    super.key,
    required this.result,
    this.onBuildSpecification,
  });

  @override
  State<BoQAuditCard> createState() => _BoQAuditCardState();
}

class _BoQAuditCardState extends State<BoQAuditCard> {
  final Set<int> _expandedItemIndices = {0, 1}; // Expand defective items by default
  String _activeItemFilter = 'ALL';

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedItemIndices.contains(index)) {
        _expandedItemIndices.remove(index);
      } else {
        _expandedItemIndices.add(index);
      }
    });
  }

  Widget _buildFilterChip(String label, String value, {Color? color}) {
    final isSelected = _activeItemFilter == value;
    return InkWell(
      key: Key('boq_filter_$value'),
      onTap: () {
        setState(() {
          _activeItemFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : (color ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;

    final filteredItems = _activeItemFilter == 'ALL'
        ? res.items
        : res.items.where((it) {
            if (_activeItemFilter == 'FAIL') return it.status == BoQStatus.fail;
            if (_activeItemFilter == 'WARN') return it.status == BoQStatus.warn;
            if (_activeItemFilter == 'PASS') return it.status == BoQStatus.pass;
            return true;
          }).toList();

    return SectionCard(
      title: 'BoQ Statutory Audit: ${res.fileName}',
      subtitle: '${res.totalItems} line items audited against BIS & CVC Mandates',
      icon: Icons.table_chart_outlined,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Executive Metric Summary Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                // Score Gauge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.nonCompliantBorder, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${res.statutoryComplianceScore}%',
                        style: AppTextStyles.brandTitle.copyWith(
                          color: AppColors.nonCompliantText,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'COMPLIANCE',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Stat Counters
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Line-Item Audit Results',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildCountBadge('FAIL (${res.failCount})', AppColors.nonCompliantText, AppColors.nonCompliantBg, AppColors.nonCompliantBorder),
                          _buildCountBadge('WARN (${res.warnCount})', AppColors.secondary, AppColors.reviewBg, AppColors.reviewBorder),
                          _buildCountBadge('PASS (${res.passCount})', AppColors.verifiedText, AppColors.verifiedBg, AppColors.verifiedBorder),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Explanatory Notice
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.reviewBg.withValues(alpha: 0.5),
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
                    '2 of 5 BoQ items contain statutory defects (superseded standard citations & proprietary brand lock-in). Immediate rectification required under GFR 144(vii).',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Line Items Filter & Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('AUDITED BOQ LINE ITEMS (${filteredItems.length})', style: AppTextStyles.sectionEyebrow),
              Text('Filter: $_activeItemFilter', style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL (${res.items.length})', 'ALL'),
                const SizedBox(width: 6),
                _buildFilterChip('FAIL (${res.failCount})', 'FAIL', color: AppColors.nonCompliantText),
                const SizedBox(width: 6),
                _buildFilterChip('WARN (${res.warnCount})', 'WARN', color: AppColors.secondary),
                const SizedBox(width: 6),
                _buildFilterChip('PASS (${res.passCount})', 'PASS', color: AppColors.verifiedText),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final isExpanded = _expandedItemIndices.contains(index);

              Color cardBorder;
              if (item.status == BoQStatus.fail) {
                cardBorder = AppColors.nonCompliantBorder;
              } else if (item.status == BoQStatus.warn) {
                cardBorder = AppColors.reviewBorder;
              } else {
                cardBorder = AppColors.verifiedBorder;
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Header Bar (tappable)
                    InkWell(
                      onTap: () => _toggleExpand(index),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status icon
                            Icon(
                              item.status == BoQStatus.fail
                                  ? Icons.cancel_outlined
                                  : item.status == BoQStatus.warn
                                      ? Icons.warning_amber_outlined
                                      : Icons.check_circle_outline,
                              size: 18,
                              color: item.status == BoQStatus.fail
                                  ? AppColors.nonCompliantText
                                  : item.status == BoQStatus.warn
                                      ? AppColors.secondary
                                      : AppColors.verifiedText,
                            ),
                            const SizedBox(width: 8),

                            // Item Number & Title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        item.itemNumber,
                                        style: AppTextStyles.codeBadge.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        '· Qty: ${item.quantity} ${item.unit}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status Tag & Expand Icon
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusBadge(
                                  label: item.statusLabel,
                                  type: item.status == BoQStatus.fail
                                      ? BadgeType.critical
                                      : item.status == BoQStatus.warn
                                          ? BadgeType.high
                                          : BadgeType.verified,
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expanded Details
                    if (isExpanded) ...[
                      const Divider(height: 1, color: AppColors.outlineVariant),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cited Standard vs Recommended
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('CITED IN BOQ', style: AppTextStyles.sectionEyebrow),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.citedStandard,
                                        style: AppTextStyles.code.copyWith(
                                          color: item.status == BoQStatus.fail
                                              ? AppColors.nonCompliantText
                                              : AppColors.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('STATUTORY TARGET', style: AppTextStyles.sectionEyebrow),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.recommendedStandard,
                                        style: AppTextStyles.code.copyWith(
                                          color: AppColors.verifiedText,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Defect & Corrective Action
                            Text('AUDIT FINDING', style: AppTextStyles.sectionEyebrow),
                            const SizedBox(height: 3),
                            Text(item.statutoryDefect, style: AppTextStyles.bodySmall),
                            const SizedBox(height: 8),

                            Text('STATUTORY REMEDY', style: AppTextStyles.sectionEyebrow),
                            const SizedBox(height: 3),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.recommendedAction,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String label, Color fg, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: AppTextStyles.codeBadge.copyWith(color: fg, fontSize: 10),
      ),
    );
  }
}
