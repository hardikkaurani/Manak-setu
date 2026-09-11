import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../services/workspace_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/status_badge.dart';

/// Workspace screen showing saved procurement tenders, audit reports, and human review decisions.
class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceController();
    final allAnalyses = workspace.recentAnalyses;

    final filtered = allAnalyses.where((item) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'FLAGGED' && item['reviewState'].toString().contains('Flagged')) {
        return true;
      }
      if (_selectedFilter == 'COMPLETED' && item['reviewState'] == 'Audit Complete') {
        return true;
      }
      if (_selectedFilter == 'IN PROGRESS' && item['reviewState'] == 'Pending Review') {
        return true;
      }
      return false;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner
          _buildWorkspaceHeader(allAnalyses.length),
          const SizedBox(height: 16),

          // 2. Filter Bar
          _buildFilterBar(),
          const SizedBox(height: 16),

          // 3. Saved Analyses List
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildAnalysisCard(context, item);
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWorkspaceHeader(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WORKSPACE / SAVED SCRUTINY', style: AppTextStyles.pageEyebrow),
        const SizedBox(height: 4),
        const Text('Saved Procurement Tenders', style: AppTextStyles.pageTitle),
        const SizedBox(height: 4),
        Text(
          '$count statutory procurement audits and specification drafts saved locally.',
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['ALL', 'IN PROGRESS', 'FLAGGED', 'COMPLETED'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerLow,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              ),
              onSelected: (_) => setState(() => _selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, Map<String, dynamic> item) {
    final score = item['score'] as int;
    final isFail = score < 30;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Info Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item['id'],
                        style: AppTextStyles.codeBadge.copyWith(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: (item['reviewState'] ?? 'Pending') ==
                              'Flagged for Legal Review'
                          ? 'Flagged'
                          : (item['reviewState'] ?? 'Pending'),
                      type: item['reviewState'] == 'Audit Complete'
                          ? BadgeType.verified
                          : item['reviewState'].toString().contains('Flagged')
                              ? BadgeType.critical
                              : BadgeType.reviewRequired,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'],
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  item['department'],
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),

                // Compliance Meter Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFail ? AppColors.nonCompliantBg : AppColors.reviewBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isFail ? AppColors.nonCompliantBorder : AppColors.reviewBorder,
                          ),
                        ),
                        child: Text(
                          '$score%',
                          style: AppTextStyles.codeBadge.copyWith(
                            color: isFail ? AppColors.nonCompliantText : AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['status'],
                              style: AppTextStyles.codeBadge.copyWith(
                                fontSize: 10,
                                color: isFail ? AppColors.nonCompliantText : AppColors.secondary,
                              ),
                            ),
                            Text(
                              '${item['criticalDefects']} Critical Defects · ${item['highRiskViolations']} High-Risk Violations',
                              style: AppTextStyles.caption.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Bottom Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('COPY ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item['id']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied tender ID ${item['id']} to clipboard.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.troubleshoot, size: 14),
                    label: const Text('OPEN AUDIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      WorkspaceController().setActivePreset(item['presetId']);
                      context.go('/tender-scrutiny');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.folder_open, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text('No tenders match "$_selectedFilter"', style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text('Select "ALL" to inspect all saved audits.', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
