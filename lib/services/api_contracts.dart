import '../models/standard.dart';
import '../models/international_equivalence.dart';
import '../models/compliance_finding.dart';
import 'retrieval_engine.dart';

/// Standard versioned API route constants for ManakSetu platform.
abstract final class ApiRoutes {
  static const String version = 'v1';
  static const String basePath = '/api/v1';

  // Standards Catalog & Metadata
  static const String standards = '$basePath/standards';
  static const String standardsSearch = '$basePath/standards/search';
  static String standardById(String id) => '$basePath/standards/$id';
  static String standardRelationships(String id) => '$basePath/standards/$id/relationships';
  static String standardVersions(String id) => '$basePath/standards/$id/versions';
  static String standardEquivalences(String id) => '$basePath/standards/$id/equivalences';

  // Ontologies & Authorities
  static const String jurisdictions = '$basePath/jurisdictions';
  static String jurisdictionById(String id) => '$basePath/jurisdictions/$id';
  static const String organizations = '$basePath/organizations';
  static String organizationById(String id) => '$basePath/organizations/$id';

  // Analysis & Verification
  static const String analyze = '$basePath/analyze';
  static const String gapAnalysis = '$basePath/gap-analysis';
  static const String evidence = '$basePath/evidence';
  static String evidenceById(String id) => '$basePath/evidence/$id';
}

/// Request payload for specification scrutiny analysis.
class SpecificationAnalysisRequest {
  final String clauseText;
  final List<String> targetJurisdictions;
  final String? productCategory;
  final String? department;
  final bool enableEquivalenceExpansion;

  const SpecificationAnalysisRequest({
    required this.clauseText,
    this.targetJurisdictions = const ['IN'],
    this.productCategory,
    this.department,
    this.enableEquivalenceExpansion = true,
  });

  Map<String, dynamic> toJson() => {
        'clause_text': clauseText,
        'target_jurisdictions': targetJurisdictions,
        'product_category': productCategory,
        'department': department,
        'enable_equivalence_expansion': enableEquivalenceExpansion,
      };
}

/// Structured response payload for specification analysis.
class SpecificationAnalysisResponse {
  final String analysisId;
  final int compliancePercentage;
  final String status;
  final List<StandardRecommendation> recommendations;
  final List<ComplianceFinding> findings;
  final List<InternationalEquivalence> detectedEquivalences;
  final String decisionTraceSummary;
  final DateTime timestamp;

  const SpecificationAnalysisResponse({
    required this.analysisId,
    required this.compliancePercentage,
    required this.status,
    required this.recommendations,
    required this.findings,
    this.detectedEquivalences = const [],
    required this.decisionTraceSummary,
    required this.timestamp,
  });
}

/// Search request parameters for global standards query.
class StandardSearchRequest {
  final String query;
  final List<String>? jurisdictions;
  final List<String>? organizations;
  final List<String>? families;
  final String? status;
  final int page;
  final int pageSize;

  const StandardSearchRequest({
    this.query = '',
    this.jurisdictions,
    this.organizations,
    this.families,
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });
}

/// Standardized paginated response for standards catalog.
class StandardSearchResponse {
  final List<Standard> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const StandardSearchResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });
}
