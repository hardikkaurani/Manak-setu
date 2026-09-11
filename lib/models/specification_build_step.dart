import 'evidence.dart';

/// Represents a single progressive statutory correction step in the Specification Builder.
///
/// Holds the authoritative score progression (`scoreBefore` and `scoreAfter`),
/// the targeted section ID, defective snippet, and compliant replacement text.
class SpecificationBuildStep {
  final String id;
  final int stepNumber; // 1, 2, 3, 4
  final String title;
  final String problem;
  final String defectiveSnippet;
  final String replacementSnippet;
  final String explanation;
  final int scoreBefore;
  final int scoreAfter; // Authoritative progression score
  final String targetSectionId; // e.g. 'sec-1', 'sec-2', etc.
  final Evidence? evidence;

  const SpecificationBuildStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.problem,
    required this.defectiveSnippet,
    required this.replacementSnippet,
    required this.explanation,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.targetSectionId,
    this.evidence,
  });
}

