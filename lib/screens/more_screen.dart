import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

/// More screen presenting officer credentials, statutory procurement mandates,
/// prototype architecture transparency, and export utilities.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.assessment_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Audit Summary Export', style: AppTextStyles.cardTitle),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MANAKSETU STATUTORY AUDIT REPORT\n'
                  'Officer: ${DemoData.officerName} (${DemoData.officerId})\n'
                  'Department: Municipal Water Supply Directorate\n'
                  'Date: 11-Sep-2026\n\n'
                  'SUMMARY FINDINGS:\n'
                  '• Distribution Transformers: 5% Compliant (NON-COMPLIANT)\n'
                  '  - Cited Obsolete IS 1180:1989 (Superseded by IS 1180:2014)\n'
                  '  - Proprietary lock-in: ABB / Siemens bushings\n'
                  '• HDPE Pipes: 8% Compliant (NON-COMPLIANT)\n'
                  '  - Cited Obsolete IS 4984:1995 (Superseded by IS 4984:2016)\n'
                  '  - Brand lock-in: Supreme / Astral make\n'
                  '• TMT Rebars: 12% Compliant (NON-COMPLIANT)\n'
                  '  - Foreign standard ASTM A615 cited without equivalence\n'
                  '  - Brand lock-in: Tata Tiscon / Jindal Panther',
                  style: AppTextStyles.code.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy, size: 14),
              label: const Text('COPY TO CLIPBOARD'),
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(
                    text: 'MANAKSETU STATUTORY AUDIT REPORT\n'
                        'Officer: Priya Rao (DES-8842)\n'
                        'Status: Audited under GFR 144(vii) & Section 16 BIS Act 2016.',
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Audit report copied to clipboard.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Officer Profile Card
          _buildOfficerCard(),
          const SizedBox(height: 16),

          // 2. Statutory Legal Reference Framework
          _buildStatutoryFrameworkCard(),
          const SizedBox(height: 16),

          // 3. Export & Utilities
          _buildExportCard(context),
          const SizedBox(height: 16),

          // 4. Prototype Transparency & SIH 2026 Disclaimer
          _buildPrototypeDisclaimer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOfficerCard() {
    return SectionCard(
      title: 'Procurement Officer Profile',
      subtitle: 'Government of India e-Procurement credentials',
      icon: Icons.badge_outlined,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: AppColors.onPrimary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DemoData.officerName, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${DemoData.officerRole} · ID: ${DemoData.officerId}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Municipal Water Supply Directorate',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge.verified('AUTHORIZED'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Audit Role Authority', style: AppTextStyles.caption),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Technical Scrutiny & Authoring',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryFrameworkCard() {
    return SectionCard(
      title: 'Statutory Reference Framework',
      subtitle: 'Legal procurement checkpoints enforced by ManakSetu',
      icon: Icons.balance_outlined,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildFrameworkItem(
            'General Financial Rules (GFR) 2017 — Rule 144(vii)',
            'Mandates that all technical specifications in government procurement tenders must reference Indian Standards formulated by the Bureau of Indian Standards (BIS) wherever available.',
          ),
          const SizedBox(height: 10),
          _buildFrameworkItem(
            'Section 16 Bureau of Indian Standards Act, 2016',
            'Empowers the Central Government to notify Quality Control Orders (QCOs) prohibiting the manufacture, storage, and procurement of non-ISI marked goods under penal sanctions.',
          ),
          const SizedBox(height: 10),
          _buildFrameworkItem(
            'CVC Anti-Tailoring Directives (OM No. 03-05-01)',
            'Prohibits citing proprietary OEM trade names, brand models, or tailored financial parameters that unduly restrict competitive bidding.',
          ),
        ],
      ),
    );
  }

  Widget _buildFrameworkItem(String title, String desc) {
    return Container(
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
            title,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 12, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(desc, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildExportCard(BuildContext context) {
    return SectionCard(
      title: 'Export & Audit Tools',
      subtitle: 'Local report generation and GeM specification exports',
      icon: Icons.ios_share_outlined,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('GENERATE LOCAL AUDIT REPORT'),
            onPressed: () => _showReportDialog(context),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: AppColors.textSecondary,
            ),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('COPY METHODOLOGY SUMMARY'),
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(
                  text: 'ManakSetu operates on a 3-step statutory architecture: '
                      '1. Extract requirements → 2. Audit against BIS Standards, QCOs, and CVC rules → 3. Synthesize GFR-144 compliant specifications.',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied methodology statement to clipboard.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrototypeDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PROTOTYPE ARCHITECTURE TRANSPARENCY',
                  style: AppTextStyles.pageEyebrow.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This application is a high-fidelity offline mobile demonstration prototype designed for Smart India Hackathon (SIH 2026). All evaluations, standards cross-references, and CVC anti-tailoring audits are evaluated deterministically against authoritative local models. No simulated claims of live external BIS server scraping or legal certainty are implied.',
            style: AppTextStyles.caption.copyWith(
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
