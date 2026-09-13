import 'evidence.dart';

/// The compliance and completeness status of a specific procurement requirement.
enum GapStatus {
  covered('COVERED', 'Requirement fully satisfied by standard and verified by authoritative evidence'),
  partial('PARTIAL', 'Partially addressed; specific parameters, test methods, or ratings omitted'),
  missing('MISSING', 'Required technical parameter or test is absent from the specified standard'),
  ambiguous('AMBIGUOUS', 'Tender clause is vaguely worded or open to conflicting engineering interpretations'),
  conflicting('CONFLICTING', 'Tender specification directly conflicts with mandatory limits of standard'),
  unverifiable('UNVERIFIABLE', 'Authority evidence unavailable to confirm compliance'),
  outOfCoverage('OUT_OF_COVERAGE', 'Required standard or testing domain is not currently indexed');

  final String label;
  final String description;
  const GapStatus(this.label, this.description);

  bool get isCompliant => this == GapStatus.covered;
  bool get requiresAction => this != GapStatus.covered;
}

/// An individual parameter evaluation within a Specification Gap Analysis.
class GapAnalysisItem {
  final String id;
  final String parameterName;
  final String tenderRequirement;
  final String? standardRequirement;
  final String? standardCode;
  final String? standardClause;
  final GapStatus status;
  final String? missingElement; // e.g. "Specific corrosion test method (ASTM B117 / IS 9000)"
  final String? conflictDetails;
  final Evidence? evidence;
  final String engineeringRecommendation;

  const GapAnalysisItem({
    required this.id,
    required this.parameterName,
    required this.tenderRequirement,
    this.standardRequirement,
    this.standardCode,
    this.standardClause,
    required this.status,
    this.missingElement,
    this.conflictDetails,
    this.evidence,
    required this.engineeringRecommendation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'parameter_name': parameterName,
        'tender_requirement': tenderRequirement,
        'standard_requirement': standardRequirement,
        'standard_code': standardCode,
        'standard_clause': standardClause,
        'status': status.label,
        'missing_element': missingElement,
        'conflict_details': conflictDetails,
        'evidence_citation': evidence?.citationDisplay,
        'engineering_recommendation': engineeringRecommendation,
      };
}

/// Overall result of a Specification Gap Analysis on a tender or technical document.
class SpecificationGapAnalysis {
  final String analysisId;
  final String tenderTitle;
  final String targetStandardCode;
  final List<GapAnalysisItem> items;
  final double coveragePercentage;
  final int coveredCount;
  final int partialCount;
  final int missingCount;
  final int conflictingCount;
  final DateTime evaluatedAt;

  const SpecificationGapAnalysis({
    required this.analysisId,
    required this.tenderTitle,
    required this.targetStandardCode,
    required this.items,
    required this.coveragePercentage,
    required this.coveredCount,
    required this.partialCount,
    required this.missingCount,
    required this.conflictingCount,
    required this.evaluatedAt,
  });

  bool get hasCriticalGaps => missingCount > 0 || conflictingCount > 0;

  Map<String, dynamic> toJson() => {
        'analysis_id': analysisId,
        'tender_title': tenderTitle,
        'target_standard_code': targetStandardCode,
        'coverage_percentage': coveragePercentage,
        'covered_count': coveredCount,
        'partial_count': partialCount,
        'missing_count': missingCount,
        'conflicting_count': conflictingCount,
        'items': items.map((i) => i.toJson()).toList(),
        'evaluated_at': evaluatedAt.toIso8601String(),
      };
}
