import 'evidence.dart';

/// Specification details of a requirement in a specific jurisdiction.
class JurisdictionRequirementDetail {
  final String jurisdictionCode; // 'IN', 'US', 'EU', 'GB', 'INT'
  final String jurisdictionName;
  final String standardCode;
  final String organization;
  final String version;
  final String status;
  final String requirementSpecification;
  final Evidence? evidence;
  final String? differenceNotes;

  const JurisdictionRequirementDetail({
    required this.jurisdictionCode,
    required this.jurisdictionName,
    required this.standardCode,
    required this.organization,
    required this.version,
    required this.status,
    required this.requirementSpecification,
    this.evidence,
    this.differenceNotes,
  });

  Map<String, dynamic> toJson() => {
        'jurisdiction_code': jurisdictionCode,
        'jurisdiction_name': jurisdictionName,
        'standard_code': standardCode,
        'organization': organization,
        'version': version,
        'status': status,
        'requirement_specification': requirementSpecification,
        'evidence': evidence?.citationDisplay,
        'difference_notes': differenceNotes,
      };
}

/// A single technical parameter row compared across multiple jurisdictions.
class CrossJurisdictionParameterRow {
  final String parameterName;
  final String technicalDomain;
  final Map<String, JurisdictionRequirementDetail> jurisdictionValues;
  final String keyDifferencesSummary;
  final bool isHarmonized;

  const CrossJurisdictionParameterRow({
    required this.parameterName,
    required this.technicalDomain,
    required this.jurisdictionValues,
    required this.keyDifferencesSummary,
    required this.isHarmonized,
  });

  Map<String, dynamic> toJson() => {
        'parameter_name': parameterName,
        'technical_domain': technicalDomain,
        'is_harmonized': isHarmonized,
        'key_differences_summary': keyDifferencesSummary,
        'jurisdictions': jurisdictionValues.map((k, v) => MapEntry(k, v.toJson())),
      };
}

/// The complete multi-jurisdiction comparison matrix for a product family.
class CrossJurisdictionMatrix {
  final String productId;
  final String productTitle;
  final List<String> comparedJurisdictions;
  final List<CrossJurisdictionParameterRow> rows;
  final DateTime generatedAt;
  final String provenanceNote;

  const CrossJurisdictionMatrix({
    required this.productId,
    required this.productTitle,
    required this.comparedJurisdictions,
    required this.rows,
    required this.generatedAt,
    this.provenanceNote = 'All regional specifications grounded in Tier 1 SDO gazettes and standards metadata.',
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_title': productTitle,
        'compared_jurisdictions': comparedJurisdictions,
        'rows': rows.map((r) => r.toJson()).toList(),
        'generated_at': generatedAt.toIso8601String(),
        'provenance_note': provenanceNote,
      };
}
