import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/demo_data.dart';
import 'section_card.dart';
import 'status_badge.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'evidence_sheet.dart';

/// Phase 4 Image Clause Analyzer component.
/// Provides real local image selection, previewing, and deterministic offline
/// statutory audit analysis for tender clause images.
class ImageClauseAnalyzer extends StatefulWidget {
  const ImageClauseAnalyzer({super.key});

  @override
  State<ImageClauseAnalyzer> createState() => _ImageClauseAnalyzerState();
}

class _ImageClauseAnalyzerState extends State<ImageClauseAnalyzer> {
  // Selected Image State
  String? _imagePath;
  Uint8List? _imageBytes;
  String? _imageFileName;
  int? _imageFileSize;
  bool _isAssetSample = false;

  // Analysis Simulation State
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  String _analysisProgressStep = '';
  Timer? _analysisTimer;

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  void _clearImage() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _imageFileName = null;
      _imageFileSize = null;
      _isAssetSample = false;
      _hasAnalyzed = false;
      _isAnalyzing = false;
      _analysisProgressStep = '';
    });
  }

  Future<void> _pickImage() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        Uint8List? bytes;
        try {
          bytes = await file.readAsBytes();
        } catch (_) {}
        int size = 0;
        try {
          size = file.lengthSync() ?? await file.length();
        } catch (_) {}
        setState(() {
          _imagePath = file.path;
          _imageBytes = bytes;
          _imageFileName = file.name;
          _imageFileSize = size;
          _isAssetSample = false;
          _hasAnalyzed = false;
          _isAnalyzing = false;
          _analysisProgressStep = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _selectSampleClauseImage() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _isAssetSample = true;
      _imageFileName = 'sample_transformer_clause.jpg';
      _imageFileSize = 485200; // ~485 KB
      _hasAnalyzed = false;
      _isAnalyzing = false;
      _analysisProgressStep = '';
    });
  }

  void _analyzeClause() {
    if (_imageFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.onPrimary, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('Please select a clause image first.')),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAnalyzed = false;
      _analysisProgressStep = 'EXTRACTING CLAUSE TEXT...';
    });

    _analysisTimer?.cancel();
    _analysisTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _analysisProgressStep = 'IDENTIFYING INDIAN STANDARDS...';
      });

      _analysisTimer = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() {
          _analysisProgressStep = 'CHECKING STATUTORY REQUIREMENTS...';
        });

        _analysisTimer = Timer(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          setState(() {
            _isAnalyzing = false;
            _hasAnalyzed = true;
            _analysisProgressStep = '';
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Instructions / Header
        _buildAnalyzerHeader(),
        const SizedBox(height: 14),

        // 2. Image Selection & Preview Zone
        if (_imageFileName == null)
          _buildEmptyUploadZone()
        else
          _buildImagePreviewCard(),

        const SizedBox(height: 14),

        // 3. Action Button (ANALYZE CLAUSE)
        PrimaryButton(
          label: 'ANALYZE CLAUSE',
          icon: Icons.document_scanner_outlined,
          isLoading: _isAnalyzing,
          onPressed: _analyzeClause,
        ),

        // 4. Progress Simulation Banner
        if (_isAnalyzing) ...[
          const SizedBox(height: 14),
          _buildProgressBanner(),
        ],

        // 5. Deterministic Analysis Results
        if (_hasAnalyzed) ...[
          const SizedBox(height: 18),
          _buildExtractedClauseCard(),
          const SizedBox(height: 14),
          _buildDetectedStandardCard(),
          const SizedBox(height: 14),
          _buildComplianceFindingCard(),
          const SizedBox(height: 16),
          // Navigation Bridge to Specification Builder
          SecondaryButton(
            label: 'OPEN SPECIFICATION BUILDER →',
            icon: Icons.edit_document,
            onPressed: () => context.go('/specification-builder'),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyzerHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'CLAUSE IMAGE ANALYZER',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                fontSize: 10.5,
              ),
            ),
            StatusBadge.ready('OFFLINE OCR DEMO'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Upload an image of a tender clause to inspect its standards and compliance requirements.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyUploadZone() {
    return Column(
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  size: 38,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Upload Clause Image',
                  style: AppTextStyles.cardTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a photo or scan of a technical specification (JPG, PNG)',
                  style: AppTextStyles.caption.copyWith(fontSize: 11.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('CHOOSE AN IMAGE'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              'Demo sample:',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.image, size: 14),
              label: const Text(
                'Sample Clause Image',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              onPressed: _selectSampleClauseImage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreviewCard() {
    final sizeKb = _imageFileSize != null
        ? (_imageFileSize! / 1024).toStringAsFixed(1)
        : '0.0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _imageFileName ?? 'clause_image.jpg',
                        style: AppTextStyles.codeBadge.copyWith(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$sizeKb KB',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Actual Image Preview Container (constrained & aspect ratio preserved)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: Colors.black.withValues(alpha: 0.04),
              constraints: const BoxConstraints(maxHeight: 220),
              width: double.infinity,
              child: _buildActualImageWidget(),
            ),
          ),
          const SizedBox(height: 10),

          // Action controls: Change / Clear
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text(
                    'CHANGE IMAGE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _pickImage,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.nonCompliantText,
                    side: const BorderSide(color: AppColors.nonCompliantBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text(
                    'CLEAR IMAGE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _clearImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActualImageWidget() {
    if (_isAssetSample) {
      return Image.asset(
        'assets/images/sample_clause.jpg',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImagePlaceholder();
        },
      );
    }

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImagePlaceholder();
        },
      );
    }

    if (_imagePath != null) {
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImagePlaceholder();
        },
      );
    }

    return _buildFallbackImagePlaceholder();
  }

  Widget _buildFallbackImagePlaceholder() {
    return Container(
      height: 120,
      color: AppColors.surfaceContainerLow,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 6),
          Text('Preview unavailable', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildProgressBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _analysisProgressStep,
              style: AppTextStyles.codeBadge.copyWith(
                color: AppColors.secondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedClauseCard() {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.text_snippet_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'EXTRACTED CLAUSE',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
              StatusBadge.ready('OCR DEMO RESULT'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Extracted Technical Clause (Deterministic Demo Result)',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              DemoData.imageClauseExtractedText,
              style: AppTextStyles.code.copyWith(
                fontSize: 11.5,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Extracted text mapped from technical clause image for statutory audit.',
            style: AppTextStyles.caption.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedStandardCard() {
    final evidence = DemoData.imageClauseEvidence;

    return SectionCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.nonCompliantBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppColors.nonCompliantText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DETECTED STANDARD',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.nonCompliantText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
              StatusBadge.obsolete('OBSOLETE / SUPERSEDED'),
            ],
          ),
          const SizedBox(height: 8),

          // Supersession replacement visual pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  DemoData.imageClauseDetectedStandard,
                  style: AppTextStyles.codeBadge.copyWith(
                    color: AppColors.nonCompliantText,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 11,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: AppColors.verifiedText,
                ),
                Text(
                  DemoData.imageClauseReplacementStandard,
                  style: AppTextStyles.codeBadge.copyWith(
                    color: AppColors.verifiedText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Outdoor Type Three-Phase Distribution Transformers Up to and Including 2500 kVA, 33 kV – Specification',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mandatory Quality Control Order: Distribution Transformers (Quality Control) Order, 2014 (S.O. 1621(E)).',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Evidence Button (Reuses existing Phase 2 EvidenceSheet)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.menu_book, size: 14),
              label: const Text(
                'VIEW BIS EVIDENCE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                EvidenceSheet.show(
                  context,
                  evidence: evidence,
                  title: DemoData.imageClauseDetectedStandard,
                  subtitle:
                      'Superseded by ${DemoData.imageClauseReplacementStandard}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceFindingCard() {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.nonCompliantBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPLIANCE FINDING',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.nonCompliantText,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DemoData.imageClauseFindingTitle,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 13,
              color: AppColors.nonCompliantText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DemoData.imageClauseFindingDescription,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.5,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
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
                  'STATUTORY ACTION REQUIRED:',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DemoData.imageClauseStatutoryAction,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
