import 'evidence.dart';

/// Degree of technical and statutory equivalence between standards from different jurisdictions.
enum EquivalenceDegree {
  /// Identical technical requirements, test methods, and acceptance thresholds
  /// (e.g. dual-logo ISO/IEC publications or identical national endorsements).
  exactEquivalent,

  /// Core technical parameters and test methods are aligned with identical performance criteria,
  /// subject only to editorial formatting differences.
  technicallyAligned,

  /// Direct national adoption of an international standard with national foreword and informative annexes.
  adoptedVersion,

  /// Adopted standard with specified modifications (e.g. tropical environmental factors, regional voltage/frequency, local raw material grades).
  modifiedAdoption,

  /// Overlaps in certain sub-clauses, test methodologies, or dimensions, but differs in overall scope.
  partialCorrespondence,

  /// Governs the same equipment or material category, but utilizes fundamentally different design formulas or test regimes.
  relatedOnly,

  /// Equivalence has been asserted or referenced without verifiable statutory concordance evidence.
  unknown;

  /// User-facing label for UI cards and badges.
  String get displayName {
    switch (this) {
      case EquivalenceDegree.exactEquivalent:
        return 'EXACT EQUIVALENT';
      case EquivalenceDegree.technicallyAligned:
        return 'TECHNICALLY ALIGNED';
      case EquivalenceDegree.adoptedVersion:
        return 'ADOPTED VERSION';
      case EquivalenceDegree.modifiedAdoption:
        return 'MODIFIED ADOPTION';
      case EquivalenceDegree.partialCorrespondence:
        return 'PARTIAL CORRESPONDENCE';
      case EquivalenceDegree.relatedOnly:
        return 'RELATED ONLY';
      case EquivalenceDegree.unknown:
        return 'EQUIVALENCE UNVERIFIED';
    }
  }

  /// True if the standards can be substituted in technical procurement without substantial re-engineering.
  bool get isSubstitutable =>
      this == EquivalenceDegree.exactEquivalent ||
      this == EquivalenceDegree.technicallyAligned ||
      this == EquivalenceDegree.adoptedVersion;
}

/// Represents an authoritative or empirical equivalence mapping between two standards.
class InternationalEquivalence {
  final String sourceStandardCode;
  final String targetStandardCode;
  final String sourceJurisdictionId;
  final String targetJurisdictionId;
  final EquivalenceDegree degree;
  final double confidence;
  final String comparisonSummary;
  final List<String> keyDifferences;
  final Evidence? evidence;

  const InternationalEquivalence({
    required this.sourceStandardCode,
    required this.targetStandardCode,
    required this.sourceJurisdictionId,
    required this.targetJurisdictionId,
    required this.degree,
    this.confidence = 1.0,
    required this.comparisonSummary,
    this.keyDifferences = const [],
    this.evidence,
  });

  /// Alias for source standard code
  String get standardCodeA => sourceStandardCode;

  /// Alias for target standard code
  String get standardCodeB => targetStandardCode;

  /// Alias for key technical differences
  List<String> get differences => keyDifferences;

  @override
  String toString() =>
      '$sourceStandardCode ↔ $targetStandardCode (${degree.displayName})';
}
