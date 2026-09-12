import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/demo_data.dart';
import '../models/demo_image_analysis.dart';
import '../services/workspace_controller.dart';
import 'section_card.dart';
import 'status_badge.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'evidence_sheet.dart';

/// Phase 5B Multi-Modal Visual Gap Matrix & Physical Scrutiny Component.
/// Provides finite deterministic visual scrutiny evaluation of equipment/product photos
/// against statutory procurement specifications, bridging into the progressive builder.
class ImageClauseAnalyzer extends StatefulWidget {
  final String? currentPresetId;

  const ImageClauseAnalyzer({super.key, this.currentPresetId});

  @override
  State<ImageClauseAnalyzer> createState() => _ImageClauseAnalyzerState();
}

class _ImageClauseAnalyzerState extends State<ImageClauseAnalyzer> {
  final ImagePicker _picker = ImagePicker();

  // Selected Image State
  String? _imagePath;
  Uint8List? _imageBytes;
  String? _imageFileName;
  int? _imageFileSize;
  bool _isAssetSample = false;

  // Intended Use / Context Controller
  late final TextEditingController _contextController;

  // Analysis State
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  String _analysisProgressStep = '';
  Timer? _analysisTimer;
  DemoImageAnalysis? _analysisResult;

  @override
  void initState() {
    super.initState();
    _contextController = TextEditingController(
      text: 'Municipal water supply pipeline',
    );
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _contextController.dispose();
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
      _analysisResult = null;
    });
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (xFile != null) {
        final bytes = await xFile.readAsBytes();
        final size = await xFile.length();
        setState(() {
          _imagePath = xFile.path;
          _imageBytes = bytes;
          _imageFileName = xFile.name;
          _imageFileSize = size;
          _isAssetSample = false;
          _hasAnalyzed = false;
          _isAnalyzing = false;
          _analysisProgressStep = '';
          _analysisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image acquisition error: $e'),
            backgroundColor: AppColors.nonCompliantText,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSourcePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELECT PRODUCT IMAGE SOURCE',
                style: AppTextStyles.sectionEyebrow,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Capture clear photo of equipment nameplate or physical asset',
                  style: TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Choose from Gallery / Device Storage',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Select existing JPG or PNG product inspection image',
                  style: TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDemoSample(String fileName, int approxBytes) {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _isAssetSample = true;
      _imageFileName = fileName;
      _imageFileSize = approxBytes;
      _hasAnalyzed = false;
      _isAnalyzing = false;
      _analysisProgressStep = '';
      _analysisResult = null;
    });
  }

  void _selectSampleClauseImage() {
    _selectDemoSample('sample_transformer_clause.jpg', 485200);
  }

  String _resolveGoverningStandard() {
    final pid = widget.currentPresetId ?? 'pipe';
    if (pid == 'transformer') {
      return 'IS 1180 (Part 1):2014';
    } else if (pid == 'steel') {
      return 'IS 1786:2008';
    }
    return 'IS 4984:2016';
  }

  void _analyzeClause() {
    if (_imageFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.onPrimary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text('Please select a clause image first.'),
              ),
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
      _analysisResult = null;
      _analysisProgressStep = 'ANALYZING VISUAL ARTIFACT...';
    });

    _analysisTimer?.cancel();
    _analysisTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _analysisProgressStep = 'CHECKING PROCUREMENT CATEGORY...';
      });

      _analysisTimer = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() {
          _analysisProgressStep = 'CROSS-REFERENCING SPECIFICATION MATRIX...';
        });

        _analysisTimer = Timer(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          final result = DemoImageAnalysis.evaluate(
            _imageFileName,
            tenderStandard: _resolveGoverningStandard(),
            contextText: _contextController.text.trim(),
          );
          setState(() {
            _isAnalyzing = false;
            _hasAnalyzed = true;
            _analysisResult = result;
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
        // 1. Header with Eyebrow & Badges
        _buildAnalyzerHeader(),
        const SizedBox(height: 14),

        // 2. Optional Context / Intended Use Input Field
        _buildContextInputField(),
        const SizedBox(height: 14),

        // 3. Image Selection & Preview Zone
        if (_imageFileName == null)
          _buildEmptyUploadZone()
        else
          _buildImagePreviewCard(),

        const SizedBox(height: 10),
        _buildDemoSamplesStrip(),

        const SizedBox(height: 14),

        // 4. Primary Scrutiny Action Button
        PrimaryButton(
          key: const Key('analyze_visual_button'),
          label: 'ANALYZE CLAUSE',
          icon: Icons.document_scanner_outlined,
          isLoading: _isAnalyzing,
          onPressed: _analyzeClause,
        ),

        // 5. Simulated Scrutiny Progress
        if (_isAnalyzing) ...[
          const SizedBox(height: 14),
          _buildProgressBanner(),
        ],

        // 6. Visual Scrutiny Results
        if (_hasAnalyzed) ...[
          const SizedBox(height: 18),
          if (_imageFileName == 'sample_transformer_clause.jpg') ...[
            // Phase 4 Clause Extraction Compatibility
            _buildExtractedClauseCard(),
            const SizedBox(height: 14),
            _buildDetectedStandardCard(),
            const SizedBox(height: 14),
            _buildComplianceFindingCard(),
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'OPEN SPECIFICATION BUILDER →',
              icon: Icons.edit_document,
              onPressed: () => context.go('/specification-builder'),
            ),
          ] else if (_analysisResult != null) ...[
            if (_analysisResult!.isCompliant)
              _buildCompliantResultCard(_analysisResult!)
            else
              _buildMismatchResultCard(_analysisResult!),
          ],
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
            StatusBadge.ready('DETERMINISTIC VISUAL SCRUTINY'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'MULTI-MODAL VISUAL GAP MATRIX & PHYSICAL SCRUTINY',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          "Cross-referencing physical equipment photo / nameplate against buyer's draft tender specification.",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildContextInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INTENDED USE / CONTEXT',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('intended_use_context_field'),
          controller: _contextController,
          style: AppTextStyles.body.copyWith(fontSize: 12.5),
          decoration: const InputDecoration(
            hintText: 'e.g. Municipal water supply pipeline',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyUploadZone() {
    return Column(
      children: [
        InkWell(
          onTap: _showSourcePickerSheet,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                  'Photograph physical equipment, nameplate, or choose image file (JPG, PNG)',
                  style: AppTextStyles.caption.copyWith(fontSize: 11.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () =>
                            _pickImageFromSource(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text(
                          'TAKE PHOTO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () =>
                            _pickImageFromSource(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text(
                          'CHOOSE AN IMAGE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoSamplesStrip() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Text(
          'Demo samples:',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMuted,
            fontSize: 10.5,
          ),
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
        ActionChip(
          key: const Key('demo_chip_compliant'),
          avatar: const Icon(
            Icons.check_circle,
            size: 14,
            color: AppColors.verifiedText,
          ),
          label: const Text(
            'Compliant (IMG-2-260912-WA0005.jpg)',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.verifiedBg,
          side: const BorderSide(color: AppColors.verifiedBorder),
          onPressed: () =>
              _selectDemoSample('IMG-2-260912-WA0005.jpg', 324500),
        ),
        ActionChip(
          key: const Key('demo_chip_mismatch_transformer'),
          avatar: const Icon(
            Icons.warning_amber,
            size: 14,
            color: AppColors.nonCompliantText,
          ),
          label: const Text(
            'Mismatch (transformer.jpg)',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.nonCompliantBg,
          side: const BorderSide(color: AppColors.nonCompliantBorder),
          onPressed: () => _selectDemoSample('transformer.jpg', 485200),
        ),
        ActionChip(
          key: const Key('demo_chip_mismatch_random'),
          avatar: const Icon(
            Icons.error_outline,
            size: 14,
            color: AppColors.secondary,
          ),
          label: const Text(
            'Mismatch (random_equipment.jpg)',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.secondaryLight,
          side: const BorderSide(color: AppColors.secondary),
          onPressed: () =>
              _selectDemoSample('random_equipment.jpg', 198400),
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
                        _imageFileName ?? 'equipment_photo.jpg',
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
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.infinity,
              child: _buildActualImageWidget(),
            ),
          ),
          const SizedBox(height: 10),

          // Action controls: Change / Clear
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('change_image_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _showSourcePickerSheet,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 14),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'CHANGE IMAGE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  key: const Key('clear_image_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.nonCompliantText,
                    side: const BorderSide(color: AppColors.nonCompliantBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _clearImage,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 14),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'CLEAR IMAGE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActualImageWidget() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImagePlaceholder();
        },
      );
    }

    if (_imagePath != null && !kIsWeb) {
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImagePlaceholder();
        },
      );
    }

    if (_isAssetSample) {
      if (_imageFileName == 'sample_transformer_clause.jpg') {
        return Image.asset(
          'assets/images/sample_clause.jpg',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImagePlaceholder();
          },
        );
      }
      return Image.asset(
        'assets/branding/manaksetu_app_icon.png',
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

  /// Compliant Result Card for `IMG-2-260912-WA0005.jpg`.
  Widget _buildCompliantResultCard(DemoImageAnalysis result) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.verifiedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.verifiedBorder, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Eyebrow & Badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'PHYSICAL SCRUTINY RESULT',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.verifiedText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontSize: 10.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.verifiedBorder),
                ),
                child: Text(
                  'COMPLIANT',
                  style: AppTextStyles.codeBadge.copyWith(
                    color: AppColors.verifiedText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Title & Confirmation Badge
          Text(
            result.displayTitle.toUpperCase(),
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.verifiedText,
              ),
              Text(
                'PRODUCT MATCH CONFIRMED',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: AppColors.verifiedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Parameter Metadata Table
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.verifiedBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow('Governing Standard', result.governingStandard),
                const Divider(height: 12),
                _buildInfoRow(
                  'Procurement Category',
                  result.procurementCategory,
                ),
                const Divider(height: 12),
                _buildInfoRow('Status', result.status),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            result.resultDescription,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // CTA to Specification Builder
          PrimaryButton(
            key: const Key('open_spec_builder_button'),
            label: 'OPEN SPECIFICATION BUILDER →',
            icon: Icons.edit_document,
            onPressed: () {
              WorkspaceController().setActivePreset(result.builderPresetId);
              context.go(
                '/specification-builder?preset=${result.builderPresetId}',
              );
            },
          ),
        ],
      ),
    );
  }

  /// Mismatch Result Card for every other image.
  Widget _buildMismatchResultCard(DemoImageAnalysis result) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.nonCompliantBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Eyebrow Header
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'MULTI-MODAL VISUAL GAP MATRIX & PHYSICAL SCRUTINY',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
              ),
              StatusBadge.nonCompliant('SCRUTINY REJECTED'),
            ],
          ),
          const SizedBox(height: 12),

          // Prominent Red Alert Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.nonCompliantBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.nonCompliantBorder,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.nonCompliantText,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRODUCT MISMATCH ALERT:',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.nonCompliantText,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'IMAGE INVALID FOR SPECIFIED REQUIREMENT',
                            style: AppTextStyles.cardTitle.copyWith(
                              color: AppColors.nonCompliantText,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Governing Standard
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.nonCompliantBorder),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        'Governing Standard: ',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        result.governingStandard,
                        style: AppTextStyles.codeBadge.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Product Mismatch Detected section
                Text(
                  'PRODUCT MISMATCH DETECTED:',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.nonCompliantText,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.resultDescription,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Nested Category Conflict Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), // Amber-50
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFCD34D),
                    ), // Amber-300
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Color(0xFFB45309),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'CATEGORY CONFLICT:',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                                fontSize: 10.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.categoryConflict ??
                            'Equipment photo/nameplate does not correspond to the required procurement category. Scrutiny rejected.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF92400E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Recovery Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                  onPressed: _showSourcePickerSheet,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 14),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'CHANGE IMAGE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.nonCompliantText,
                    side: const BorderSide(color: AppColors.nonCompliantBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                  onPressed: _clearImage,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 14),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'CLEAR',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
