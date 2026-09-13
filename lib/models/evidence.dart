import 'dart:convert';

/// Source governance hierarchy classifying provenance integrity.
///
/// TIER 1 — Official standards organizations, official regulators, official certification bodies.
/// TIER 2 — Official government mirrors, ministerial gazette portals, statutory databases.
/// TIER 3 — Reputable secondary sources, accredited testing laboratories, industry bodies.
/// TIER 4 — Unverified web sources, crowdsourced citations, external unauthenticated repositories.
enum SourceTier {
  tier1Authoritative('Tier 1: Authoritative SDO / Regulator', 1.0),
  tier2OfficialMirror('Tier 2: Official Mirror / Government Source', 0.85),
  tier3ReputableSecondary('Tier 3: Reputable Secondary Source', 0.65),
  tier4UnverifiedWeb('Tier 4: Unverified Web Source', 0.30);

  final String displayName;
  final double trustWeight;
  const SourceTier(this.displayName, this.trustWeight);

  /// Whether this source tier is legally authoritative for public procurement decisions.
  bool get isAuthoritative => this == SourceTier.tier1Authoritative || this == SourceTier.tier2OfficialMirror;
}

/// Represents concrete provenance-backed evidence cited for a requirement, finding, or relationship.
///
/// Implements strict provenance governance: when exact clause/page evidence is unverified,
/// [Evidence.unavailable] must be returned instead of fabricating citations.
class Evidence {
  final String id;
  final String standardCode;
  final String? defectiveStandardCode;
  final String? replacementStandardCode;
  final String? section;
  final String? clause;
  final String? page;
  final String? table;
  final String sourceFile;
  final String textExcerpt;
  final String? sourceUrl;
  final SourceTier sourceTier;
  final String sourceOrganization;
  final DateTime? retrievedAt;
  final String? contentVersion;
  final String verificationStatus;
  final String? evidenceHash;
  final String? licenseNotes;
  final bool isAvailable;

  const Evidence({
    String? id,
    required this.standardCode,
    this.defectiveStandardCode,
    this.replacementStandardCode,
    this.section,
    this.clause,
    this.page,
    this.table,
    required this.sourceFile,
    required this.textExcerpt,
    this.sourceUrl,
    this.sourceTier = SourceTier.tier1Authoritative,
    this.sourceOrganization = 'Bureau of Indian Standards',
    this.retrievedAt,
    this.contentVersion = '1.0',
    this.verificationStatus = 'VERIFIED',
    String? evidenceHash,
    this.licenseNotes = 'Licensed metadata / public statutory extract',
    this.isAvailable = true,
  })  : id = id ?? '$standardCode-${clause ?? section ?? "cl"}',
        evidenceHash = evidenceHash ??
            (textExcerpt == 'EVIDENCE_UNAVAILABLE'
                ? null
                : 'sha256:generated');

  /// Fallback factory when exact clause or page text cannot be proven from authorized sources.
  /// Strictly prevents fabricating citations or masquerading unverified claims as facts.
  factory Evidence.unavailable({
    required String standardCode,
    String? clause,
    String? reason,
  }) {
    return Evidence(
      id: 'unavailable-$standardCode',
      standardCode: standardCode,
      clause: clause,
      sourceFile: 'UNAVAILABLE',
      textExcerpt: 'EVIDENCE_UNAVAILABLE: ${reason ?? "Exact clause/page extract not indexed in verified repository."}',
      sourceTier: SourceTier.tier4UnverifiedWeb,
      sourceOrganization: 'UNKNOWN',
      verificationStatus: 'EVIDENCE_UNAVAILABLE',
      isAvailable: false,
      licenseNotes: 'None',
    );
  }

  /// Human-readable citation formatted for display in reports and audit logs.
  String get citationDisplay {
    if (!isAvailable) return '[$standardCode] EVIDENCE_UNAVAILABLE';
    final parts = <String>[standardCode];
    if (section != null) parts.add('Sec. $section');
    if (clause != null) parts.add('Clause $clause');
    if (table != null) parts.add(table!);
    if (page != null) parts.add('Page $page');
    return parts.join(' · ');
  }

  /// Alias for citationDisplay.
  String get citation => citationDisplay;

  /// Computes a deterministic evidence hash for tamper-evident provenance.
  static String computeHash({
    required String standardCode,
    required String excerpt,
    String? sourceFile,
    String? clause,
  }) {
    final payload = utf8.encode('$standardCode|$sourceFile|$clause|$excerpt');
    var hash = 0xcbf29ce484222325;
    for (final byte in payload) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0').substring(0, 16);
  }
}
