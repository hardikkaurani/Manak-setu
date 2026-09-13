import '../models/knowledge_state.dart';

/// Evaluates coverage boundaries to ensure ManakSetu is honest about uncertainty
/// and refuses to hallucinate unindexed jurisdictions, bodies, or standards.
class CoverageReport {
  final String query;
  final String? targetJurisdiction;
  final String? targetOrganization;
  final KnowledgeState state;
  final bool isIndexed;
  final String message;
  final List<String> availableJurisdictions;

  const CoverageReport({
    required this.query,
    this.targetJurisdiction,
    this.targetOrganization,
    required this.state,
    required this.isIndexed,
    required this.message,
    required this.availableJurisdictions,
  });

  @override
  String toString() => 'Coverage for $query [$state]: $message';
}

/// Intelligence engine checking whether requested jurisdictions, standard families,
/// and products fall within the actively indexed catalog.
class CoverageIntelligence {
  static const Set<String> indexedJurisdictions = {
    'IN',
    'INT',
    'US',
    'EU',
    'GB',
  };

  static const Set<String> unindexedJurisdictions = {
    'JP', // Japan (JISC) - provider exists but not yet indexed
    'AU', // Standards Australia
    'CA', // CSA Group
    'DE', // DIN
  };

  static const Set<String> indexedOrganizations = {
    'bis',
    'iso',
    'iec',
    'astm',
    'ieee',
    'bsi',
    'cen',
    'cenelec',
  };

  static const Set<String> indexedFamilies = {
    'IS',
    'ISO',
    'IEC',
    'ISO/IEC',
    'ASTM',
    'IEEE',
    'BS',
    'EN',
  };

  const CoverageIntelligence();

  /// Inspects a query or target jurisdiction to determine if it is within active indexing coverage.
  CoverageReport evaluateCoverage({
    required String query,
    String? jurisdictionId,
    String? organizationId,
    String? standardFamily,
  }) {
    final cleanJur = jurisdictionId?.toUpperCase();
    final cleanOrg = organizationId?.toLowerCase();
    final cleanFam = standardFamily?.toUpperCase();

    // Check if unindexed jurisdiction was explicitly requested
    if (cleanJur != null && unindexedJurisdictions.contains(cleanJur)) {
      return CoverageReport(
        query: query,
        targetJurisdiction: cleanJur,
        state: KnowledgeState.outOfCoverage,
        isIndexed: false,
        message: 'Jurisdiction [$cleanJur] is currently out of active indexing coverage. Direct catalog records are not available.',
        availableJurisdictions: indexedJurisdictions.toList(),
      );
    }

    if (cleanFam == 'JIS' || cleanOrg == 'jisc') {
      return CoverageReport(
        query: query,
        targetJurisdiction: 'JP',
        targetOrganization: 'jisc',
        state: KnowledgeState.outOfCoverage,
        isIndexed: false,
        message: 'Japanese Industrial Standards (JIS) catalog is not yet indexed in local store. Hallucination prohibited.',
        availableJurisdictions: indexedJurisdictions.toList(),
      );
    }

    // Check if target is supported
    final jurIndexed = cleanJur == null || indexedJurisdictions.contains(cleanJur);
    final orgIndexed = cleanOrg == null || indexedOrganizations.contains(cleanOrg);
    final famIndexed = cleanFam == null || indexedFamilies.contains(cleanFam);

    if (jurIndexed && orgIndexed && famIndexed) {
      return CoverageReport(
        query: query,
        targetJurisdiction: cleanJur,
        targetOrganization: cleanOrg,
        state: KnowledgeState.verified,
        isIndexed: true,
        message: 'Target is within actively verified coverage boundaries.',
        availableJurisdictions: indexedJurisdictions.toList(),
      );
    }

    return CoverageReport(
      query: query,
      targetJurisdiction: cleanJur,
      targetOrganization: cleanOrg,
      state: KnowledgeState.unknown,
      isIndexed: false,
      message: 'Coverage boundary uncertain for target. Flagged for review.',
      availableJurisdictions: indexedJurisdictions.toList(),
    );
  }
}
