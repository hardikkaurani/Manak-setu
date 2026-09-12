/// Phase 5B Deterministic Demo Image Analysis Data Model.
/// Provides finite offline multi-modal visual scrutiny evaluation based solely on normalized filename.
class DemoImageAnalysis {
  final String filename;
  final String displayTitle;
  final String contextText;
  final bool isCompliant;
  final String status;
  final String governingStandard;
  final String procurementCategory;
  final String resultTitle;
  final String resultDescription;
  final String? categoryConflict;
  final String? mismatchReason;
  final String builderPresetId;

  const DemoImageAnalysis({
    required this.filename,
    required this.displayTitle,
    required this.contextText,
    required this.isCompliant,
    required this.status,
    required this.governingStandard,
    required this.procurementCategory,
    required this.resultTitle,
    required this.resultDescription,
    this.categoryConflict,
    this.mismatchReason,
    required this.builderPresetId,
  });

  /// Canonical Compliant Demo Scenario (Water Supply HDPE Pipeline).
  static const DemoImageAnalysis compliantWater = DemoImageAnalysis(
    filename: 'IMG-2-260912-WA0005.jpg',
    displayTitle: 'HDPE Water Supply Pipe',
    contextText: 'Municipal water supply pipeline',
    isCompliant: true,
    status: 'PRODUCT MATCH CONFIRMED',
    governingStandard: 'IS 4984:2016',
    procurementCategory: 'Water Supply / HDPE Pipeline',
    resultTitle: 'PRODUCT MATCH / COMPLIANT',
    resultDescription:
        'The uploaded equipment/product image is consistent with the selected procurement requirement.',
    builderPresetId: 'pipe',
  );

  /// Normalized Basename Extractor & Sanitizer.
  /// Extracts basename, trims whitespace, and converts to lowercase.
  static String normalizeFilename(String pathOrName) {
    if (pathOrName.isEmpty) return '';
    final basename = pathOrName.split('/').last.split('\\').last.trim();
    return basename.toLowerCase();
  }

  /// Evaluates whether the given filename qualifies as the compliant demo scenario.
  /// The ONLY compliant filename is: `IMG-2-260912-WA0005.jpg` (case-insensitive).
  static bool isCompliantImage(String? fileName) {
    if (fileName == null) return false;
    final normalized = normalizeFilename(fileName);
    return normalized == 'img-2-260912-wa0005.jpg';
  }

  /// Evaluates an image filename deterministically.
  /// Returns [compliantWater] when normalized filename matches `IMG-2-260912-WA0005.jpg`.
  /// Returns a mismatch analysis for any other filename.
  static DemoImageAnalysis evaluate(
    String? fileName, {
    String? tenderStandard,
    String? contextText,
    bool forceMismatch = false,
  }) {
    final rawName = fileName?.trim() ?? 'unknown_image.jpg';
    final isMatch = isCompliantImage(rawName);
    final isMatch = !forceMismatch && isCompliantImage(rawName);

    if (isMatch) {
      return DemoImageAnalysis(
        filename: rawName,
        displayTitle: compliantWater.displayTitle,
        contextText: contextText?.isNotEmpty == true
            ? contextText!
            : compliantWater.contextText,
        isCompliant: true,
        status: compliantWater.status,
        governingStandard: compliantWater.governingStandard,
        procurementCategory: compliantWater.procurementCategory,
        resultTitle: compliantWater.resultTitle,
        resultDescription: compliantWater.resultDescription,
        builderPresetId: compliantWater.builderPresetId,
      );
    }

    final governingStd = tenderStandard?.isNotEmpty == true
        ? tenderStandard!
        : 'IS 4984:2016';

    return DemoImageAnalysis(
      filename: rawName,
      displayTitle: 'Equipment Visual Scrutiny',
      contextText: contextText?.isNotEmpty == true
          ? contextText!
          : 'Municipal water supply pipeline',
      isCompliant: false,
      status: 'SCRUTINY REJECTED',
      governingStandard: governingStd,
      procurementCategory: 'Procurement Category Mismatch',
      resultTitle:
          'PRODUCT MISMATCH ALERT: IMAGE INVALID FOR SPECIFIED REQUIREMENT',
      resultDescription:
          'The uploaded equipment image does not correspond to the required procurement item and cannot be accepted for this tender.',
      categoryConflict:
          'Equipment photo/nameplate does not correspond to the required procurement category. Scrutiny rejected.',
      mismatchReason:
          'Equipment photo/nameplate corresponds to a different product category and violates specification consistency.',
      builderPresetId: '',
    );
  }
}

