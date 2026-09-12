import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/knowledge_state.dart';
import '../models/product_image_sample.dart';
import '../models/demo_image_analysis.dart';
import '../data/demo_data.dart';
import 'section_card.dart';
import 'knowledge_state_badge.dart';
import 'status_badge.dart';
import 'primary_button.dart';

/// Product Image Input & Analysis Card for Tender Scrutiny.
/// Allows procurement officers to upload or photograph physical equipment,
/// review deterministic extracted technical parameters, and run statutory scrutiny.
class ProductImageInputCard extends StatefulWidget {
  final void Function(ProductImageSample sample) onAnalyzeProduct;
  final VoidCallback onManualInputRequested;
  final void Function(bool isErrorMode)? onModeToggled;

  const ProductImageInputCard({
    super.key,
    required this.onAnalyzeProduct,
    required this.onManualInputRequested,
    this.onModeToggled,
  });

  @override
  State<ProductImageInputCard> createState() => _ProductImageInputCardState();
}

class _ProductImageInputCardState extends State<ProductImageInputCard> {
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  Uint8List? _imageBytes;
  String? _imageFileName;
  int? _imageFileSize;
  bool _isAssetSample = false;

  // Selected or detected demo product sample
  late ProductImageSample _selectedSample;

  // Phase 5B Demo Error-State Override
  bool _forceImageMismatch = false;
  DemoImageAnalysis? _mismatchResult;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _selectedSample = DemoData.productImageSamples.first; // Default: Transformer
  }

  void _toggleErrorOverride() {
    setState(() {
      _forceImageMismatch = !_forceImageMismatch;
      _mismatchResult = null; // Clear stale result immediately
      _isAnalyzing = false;
    });
    widget.onModeToggled?.call(_forceImageMismatch);
  }

  String _getGoverningStandard(ProductImageSample sample) {
    switch (sample.id) {
      case 'pipe':
        return 'IS 4984:2016';
      case 'steel':
        return 'IS 1786:2008';
      case 'transformer':
      default:
        return 'IS 1180:2014';
    }
  }

  Future<void> _handleAnalyze() async {
    if (_forceImageMismatch) {
      setState(() {
        _isAnalyzing = true;
        _mismatchResult = null;
      });
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      final std = _getGoverningStandard(_selectedSample);
      setState(() {
        _isAnalyzing = false;
        _mismatchResult = DemoImageAnalysis.evaluate(
          _imageFileName ?? '${_selectedSample.id}_photo.jpg',
          tenderStandard: std,
          contextText: _selectedSample.title,
          forceMismatch: true,
        );
      });
    } else {
      widget.onAnalyzeProduct(_selectedSample);
    }
  }

  void _clearImage() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _imageFileName = null;
      _imageFileSize = null;
      _isAssetSample = false;
      _mismatchResult = null;
      _isAnalyzing = false;
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
          _mismatchResult = null;
          _isAnalyzing = false;
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

  void _selectDemoSample(ProductImageSample sample) {
    setState(() {
      _selectedSample = sample;
      _imageFileName = '${sample.id}_photo.jpg';
      _imageFileSize = 142800; // ~140 KB
      _isAssetSample = true;
      _imageBytes = null;
      _imagePath = sample.sampleAssetPath;
      _mismatchResult = null;
      _isAnalyzing = false;
    });
  }

  void _showImageSourcePicker() {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PRODUCT PHOTO SOURCE', style: AppTextStyles.sectionEyebrow),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Text('OFFLINE DEMO', style: AppTextStyles.caption),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Photograph physical equipment or nameplate', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Upload existing equipment inspection image', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('OR SELECT CANONICAL DEMO SAMPLE', style: AppTextStyles.caption),
              ),
              ...DemoData.productImageSamples.map((sample) {
                return ListTile(
                  dense: true,
                  leading: Icon(
                    sample.isSupported ? Icons.check_circle_outline : Icons.help_outline,
                    color: sample.isSupported ? AppColors.verifiedText : AppColors.secondary,
                    size: 20,
                  ),
                  title: Text(sample.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    sample.isSupported ? sample.category : 'Triggers unidentifiable fallback',
                    style: const TextStyle(fontSize: 10),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _selectDemoSample(sample);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null || _imageBytes != null || _isAssetSample;

    if (!hasImage) {
      return _buildInitialCard();
    }

    return _buildPreviewAndExtractionCard();
  }

  Widget _buildInitialCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Icon(
                  Icons.camera_enhance_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        const Text('ADD PRODUCT IMAGE', style: AppTextStyles.label),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: const Text('OFFLINE DEMO', style: AppTextStyles.caption),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Analyze a product photo instead of typing specifications.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('add_product_image_button'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
            icon: const Icon(Icons.add_a_photo_outlined, size: 16),
            label: const Text(
              'TAKE PHOTO OR CHOOSE IMAGE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onPressed: _showImageSourcePicker,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Quick demo products:', style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ...DemoData.productImageSamples.take(3).map((sample) {
                final label = sample.category.split(' ').first;
                return InkWell(
                  key: Key('quick_demo_${sample.id}'),
                  onTap: () => _selectDemoSample(sample),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      sample.category.split(' ').first,
                      label,
                      style: const TextStyle(fontSize: 10, color: AppColors.primary),
                    ),
                  ),
                );
              }),
              _buildDemoErrorSwitch(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewAndExtractionCard() {
    return SectionCard(
      eyebrow: 'PRODUCT IMAGE ANALYSIS',
      title: 'Physical Equipment Specification',
      subtitle: 'Deterministic parameter extraction from product photograph',
      icon: Icons.image_search,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Text('OFFLINE PRODUCT IMAGE DEMO', style: AppTextStyles.caption),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Image Thumbnail & Metadata Header
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surface,
                    child: _buildThumbnail(),
                  ),
                ),
                const SizedBox(width: 12),
                // Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _imageFileName ?? 'product_capture.jpg',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _imageFileSize != null
                            ? '${(_imageFileSize! / 1024).toStringAsFixed(1)} KB · Photo ready'
                            : 'Bundled demo product image',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.verifiedBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.verifiedBorder),
                            ),
                            child: const Text(
                              'OFFLINE DEMO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.verifiedText,
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
          const SizedBox(height: 10),

          // 2. Action Controls (Replace / Remove)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('product_image_replace_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text(
                    'REPLACE PHOTO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _showImageSourcePicker,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('product_image_remove_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.nonCompliantText,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text(
                    'REMOVE PHOTO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _clearImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const SizedBox(height: 10),

          // Quick Demo Products strip with Error Override Switch
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Quick demo products:', style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ...DemoData.productImageSamples.take(3).map((sample) {
                final label = sample.category.split(' ').first;
                final isSelected = _selectedSample.id == sample.id;
                return InkWell(
                  key: Key('quick_demo_${sample.id}'),
                  onTap: () => _selectDemoSample(sample),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isSelected ? AppColors.onPrimary : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }),
              _buildDemoErrorSwitch(),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Demo Product Category Switcher
          Text('MATCHED PRODUCT CATEGORY (DEMO SELECTION)', style: AppTextStyles.sectionEyebrow),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DemoData.productImageSamples.map((sample) {
                final isSelected = _selectedSample.id == sample.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    key: Key('product_sample_chip_${sample.id}'),
                    selected: isSelected,
                    label: Text(
                      sample.isSupported ? sample.category : 'Unknown / Other',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                      ),
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainerLow,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSample = sample;
                          _mismatchResult = null;
                          _isAnalyzing = false;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Extracted Summary or Fallback Card
          if (_selectedSample.isSupported) ...[
          // 4. Extracted Summary or Fallback Card or Mismatch Card
          if (_mismatchResult != null) ...[
            _buildMismatchResultCard(_mismatchResult!),
            const SizedBox(height: 14),
            PrimaryButton(
              key: const Key('analyze_product_button'),
              label: 'ANALYZE APPLICABLE STANDARDS',
              icon: Icons.shield_outlined,
              isLoading: _isAnalyzing,
              onPressed: _handleAnalyze,
            ),
          ] else if (_selectedSample.isSupported) ...[
            _buildSupportedParametersView(),
            const SizedBox(height: 14),
            PrimaryButton(
              key: const Key('analyze_product_button'),
              label: 'ANALYZE APPLICABLE STANDARDS',
              icon: Icons.shield_outlined,
              onPressed: () => widget.onAnalyzeProduct(_selectedSample),
              isLoading: _isAnalyzing,
              onPressed: _handleAnalyze,
            ),
          ] else ...[
            _buildUnsupportedFallbackView(),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, color: AppColors.textMuted),
      );
    }
    if (_imagePath != null && !_isAssetSample) {
      if (!kIsWeb) {
        return Image.file(
          File(_imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, color: AppColors.textMuted),
        );
      }
    }
    // Asset sample fallback
    return Image.asset(
      'assets/branding/manaksetu_app_icon.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image, color: AppColors.textMuted),
    );
  }

  Widget _buildSupportedParametersView() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text('EXTRACTED PRODUCT SPECIFICATION', style: AppTextStyles.sectionEyebrow),
              KnowledgeStateBadge(
                state: _selectedSample.knowledgeState,
                isCompact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Product Identification
          _buildParamRow('Category', _selectedSample.category),
          _buildParamRow('Attributes', _selectedSample.detectedAttributes),

          const Divider(height: 16),

          // Technical Parameters
          Text('TECHNICAL PARAMETERS', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _buildParamRow('Material', _selectedSample.material),
          _buildParamRow('Size / Rating', _selectedSample.sizeRating),
          _buildParamRow('Application', _selectedSample.application),
          _buildParamRow('Performance', _selectedSample.performance),
        ],
      ),
    );
  }

  Widget _buildUnsupportedFallbackView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Amber-100
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFDE68A)), // Amber-200
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product identification unavailable — manual specification input required.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The captured image does not match any indexed canonical Indian Standard category or lacks recognizable statutory markings. Manual specification entry is mandatory.',
                      style: AppTextStyles.caption.copyWith(color: const Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              KnowledgeStateBadge(
                state: KnowledgeState.outOfCoverage,
                isCompact: true,
              ),
              TextButton.icon(
                key: const Key('switch_to_manual_button'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF92400E),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text(
                  'CONTINUE WITH MANUAL TEXT INPUT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                onPressed: widget.onManualInputRequested,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoErrorSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _forceImageMismatch
            ? AppColors.nonCompliantBg
            : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _forceImageMismatch
              ? AppColors.nonCompliantBorder
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _forceImageMismatch ? Icons.error_outline : Icons.bug_report_outlined,
            size: 11,
            color: _forceImageMismatch
                ? AppColors.nonCompliantText
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: _toggleErrorOverride,
            child: Text(
              'Force Mismatch',
              style: TextStyle(
                fontSize: 10,
                fontWeight: _forceImageMismatch ? FontWeight.w700 : FontWeight.w500,
                color: _forceImageMismatch
                    ? AppColors.nonCompliantText
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            height: 16,
            width: 28,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                key: const Key('demo_error_override_switch'),
                value: _forceImageMismatch,
                activeThumbColor: AppColors.nonCompliantText,
                activeTrackColor: AppColors.nonCompliantBg,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  if (val != _forceImageMismatch) {
                    _toggleErrorOverride();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMismatchResultCard(DemoImageAnalysis result) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.nonCompliantBorder,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
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
                      color: const Color(0xFFFCD34D), // Amber-300
                    ),
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
                  key: const Key('change_image_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                  onPressed: _showImageSourcePicker,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CHANGE IMAGE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  key: const Key('clear_image_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.nonCompliantText,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                  onPressed: _clearImage,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CLEAR',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
