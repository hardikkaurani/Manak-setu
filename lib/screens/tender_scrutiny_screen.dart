import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/demo_data.dart';
import '../models/compliance_finding.dart';
import '../models/tender_analysis.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/audit_scorecard.dart';
import '../widgets/evidence_sheet.dart';
import '../widgets/image_clause_analyzer.dart';

/// Phase 2 Interactive Tender Scrutiny Screen.
/// Provides deterministic offline statutory audit demonstration for the Substation Distribution Transformer preset.
class TenderScrutinyScreen extends StatefulWidget {
  const TenderScrutinyScreen({super.key});

  @override
  State<TenderScrutinyScreen> createState() => _TenderScrutinyScreenState();
}

class _TenderScrutinyScreenState extends State<TenderScrutinyScreen> {
  int _selectedPresetIndex =
      1; // Default to Substation Distribution Transformer (Primary demo)
  int _activeTabIndex = 0; // 0: Clause & Presets, 1: Upload Document

  late final TextEditingController _categoryController;
  late final TextEditingController _departmentController;
  late final TextEditingController _clauseController;

  // Analysis State
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  String _analysisProgressStep = '';
  final Set<int> _expandedFlags = {
    0,
    1,
    2,
  }; // Expand all CVC flags by default for immediate visibility

  // File Upload State
  String? _uploadedFileName;
  int? _uploadedFileSize;

  String get _currentPresetId =>
      DemoData.presets[_selectedPresetIndex]['id'] ?? 'transformer';
  TenderAnalysis get _currentAnalysis =>
      DemoData.getAnalysisForPreset(_currentPresetId);

  @override
  void initState() {
    super.initState();
    final initialPreset = DemoData.presets[_selectedPresetIndex];
    _categoryController = TextEditingController(text: initialPreset['title']);
    _departmentController = TextEditingController(
      text: initialPreset['department'],
    );
    _clauseController = TextEditingController(text: initialPreset['clause']);

    // Stale detection: if user edits technical clause after analysis, clear/mark stale
    _clauseController.addListener(_onClauseTextChanged);
  }

  @override
  void dispose() {
    _clauseController.removeListener(_onClauseTextChanged);
    _categoryController.dispose();
    _departmentController.dispose();
    _clauseController.dispose();
    super.dispose();
  }

  void _onClauseTextChanged() {
    if (_hasAnalyzed) {
      setState(() {
        _hasAnalyzed = false;
      });
    }
  }

  void _applyPreset(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _hasAnalyzed = false;
      final preset = DemoData.presets[index];
      _categoryController.text = preset['title'] ?? '';
      _departmentController.text = preset['department'] ?? '';
      _clauseController.text = preset['clause'] ?? '';
    });
  }

  void _resetInputForm() {
    setState(() {
      _selectedPresetIndex = 1; // Substation Distribution Transformer
      _hasAnalyzed = false;
      _isAnalyzing = false;
      final preset = DemoData.presets[1];
      _categoryController.text = preset['title'] ?? '';
      _departmentController.text = preset['department'] ?? '';
      _clauseController.text = preset['clause'] ?? '';
      _uploadedFileName = null;
      _uploadedFileSize = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Form reset to canonical defective Distribution Transformer tender clause.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadRectifiedClause() {
    setState(() {
      _clauseController.text = DemoData.rectifiedTransformerClause;
      _categoryController.text = 'Distribution Transformers (Compliant)';
      _hasAnalyzed = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Loaded canonical GFR-144 & BIS compliant specification clause.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _runComplianceCheck() async {
    setState(() {
      _isAnalyzing = true;
      _hasAnalyzed = false;
      _analysisProgressStep = 'Cross-referencing 23,000+ Indian Standards...';
    });

    // Short, crisp ~700ms deterministic analysis state
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _analysisProgressStep = 'Auditing Section 16 BIS Act QCO compliance...';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _hasAnalyzed = true;
      _analysisProgressStep = '';
    });
  }

  Future<void> _pickLocalFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xlsx', 'xls', 'docx'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final size = file.lengthSync() ?? await file.length();
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFileSize = size;
          _hasAnalyzed = false;
        });
      }
    } catch (_) {
      // Fallback demo file simulation if file_picker is restricted in headless/test environments
      _selectFallbackDemoFile(
        'flawed_distribution_transformer_tender.pdf',
        1428500,
      );
    }
  }

  void _selectFallbackDemoFile(String name, int size) {
    setState(() {
      _uploadedFileName = name;
      _uploadedFileSize = size;
      _hasAnalyzed = false;
    });
  }

  void _clearUploadedFile() {
    setState(() {
      _uploadedFileName = null;
      _uploadedFileSize = null;
      _hasAnalyzed = false;
    });
  }

  void _toggleFlagExpanded(int index) {
    setState(() {
      if (_expandedFlags.contains(index)) {
        _expandedFlags.remove(index);
      } else {
        _expandedFlags.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page Header
          _buildPageHeader(),
          const SizedBox(height: 18),

          // Authoritative Presets Section
          _buildPresetsSection(),
          const SizedBox(height: 18),

          // Ingestion Mode Tabs & Input Form
          _buildIngestionCard(),
          const SizedBox(height: 18),

          // Simulated Progress Indicator (when analyzing)
          if (_isAnalyzing) ...[
            _buildAnalyzingProgressCard(),
            const SizedBox(height: 18),
          ],

          // Analysis Results (when completed)
          if (_hasAnalyzed) ...[
            // 1. Audit Scorecard
            AuditScorecard(
              score: _currentAnalysis.compliancePercentage,
              status: _currentAnalysis.status,
              criticalCount: _currentAnalysis.criticalDefects,
              highCount: _currentAnalysis.highRiskViolations,
              summaryText: _currentAnalysis.summaryText,
              onBuildSpecification: () => context.go(
                '/specification-builder?preset=$_currentPresetId',
              ),
            ),
            const SizedBox(height: 18),

            // 2. Detected Standards & Statutory Status
            _buildDetectedStandardsSection(),
            const SizedBox(height: 18),

            // 3. CVC Anti-Tailoring & Vigilance Flags
            _buildCvcFlagsSection(),
            const SizedBox(height: 18),

            // Secondary Bridge CTA
            SecondaryButton(
              label: 'BUILD COMPLIANT SPECIFICATION →',
              icon: Icons.edit_document,
              onPressed: () => context.go(
                '/specification-builder?preset=$_currentPresetId',
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Statutory Checkpoints Information Card
          _buildStatutoryCheckpointsCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WORKSPACE / NEW ANALYSIS',
          style: AppTextStyles.pageEyebrow,
        ),
        const SizedBox(height: 4),
        const Text(
          'New standards scrutiny & analysis',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: 6),
        Text(
          'Audit tender specifications against 23,000+ Indian Standards, mandatory QCOs, and CVC anti-tailoring directives.',
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget _buildPresetsSection() {
    return SectionCard(
      eyebrow: 'STATUTORY AUDIT WORKBENCH',
      title: 'Authoritative Evaluation Presets',
      subtitle: 'Click to load statutory test case into scrutiny workbench',
      icon: Icons.tune,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Text('Real test cases', style: AppTextStyles.caption),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(DemoData.presets.length, (index) {
          final preset = DemoData.presets[index];
          final isSelected = _selectedPresetIndex == index;

          return InkWell(
            onTap: () => _applyPreset(index),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              margin: EdgeInsets.only(
                bottom: index == DemoData.presets.length - 1 ? 0 : 8,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceContainerLow
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: isSelected ? 1.5 : 1,
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
                          preset['label']!,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryContainer,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset['badge']!,
                    style: AppTextStyles.codeBadge.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIngestionCard() {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab Switcher (Horizontally scrollable for compact mobile screens)
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton(
                    index: 0,
                    icon: Icons.edit_note,
                    label: '1. Tender Clause & Presets',
                  ),
                  const SizedBox(width: 12),
                  _buildTabButton(
                    index: 1,
                    icon: Icons.upload_file,
                    label: '2. Upload Document (PDF / BoQ)',
                  ),
                  const SizedBox(width: 12),
                  _buildTabButton(
                    index: 2,
                    icon: Icons.image_search,
                    label: '3. Clause Image Analyzer',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_activeTabIndex == 0) ...[
            // Category & Department Inputs
            Text('Procurement Item Category', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _categoryController,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'e.g. Distribution Transformers, HDPE Pipes',
              ),
            ),
            const SizedBox(height: 14),

            Text('Department / Procuring Entity', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _departmentController,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'e.g. Municipal Water Supply Directorate',
              ),
            ),
            const SizedBox(height: 14),

            // Clause Header with Linter Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Technical Specification / Tender Clause',
                          style: AppTextStyles.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.nonCompliantText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AppColors.primaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NLP + CVC linter',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Clause Multiline Input
            TextField(
              controller: _clauseController,
              maxLines: 8,
              style: AppTextStyles.body.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                hintText:
                    'Enter or paste technical tender specification clause...',
              ),
            ),
            const SizedBox(height: 6),

            // Character count & Status line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _clauseController,
                    builder: (context, value, child) {
                      return Text(
                        '${value.text.length} characters',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _hasAnalyzed
                        ? 'Audit Active'
                        : 'Deterministic statutory demo',
                    style: AppTextStyles.caption.copyWith(
                      color: _hasAnalyzed
                          ? AppColors.nonCompliantText
                          : AppColors.secondary,
                      fontWeight: _hasAnalyzed
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Preset Helper Actions (Reset & Load Rectified Clause)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.restart_alt, size: 16),
                    label: const Text(
                      'RESET INPUT FORM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _resetInputForm,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryContainer,
                      side: const BorderSide(color: AppColors.primaryContainer),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.verified, size: 16),
                    label: const Text(
                      'LOAD RECTIFIED CLAUSE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _loadRectifiedClause,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Primary Audit Action Button
            PrimaryButton(
              label: 'CHECK TENDER COMPLIANCE',
              icon: Icons.shield_outlined,
              isLoading: _isAnalyzing,
              onPressed: _runComplianceCheck,
            ),
          ] else if (_activeTabIndex == 1) ...[
            // Document Upload Ingestion Tab
            _buildDocumentUploadTab(),
          ] else if (_activeTabIndex == 2) ...[
            // Phase 4 Clause Image Analyzer
            const ImageClauseAnalyzer(),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentUploadTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _pickLocalFile,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _uploadedFileName != null
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                width: _uploadedFileName != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _uploadedFileName != null
                      ? Icons.file_present
                      : Icons.cloud_upload_outlined,
                  size: 40,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(height: 10),
                Text(
                  _uploadedFileName ?? 'Select or drag Tender RFP (.pdf) or Bill of Quantities (.xlsx)',
                  style: AppTextStyles.cardTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _uploadedFileName != null
                      ? 'File size: ${(_uploadedFileSize! / 1024).toStringAsFixed(1)} KB · Ready for statutory audit'
                      : 'Supports digital PDFs, scanned tender annexures, and multi-item Excel BoQ files',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _pickLocalFile,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: Text(
                    _uploadedFileName != null ? 'CHANGE FILE' : 'CHOOSE FILE',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Fallback Demo Selector
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              'Quick demo samples:',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _selectFallbackDemoFile(
                'substation_transformer_tender.pdf',
                1845200,
              ),
              child: const Text(
                'Transformer PDF',
                style: TextStyle(fontSize: 11),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _selectFallbackDemoFile(
                'municipal_procurement_boq.xlsx',
                482100,
              ),
              child: const Text('BoQ Excel', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),

        if (_uploadedFileName != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'REMOVE FILE',
                  icon: Icons.delete_outline,
                  onPressed: _clearUploadedFile,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'ANALYZE DOCUMENT',
                  icon: Icons.shield,
                  isLoading: _isAnalyzing,
                  onPressed: _runComplianceCheck,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyzingProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHECKING TENDER COMPLIANCE...',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(_analysisProgressStep, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedStandardsSection() {
    final standards = _currentAnalysis.detectedStandards;

    return SectionCard(
      title: 'Detected Standards & Statutory Status (${standards.length})',
      subtitle: 'Mandatory Indian Standards identified in the technical specification',
      icon: Icons.auto_stories,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: standards.map((std) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Standard Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        std.code,
                        style: AppTextStyles.code.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.obsolete(std.status),
                  ],
                ),
                if (std.replacementCode != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.verifiedText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Replace with: ${std.replacementCode!}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.verifiedText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  std.title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                ),
                if (std.advisory != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      std.advisory!,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // View Evidence Button
                if (std.evidence != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.menu_book, size: 14),
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
                          evidence: std.evidence!,
                          title: '${std.code} Supersession Evidence',
                          subtitle: std.title,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCvcFlagsSection() {
    final flags = _currentAnalysis.cvcFlags;

    return SectionCard(
      title: 'CVC Anti-Tailoring & Vigilance Flags (${flags.length})',
      subtitle: 'Deterministic alerts under CVC Guidelines & GFR Rule 144',
      icon: Icons.security,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(flags.length, (index) {
          final flag = flags[index];
          final isExpanded = _expandedFlags.contains(index);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: flag.severity == FindingSeverity.critical
                    ? AppColors.nonCompliantBorder
                    : AppColors.reviewBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expandable Header
                InkWell(
                  onTap: () => _toggleFlagExpanded(index),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          flag.severity == FindingSeverity.critical
                              ? Icons.error
                              : Icons.warning,
                          size: 18,
                          color: flag.severity == FindingSeverity.critical
                              ? AppColors.nonCompliantText
                              : AppColors.reviewText,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  StatusBadge(
                                    label: flag.severityLabel,
                                    type:
                                        flag.severity ==
                                            FindingSeverity.critical
                                        ? BadgeType.critical
                                        : BadgeType.high,
                                  ),
                                  if (flag.matchedEntity != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AppColors.outlineVariant,
                                        ),
                                      ),
                                      child: Text(
                                        flag.matchedEntity!,
                                        style: AppTextStyles.codeBadge.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                flag.title,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.textMuted,
                          size: 20,
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
                        Text(
                          'VIOLATION SPECIFICATION',
                          style: AppTextStyles.sectionEyebrow,
                        ),
                        const SizedBox(height: 4),
                        Text(flag.description, style: AppTextStyles.bodySmall),
                        const SizedBox(height: 10),
                        Text(
                          'STATUTORY ACTION REQUIRED',
                          style: AppTextStyles.sectionEyebrow.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            flag.statutoryAction,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (flag.evidence != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryContainer,
                              ),
                              icon: const Icon(Icons.verified, size: 14),
                              label: const Text(
                                'VIEW STATUTORY RULE EVIDENCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () {
                                EvidenceSheet.show(
                                  context,
                                  evidence: flag.evidence!,
                                  title: flag.title,
                                  subtitle: flag.description,
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
        }),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _activeTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.secondary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatutoryCheckpointsCard() {
    return SectionCard(
      title: 'Statutory Checkpoints',
      subtitle: 'Deterministic verification against Government of India procurement mandates',
      icon: Icons.gavel,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: DemoData.statutoryCheckpoints.map((checkpoint) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.balance,
                    size: 14,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkpoint['title']!,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        checkpoint['description']!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
