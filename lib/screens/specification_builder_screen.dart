import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/demo_data.dart';
import '../models/specification.dart';
import '../models/specification_build_step.dart';
import '../models/specification_parameter.dart';
import '../services/workspace_controller.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/secondary_button.dart';
import '../widgets/evidence_sheet.dart';
import '../widgets/diff_viewer.dart';
import '../widgets/knowledge_graph_view.dart';

/// Phase 5A Progressive Specification Builder Screen.
/// Supports all 3 presets (HDPE Pipe, Transformer, TMT Steel).
/// Allows judges to progressively apply statutory corrections or jump to 100% compliance.
class SpecificationBuilderScreen extends StatefulWidget {
  final String? presetId;

  const SpecificationBuilderScreen({super.key, this.presetId});

  @override
  State<SpecificationBuilderScreen> createState() =>
      _SpecificationBuilderScreenState();
}

class _SpecificationBuilderScreenState
    extends State<SpecificationBuilderScreen> {
  int _activeTabIndex = 0; // 0: Workbench, 1: Diff, 2: Knowledge Graph
  late String _presetId;
  late List<SpecificationBuildStep> _steps;
  final Set<String> _appliedStepIds = {};
  late List<SpecificationSection> _sections;
  late Set<String> _expandedSectionIds;

  @override
  void initState() {
    super.initState();
    _presetId = DemoData.normalizePresetId(widget.presetId);
    _steps = DemoData.getBuildStepsForPreset(_presetId);
    _sections = DemoData.getSectionsWithAppliedSteps(_presetId, _appliedStepIds);
    _expandedSectionIds = {'sec-1', 'sec-2'};
  }

  @override
  void didUpdateWidget(covariant SpecificationBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetId != widget.presetId) {
      setState(() {
        _presetId = DemoData.normalizePresetId(widget.presetId);
        _steps = DemoData.getBuildStepsForPreset(_presetId);
        _appliedStepIds.clear();
        _sections = DemoData.getSectionsWithAppliedSteps(
          _presetId,
          _appliedStepIds,
        );
        _expandedSectionIds = {'sec-1', 'sec-2'};
      });
    }
  }

  int get _initialScore => DemoData.getInitialScoreForPreset(_presetId);

  int get _currentScore {
    if (_appliedStepIds.isEmpty) return _initialScore;
    if (_appliedStepIds.length == _steps.length) return 100;
    // Derive score from the latest applied step in sequential order
    for (int i = _steps.length - 1; i >= 0; i--) {
      if (_appliedStepIds.contains(_steps[i].id)) {
        return _steps[i].scoreAfter;
      }
    }
    return _initialScore;
  }

  bool get _isFullyCompliant => _appliedStepIds.length == _steps.length;

  String get _currentStatus {
    if (_isFullyCompliant) return 'COMPLIANT';
    if (_appliedStepIds.isEmpty) return 'NON_COMPLIANT';
    return 'PARTIALLY_COMPLIANT';
  }

  bool _canApplyStep(int index) {
    if (index < 0 || index >= _steps.length) return false;
    final step = _steps[index];
    if (_appliedStepIds.contains(step.id)) return false;
    if (index == 0) return true;
    return _appliedStepIds.contains(_steps[index - 1].id);
  }

  void _applyStep(int index) {
    if (!_canApplyStep(index)) return;
    final step = _steps[index];

    setState(() {
      _appliedStepIds.add(step.id);
      _expandedSectionIds.add(step.targetSectionId);
      _sections = DemoData.getSectionsWithAppliedSteps(
        _presetId,
        _appliedStepIds,
      );
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Applied Step ${step.stepNumber}: ${step.title}. Score updated to ${step.scoreAfter}%.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyAllSteps() {
    setState(() {
      _appliedStepIds.addAll(_steps.map((s) => s.id));
      _sections = DemoData.getSectionsWithAppliedSteps(
        _presetId,
        _appliedStepIds,
      );
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.verified, color: AppColors.verifiedText, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'All statutory corrections applied: 100% COMPLIANT specification synthesized.',
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetBuilder() {
    setState(() {
      _appliedStepIds.clear();
      _sections = DemoData.getSectionsWithAppliedSteps(
        _presetId,
        _appliedStepIds,
      );
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Specification reset to initial defective procurement tender state.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleSection(String id) {
    setState(() {
      if (_expandedSectionIds.contains(id)) {
        _expandedSectionIds.remove(id);
      } else {
        _expandedSectionIds.add(id);
      }
    });
  }

  void _recheckCompliance() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isFullyCompliant ? Icons.check_circle : Icons.info,
              color: _isFullyCompliant
                  ? AppColors.verifiedText
                  : AppColors.reviewText,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isFullyCompliant
                    ? 'Statutory re-check complete: 100% compliant with active BIS standards & QCO orders.'
                    : 'Current compliance is at $_currentScore%. ${_steps.length - _appliedStepIds.length} corrections remain pending.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copySpecification() {
    final buffer = StringBuffer();
    final stdInfo = DemoData.getGoverningStandardInfo(_presetId);
    buffer.writeln('========================================');
    buffer.writeln('MANAKSETU STATUTORY TENDER SPECIFICATION');
    buffer.writeln('Governing Standard: ${stdInfo['title'] ?? ''} (${stdInfo['badge'] ?? ''})');
    buffer.writeln('Compliance Rating: $_currentScore% ($_currentStatus)');
    buffer.writeln('Statutory Framework: BIS Act 2016 (Sec 16) · GFR Rule 144(vii)');
    buffer.writeln('========================================\n');

    buffer.writeln('--- TECHNICAL PARAMETERS ---');
    final params = WorkspaceController().getParametersForPreset(_presetId);
    for (final p in params) {
      buffer.writeln('${p.name}: ${p.currentValue} [${p.status.toUpperCase()}]');
    }
    buffer.writeln('\n--- STATUTORY SPECIFICATION CLAUSES ---');
    for (final sec in _sections) {
      buffer.writeln('\n[Clause ${sec.sectionNumber}] ${sec.title}');
      buffer.writeln(sec.content);
      if (sec.isPurchaserDefined) {
        buffer.writeln('>> NOTE: Purchaser-defined requirement (No BIS evidence attached)');
      }
    }

    final customClauses = WorkspaceController().customPurchaserClauses;
    if (customClauses.isNotEmpty) {
      buffer.writeln('\n--- ADDITIONAL PURCHASER-DEFINED CLAUSES ---');
      for (final c in customClauses) {
        buffer.writeln('\n[Clause ${c.sectionNumber}] ${c.title} (PURCHASER-DEFINED)');
        buffer.writeln(c.content);
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.content_copy, color: AppColors.onPrimary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Copied bid-ready tender specification (${buffer.length} characters) to clipboard for GeM portal.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _downloadCertificatePdf() {
    final buffer = StringBuffer();
    final stdInfo = DemoData.getGoverningStandardInfo(_presetId);
    buffer.writeln('=====================================================');
    buffer.writeln('GOVERNMENT OF INDIA · STATUTORY VIGILANCE AUDIT REPORT');
    buffer.writeln('MANAKSETU PROCUREMENT SCRUTINY CERTIFICATE (DEMO STATE)');
    buffer.writeln('=====================================================');
    buffer.writeln('Audit ID: NIT-DES-8842');
    buffer.writeln('Officer: ${DemoData.officerName} (${DemoData.officerId})');
    buffer.writeln('Standard: ${stdInfo['title']} (${stdInfo['badge']})');
    buffer.writeln('Compliance Score: $_currentScore% ($_currentStatus)');
    buffer.writeln('Verification: GFR Rule 144(vii) & BIS Act 2016 Mandatory QCO Order');
    buffer.writeln('Status: Ready for Departmental Tender Publication');
    buffer.writeln('=====================================================');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.verified, color: AppColors.onPrimary, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Vigilance & GFR-144 Audit Certificate prepared (PDF).',
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stdInfo = DemoData.getGoverningStandardInfo(_presetId);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Page Header Area
          _buildPageHeader(stdInfo),
          const SizedBox(height: 16),

          // 2. Dominant Dynamic Compliance Scorecard
          _buildComplianceScorecard(stdInfo),
          const SizedBox(height: 14),

          // 3. Completion State Banner (when 100% compliant)
          if (_isFullyCompliant) ...[
            _buildCompletionStateCard(),
            const SizedBox(height: 14),
          ],

          // 4. Statutory Checklist Banner
          _buildStatutoryChecklist(),
          const SizedBox(height: 16),

          // 5. Shortcut & Reset Action Controls Bar
          _buildActionControls(),
          const SizedBox(height: 18),

          // 6. Workbench View Mode Selector Tabs
          _buildTabSelector(),
          const SizedBox(height: 16),

          // 7. Tab Content
          if (_activeTabIndex == 0) _buildClauseWorkbenchTab(),
          if (_activeTabIndex == 1) _buildRedlineDiffTab(),
          if (_activeTabIndex == 2) _buildKnowledgeGraphTab(),

          const SizedBox(height: 20),

          // 8. Return to Tender Scrutiny Navigation
          SecondaryButton(
            label: '← RETURN TO TENDER SCRUTINY',
            icon: Icons.arrow_back,
            onPressed: () {
              context.go('/tender-scrutiny');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPageHeader(Map<String, String> stdInfo) {
    final analysis = DemoData.getAnalysisForPreset(_presetId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'AUTHORING / SPECIFICATION BUILDER',
              style: AppTextStyles.pageEyebrow,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Text(
                stdInfo['badge'] ?? '',
                style: AppTextStyles.codeBadge.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Bid-ready specification workbench',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: 4),
        Text(
          '${analysis.title} — Progressive rectification with mandatory QCO declarations, testing schedules, and CVC anti-tailoring safeguards.',
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget _buildComplianceScorecard(Map<String, String> stdInfo) {
    final isCompliant = _isFullyCompliant;
    final score = _currentScore;

    final borderColor = isCompliant
        ? AppColors.verifiedBorder
        : (_appliedStepIds.isEmpty
            ? AppColors.nonCompliantBorder
            : AppColors.reviewBorder);

    final bgColor = isCompliant
        ? AppColors.verifiedBg
        : (_appliedStepIds.isEmpty
            ? AppColors.nonCompliantBg
            : AppColors.reviewBg);

    final textColor = isCompliant
        ? AppColors.verifiedText
        : (_appliedStepIds.isEmpty
            ? AppColors.nonCompliantText
            : AppColors.reviewText);

    return SectionCard(
      padding: const EdgeInsets.all(16),
      borderColor: borderColor,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Big Dynamic Score & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Text(
                  '$score%',
                  style: AppTextStyles.brandTitle.copyWith(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'STATUTORY STATUS:',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isCompliant)
                          StatusBadge.verified(_currentStatus)
                        else if (_appliedStepIds.isEmpty)
                          StatusBadge.nonCompliant(_currentStatus)
                        else
                          StatusBadge.review(_currentStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompliant
                          ? '0 Critical Defects • GFR-144 & BIS Ready'
                          : '${_steps.length - _appliedStepIds.length} Corrections Pending • Rectification Required',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      isCompliant
                          ? 'All parameters conform to mandatory Quality Control Orders and CVC anti-tailoring directives.'
                          : 'Progressively apply statutory corrections below or tap View 100% Compliant Specification.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 10),

          // Governing Standard Info
          Text(
            'GOVERNING NATIONAL STANDARD',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stdInfo['code'] ?? '',
            style: AppTextStyles.code.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            stdInfo['title'] ?? '',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Supersession Badges from build steps
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _steps.map((step) {
              final isApplied = _appliedStepIds.contains(step.id);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isApplied
                      ? AppColors.verifiedBg.withValues(alpha: 0.5)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isApplied
                        ? AppColors.verifiedBorder
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isApplied ? Icons.check : Icons.sync_alt,
                      size: 11,
                      color: isApplied
                          ? AppColors.verifiedText
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Step ${step.stepNumber}: ${step.id}',
                      style: AppTextStyles.codeBadge.copyWith(
                        color: isApplied
                            ? AppColors.verifiedText
                            : AppColors.textSecondary,
                        fontWeight:
                            isApplied ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStateCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.verifiedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.verifiedBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified,
            color: AppColors.verifiedText,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% SPECIFICATION READY FOR PROCUREMENT',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.verifiedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '✓ All ${_steps.length} statutory corrections applied in-place\n'
                  '✓ Fully compliant with Section 16 BIS Act and GFR Rule 144(vii)\n'
                  '✓ Redline Diff & Normative Knowledge Graph available below',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryChecklist() {
    final items = DemoData.getChecklistForPreset(_presetId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isFullyCompliant
            ? AppColors.verifiedBg.withValues(alpha: 0.4)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFullyCompliant
              ? AppColors.verifiedBorder
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isFullyCompliant
                ? 'STATUTORY COMPLIANCE CHECKPOINTS (ALL VERIFIED)'
                : 'STATUTORY COMPLIANCE CHECKPOINTS (${_appliedStepIds.length}/${_steps.length} ADDRESSED)',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: _isFullyCompliant
                  ? AppColors.verifiedText
                  : AppColors.textPrimary,
              letterSpacing: 0.5,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isItemVerified =
                _isFullyCompliant || (_appliedStepIds.length > idx);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isItemVerified
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 14,
                    color: isItemVerified
                        ? AppColors.verifiedText
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: isItemVerified
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isItemVerified
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionControls() {
    return Column(
      children: [
        // Shortcut to 100% Compliance (Bright Green Button)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFullyCompliant
                ? AppColors.surfaceContainerLow
                : const Color(0xFF1B5E20), // Institutional dark forest green
            foregroundColor: _isFullyCompliant
                ? AppColors.verifiedText
                : Colors.white,
            side: const BorderSide(color: AppColors.verifiedBorder),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: Icon(
            _isFullyCompliant ? Icons.check_circle : Icons.verified,
            size: 18,
          ),
          label: Text(
            _isFullyCompliant
                ? '✓ SPECIFICATION FULLY COMPLIANT (100%)'
                : 'VIEW 100% COMPLIANT SPECIFICATION',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          onPressed: _isFullyCompliant ? null : _applyAllSteps,
        ),
        const SizedBox(height: 8),

        // Helper Actions Row (Reset Specification & Recheck)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.restart_alt, size: 15),
                label: const Text(
                  'RESET SPECIFICATION',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _resetBuilder,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.sync, size: 15),
                label: const Text(
                  'RE-CHECK COMPLIANCE SCORE',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _recheckCompliance,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Copy for GeM & Download PDF Actions
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'COPY FOR GeM',
                icon: Icons.content_copy,
                onPressed: _copySpecification,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SecondaryButton(
                label: 'DOWNLOAD PDF',
                icon: Icons.picture_as_pdf,
                onPressed: _downloadCertificatePdf,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildTabItem(0, 'Clause Workbench', Icons.edit_note),
          _buildTabItem(1, 'Redline Diff', Icons.difference),
          _buildTabItem(2, 'Knowledge Graph', Icons.hub),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _activeTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 0: Clause Workbench
  Widget _buildClauseWorkbenchTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Progressive Corrections Workbench
        _buildProgressiveCorrectionsSection(),
        const SizedBox(height: 18),

        // 2. Interactive Parameter Simulation & Conflict Detection
        _buildEditableParametersSection(),
        const SizedBox(height: 18),

        // 3. Clause-by-Clause Workbench
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'CLAUSE-BY-CLAUSE WORKBENCH',
                style: AppTextStyles.pageEyebrow.copyWith(
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_sections.length} statutory sections',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._sections.map((sec) => _buildExpandableSectionCard(sec)),
        const SizedBox(height: 18),

        // 4. Purchaser-Defined Requirements (Explicit Separation from BIS)
        _buildPurchaserClausesSection(),
      ],
    );
  }

  Widget _buildEditableParametersSection() {
    final controller = WorkspaceController();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final params = controller.getParametersForPreset(_presetId);
        return SectionCard(
          eyebrow: 'STATUTORY PARAMETER SIMULATION',
          title: 'Technical Parameters (${params.length})',
          subtitle: 'Simulate tender amendments. Live BIS rules detect conflicts.',
          icon: Icons.tune,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: params.map((param) {
              final isConflict = param.status == 'conflict';
              final isVerified = param.status == 'verified';

              Color badgeBg = AppColors.surfaceContainerLow;
              Color badgeText = AppColors.verifiedText;
              if (isConflict) {
                badgeText = AppColors.nonCompliantText;
              } else if (!isVerified) {
                badgeText = AppColors.reviewText;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isConflict ? AppColors.nonCompliantBorder : AppColors.outlineVariant,
                    width: isConflict ? 1.5 : 1,
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
                            param.name,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: badgeText.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            param.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: badgeText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Value: ',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                              ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    param.currentValue,
                                    style: AppTextStyles.codeBadge.copyWith(
                                      color: isConflict ? AppColors.nonCompliantText : AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(60, 28),
                          ),
                          icon: const Icon(Icons.edit, size: 12),
                          label: const Text('EDIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          onPressed: () => _showEditParameterDialog(param),
                        ),
                      ],
                    ),
                    if (isConflict && param.conflictMessage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.nonCompliantSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.nonCompliantBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, size: 14, color: AppColors.nonCompliantText),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                param.conflictMessage!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.nonCompliantText,
                                  fontWeight: FontWeight.w600,
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
            }).toList(),
          ),
        );
      },
    );
  }

  void _showEditParameterDialog(SpecificationParameter param) {
    final textEditController = TextEditingController(text: param.currentValue);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Edit Parameter: ${param.name}', style: AppTextStyles.cardTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter technical value. Live BIS rule checks will evaluate compliance with ${DemoData.getGoverningStandardInfo(_presetId)['title'] ?? 'Indian Standards'}.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textEditController,
                decoration: const InputDecoration(
                  labelText: 'Parameter Value',
                  hintText: 'e.g. PE100, PE63, Level 2, Level 1',
                ),
              ),
              const SizedBox(height: 12),
              Text('Quick Test Values:', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ActionChip(
                    label: Text(param.allowedValues.isNotEmpty ? param.allowedValues.first : 'Compliant Value', style: const TextStyle(fontSize: 10)),
                    onPressed: () {
                      textEditController.text = param.allowedValues.isNotEmpty ? param.allowedValues.first : 'Compliant';
                    },
                  ),
                  if (param.id == 'material')
                    ActionChip(
                      label: const Text('PE63 (Obsolete Conflict)', style: TextStyle(fontSize: 10, color: AppColors.nonCompliantText)),
                      onPressed: () => textEditController.text = 'PE63',
                    )
                  else if (param.id == 'energy_level')
                    ActionChip(
                      label: const Text('Level 1 (BEE Mandate Conflict)', style: TextStyle(fontSize: 10, color: AppColors.nonCompliantText)),
                      onPressed: () => textEditController.text = 'Level 1',
                    )
                  else if (param.id == 'steel_grade')
                    ActionChip(
                      label: const Text('Fe 415 (Obsolete Conflict)', style: TextStyle(fontSize: 10, color: AppColors.nonCompliantText)),
                      onPressed: () => textEditController.text = 'Fe 415',
                    )
                  else if (param.id == 'cooling')
                    ActionChip(
                      label: const Text('OFWF (Conflict)', style: TextStyle(fontSize: 10, color: AppColors.nonCompliantText)),
                      onPressed: () => textEditController.text = 'OFWF',
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = textEditController.text.trim();
                if (newValue.isNotEmpty) {
                  WorkspaceController().updateParameterValue(_presetId, param.id, newValue);
                }
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('UPDATE PARAMETER'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPurchaserClausesSection() {
    final controller = WorkspaceController();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final customClauses = controller.customPurchaserClauses;
        return SectionCard(
          eyebrow: 'STATUTORY SEPARATION: PURCHASER CONDITIONS',
          title: 'Purchaser-Defined Requirements (${customClauses.length})',
          subtitle: 'Specific procurement conditions distinct from BIS mandates (no BIS evidence attached).',
          icon: Icons.assignment_turned_in,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.reviewBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.reviewBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.reviewText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Statutory Rule: Purchaser-defined delivery, warranty, and inspection clauses must be kept separate from BIS standard clauses to prevent anti-competitive tailoring.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.reviewText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (customClauses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  child: Text(
                    'No custom purchaser requirements added yet. Use the button below to add departmental delivery, warranty, or inspection criteria.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...customClauses.map((clause) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.reviewBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PURCHASER-DEFINED',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.reviewText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
                              onPressed: () => controller.removePurchaserClause(clause.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(clause.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(clause.content, style: AppTextStyles.bodySmall),
                        const SizedBox(height: 6),
                        Text(
                          'Note: Not mandated by BIS standards.',
                          style: AppTextStyles.caption.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  side: const BorderSide(color: AppColors.primaryContainer),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  '+ ADD PURCHASER REQUIREMENT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                onPressed: _showAddPurchaserClauseDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPurchaserClauseDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Add Purchaser Requirement', style: AppTextStyles.cardTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchaser-defined clauses will be explicitly labeled as "PURCHASER-DEFINED (No BIS Evidence Attached)" to preserve audit integrity under CVC vigilance standards.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Clause Title',
                    hintText: 'e.g. Warranty & Comprehensive AMC Schedule',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Clause Requirement Text',
                    hintText: 'e.g. Supplier shall provide 36 months comprehensive warranty with 48-hour on-site replacement guarantee.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  WorkspaceController().addPurchaserClause(
                    title: title,
                    content: content,
                  );
                }
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('ADD CLAUSE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressiveCorrectionsSection() {
    return SectionCard(
      eyebrow: 'STATUTORY CORRECTIONS WORKBENCH',
      title:
          'Progressive Compliance Corrections (${_appliedStepIds.length}/${_steps.length} Applied)',
      subtitle:
          'Apply corrections sequentially or use the green button above to apply all',
      icon: Icons.checklist_rtl,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          final isApplied = _appliedStepIds.contains(step.id);
          final canApply = _canApplyStep(index);

          return Container(
            margin: EdgeInsets.only(
              bottom: index == _steps.length - 1 ? 0 : 12,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isApplied
                  ? AppColors.verifiedBg.withValues(alpha: 0.35)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isApplied
                    ? AppColors.verifiedBorder
                    : (canApply
                        ? AppColors.primary
                        : AppColors.outlineVariant),
                width: canApply ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step Pill & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isApplied
                            ? AppColors.verifiedBg
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isApplied
                              ? AppColors.verifiedBorder
                              : AppColors.outlineVariant,
                        ),
                      ),
                      child: Text(
                        'STEP ${step.stepNumber}',
                        style: AppTextStyles.codeBadge.copyWith(
                          color: isApplied
                              ? AppColors.verifiedText
                              : AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.title,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.problem,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),

                // Defective snippet (Before)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.nonCompliantBg.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.nonCompliantBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEFECTIVE NIT CLAUSE:',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.nonCompliantText,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.defectiveSnippet,
                        style: AppTextStyles.code.copyWith(
                          fontSize: 11,
                          color: AppColors.nonCompliantText,
                          decoration:
                              isApplied ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Replacement snippet (After)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.verifiedBg.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.verifiedBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMPLIANT RECTIFICATION:',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.verifiedText,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.replacementSnippet,
                        style: AppTextStyles.code.copyWith(
                          fontSize: 11,
                          color: AppColors.verifiedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Action Button
                if (isApplied) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.verifiedText,
                      side: const BorderSide(color: AppColors.verifiedBorder),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(
                      '✓ ADDED TO SPECIFICATION (${step.scoreAfter}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: null, // disabled
                  ),
                ] else if (canApply) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.add_task, size: 16),
                    label: Text(
                      'ADD TO SPEC (${step.scoreBefore}% ➔ ${step.scoreAfter}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => _applyStep(index),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.lock_outline, size: 14),
                    label: Text(
                      'STEP PENDING (Complete Step ${step.stepNumber - 1} first)',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: null,
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExpandableSectionCard(SpecificationSection section) {
    final isExpanded = _expandedSectionIds.contains(section.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tappable Header
          InkWell(
            onTap: () => _toggleSection(section.id),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      section.sectionNumber,
                      style: AppTextStyles.codeBadge.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                        ),
                        if (!isExpanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            section.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (section.status == 'VERIFIED')
                    StatusBadge.verified(section.status)
                  else
                    StatusBadge.review(section.status),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content Body
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPECIFICATION CLAUSE CONTENT:',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      section.content,
                      style: AppTextStyles.code.copyWith(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (section.recommendation != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 15,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'REGULATORY ADVISORY:',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                    fontSize: 9.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  section.recommendation!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (section.evidence != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.menu_book, size: 13),
                        label: const Text(
                          'VIEW BIS EVIDENCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          EvidenceSheet.show(
                            context,
                            evidence: section.evidence!,
                            title:
                                'Section ${section.sectionNumber} Statutory Evidence',
                            subtitle: section.title,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TAB 1: Redline Diff
  Widget _buildRedlineDiffTab() {
    return DiffViewer(
      originalText: DemoData.getDiffOriginalForPreset(_presetId),
      recommendedText: DemoData.getDiffRectifiedForPreset(_presetId),
      itemTitle: DemoData.getDiffItemTitleForPreset(_presetId),
      statutoryAction: DemoData.getDiffStatutoryActionForPreset(_presetId),
    );
  }

  // TAB 2: Knowledge Graph
  Widget _buildKnowledgeGraphTab() {
    return KnowledgeGraphView(
      nodes: DemoData.getGraphNodesForPreset(_presetId),
    );
  }
}
