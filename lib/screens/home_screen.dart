import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/demo_data.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import '../services/workspace_controller.dart';

/// Home Command Center for procurement officers.
/// Shows active analyses, recent audit history, quick-action launchers, and statutory vigilance alerts.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = WorkspaceController();
    final recentItems = workspace.recentAnalyses;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Officer Context Banner
          _buildOfficerBanner(),
          const SizedBox(height: 16),

          // 2. Active Analysis Hero Banner
          _buildActiveAnalysisHero(context),
          const SizedBox(height: 16),

          // 3. Quick Action Grid
          _buildQuickActionGrid(context),
          const SizedBox(height: 16),

          // 4. Statutory Vigilance Alert Feed
          _buildStatutoryAlertsFeed(context),
          const SizedBox(height: 16),

          // 5. Recent Tenders & Audits
          _buildRecentAuditsSection(context, recentItems),
          const SizedBox(height: 16),

          // 6. Standards Intelligence Shortcut Card
          _buildStandardsIntelligenceEntry(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOfficerBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.account_circle,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME, ${DemoData.officerName.toUpperCase()}',
                  style: AppTextStyles.pageEyebrow,
                ),
                const SizedBox(height: 2),
                Text(
                  '${DemoData.officerRole} (${DemoData.officerId})',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                ),
                Text(
                  'Municipal Water Supply Directorate',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.verifiedBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.verifiedBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 12, color: AppColors.verifiedText),
                const SizedBox(width: 4),
                Text(
                  'GFR-144 AUDITOR',
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
    );
  }

  Widget _buildActiveAnalysisHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ACTIVE AUDIT IN PROGRESS',
                    style: AppTextStyles.codeBadge.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.nonCompliant('5% COMPLIANT'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Distribution Transformers 500 kVA (NIT-DES-8842)',
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.onPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Audited tender contains 2 critical defects and 3 high-risk violations. Cites obsolete IS 1180:1989 and ABB/Siemens vendor lock-in.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text(
                    'RESUME AUDIT WORKBENCH',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  onPressed: () => context.go('/tender-scrutiny'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return SectionCard(
      title: 'Scrutiny & Ingestion Actions',
      subtitle: 'Upload tender schedules, clauses, or choose statutory scenarios',
      icon: Icons.bolt,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.edit_note,
                  title: 'Analyze Spec',
                  subtitle: 'Direct clause scrutiny',
                  color: AppColors.primary,
                  onTap: () => context.go('/tender-scrutiny'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Upload PDF',
                  subtitle: 'Tender RFP (.pdf)',
                  color: AppColors.primaryContainer,
                  onTap: () => context.go('/tender-scrutiny'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.table_chart_outlined,
                  title: 'Audit BoQ Excel',
                  subtitle: 'Multi-item schedule',
                  color: AppColors.secondary,
                  onTap: () => context.go('/tender-scrutiny'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.image_search_outlined,
                  title: 'Scan Clause',
                  subtitle: 'Image OCR analyzer',
                  color: AppColors.verifiedText,
                  onTap: () => context.go('/tender-scrutiny'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatutoryAlertsFeed(BuildContext context) {
    return SectionCard(
      title: 'Vigilance & Legal Review Flags',
      subtitle: 'Mandatory checkpoints requiring officer sign-off before publication',
      icon: Icons.gavel,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildAlertItem(
            severity: 'CRITICAL',
            title: 'Proprietary OEM Brand Lock-in',
            entity: 'ABB / Siemens Bushings',
            action: 'Strip trade makes under CVC OM No. 03-05-01; replace with generic IS 2099 requirements.',
            isCritical: true,
            onTap: () => context.go('/tender-scrutiny'),
          ),
          const SizedBox(height: 8),
          _buildAlertItem(
            severity: 'HIGH',
            title: 'Obsolete BIS Standard Cited',
            entity: 'IS 1180:1989',
            action: 'Superseded by IS 1180 (Part 1):2014. Restricts bidding and violates GFR 144(vii).',
            isCritical: false,
            onTap: () => context.go('/tender-scrutiny'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String severity,
    required String title,
    required String entity,
    required String action,
    required bool isCritical,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isCritical
                ? AppColors.nonCompliantBorder
                : AppColors.reviewBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      StatusBadge(
                        label: severity,
                        type: isCritical ? BadgeType.critical : BadgeType.high,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          entity,
                          style: AppTextStyles.codeBadge.copyWith(
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 3),
            Text(
              action,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAuditsSection(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    return SectionCard(
      title: 'Recent Tender Audits',
      subtitle: 'Deterministic statutory evaluation history',
      icon: Icons.history,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: items.map((item) {
          final isFail = (item['score'] as int) < 30;

          return InkWell(
            onTap: () {
              WorkspaceController().setActivePreset(item['presetId']);
              context.go('/tender-scrutiny');
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isFail
                          ? AppColors.nonCompliantBg
                          : AppColors.reviewBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isFail
                            ? AppColors.nonCompliantBorder
                            : AppColors.reviewBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${item['score']}%',
                        style: AppTextStyles.codeBadge.copyWith(
                          color: isFail
                              ? AppColors.nonCompliantText
                              : AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item['id']} · ${item['date']}',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  StatusBadge(
                    label: item['reviewState'] == 'Flagged for Legal Review'
                        ? 'Flagged'
                        : (item['reviewState'] ?? 'Pending'),
                    type: item['reviewState'] == 'Audit Complete'
                        ? BadgeType.verified
                        : (item['reviewState'] == 'Flagged for Legal Review'
                            ? BadgeType.critical
                            : BadgeType.reviewRequired),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStandardsIntelligenceEntry(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppColors.secondaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STANDARDS & QCO EXPLORER',
                  style: AppTextStyles.pageEyebrow.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Search 23,000+ Indian Standards',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                ),
                Text(
                  'Inspect mandatory DPIIT Quality Control Orders and relationship ontologies.',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
            onPressed: () => context.go('/standards'),
          ),
        ],
      ),
    );
  }
}
