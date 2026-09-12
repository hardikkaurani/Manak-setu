import 'knowledge_state.dart';

/// Represents a deterministic product image sample for offline demo analysis.
class ProductImageSample {
  final String id;
  final String title;
  final String category;
  final String department;
  final String detectedAttributes;
  final String material;
  final String sizeRating;
  final String application;
  final String performance;
  final KnowledgeState knowledgeState;
  final String technicalClause;
  final String presetId;
  final bool isSupported;
  final String? sampleAssetPath;

  const ProductImageSample({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.detectedAttributes,
    required this.material,
    required this.sizeRating,
    required this.application,
    required this.performance,
    required this.knowledgeState,
    required this.technicalClause,
    required this.presetId,
    this.isSupported = true,
    this.sampleAssetPath,
  });
}
