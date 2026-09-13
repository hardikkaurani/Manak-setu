import '../models/standard.dart';
import '../models/standard_relationship.dart';
import '../models/jurisdiction.dart';
import '../models/standards_organization.dart';

/// Severity of a data quality finding.
enum QualityFindingSeverity {
  critical,
  warning,
  info,
}

/// A specific data quality violation or anomaly found during catalog validation.
class QualityFinding {
  final String entityId;
  final String rule;
  final QualityFindingSeverity severity;
  final String message;

  const QualityFinding({
    required this.entityId,
    required this.rule,
    required this.severity,
    required this.message,
  });

  @override
  String toString() => '[$severity] $entityId — $rule: $message';
}

/// Comprehensive validation engine ensuring data integrity, chronological consistency,
/// and referential soundness across the global standards repository.
class DataQualityValidator {
  const DataQualityValidator();

  /// Validates an individual standard record against canonical quality rules.
  List<QualityFinding> validateStandard(
    Standard standard, {
    List<Jurisdiction>? knownJurisdictions,
    List<StandardsOrganization>? knownOrganizations,
  }) {
    final findings = <QualityFinding>[];

    // Rule 1: Code Format
    if (standard.code.trim().isEmpty) {
      findings.add(
        QualityFinding(
          entityId: standard.standardId,
          rule: 'VALID_CODE',
          severity: QualityFindingSeverity.critical,
          message: 'Standard code must not be empty.',
        ),
      );
    }

    // Rule 2: Title Completeness
    if (standard.title.trim().length < 5) {
      findings.add(
        QualityFinding(
          entityId: standard.code,
          rule: 'TITLE_LENGTH',
          severity: QualityFindingSeverity.warning,
          message: 'Title is suspiciously short: "${standard.title}".',
        ),
      );
    }

    // Rule 3: Known Jurisdiction Referential Integrity
    if (knownJurisdictions != null &&
        !knownJurisdictions.any((j) => j.id.toUpperCase() == standard.jurisdictionId.toUpperCase())) {
      findings.add(
        QualityFinding(
          entityId: standard.code,
          rule: 'KNOWN_JURISDICTION',
          severity: QualityFindingSeverity.critical,
          message: 'Jurisdiction "${standard.jurisdictionId}" is not registered in canonical jurisdictions.',
        ),
      );
    }

    // Rule 4: Known Organization Referential Integrity
    if (knownOrganizations != null &&
        !knownOrganizations.any((o) => o.id.toLowerCase() == standard.organizationId.toLowerCase())) {
      findings.add(
        QualityFinding(
          entityId: standard.code,
          rule: 'KNOWN_ORGANIZATION',
          severity: QualityFindingSeverity.critical,
          message: 'Issuing organization "${standard.organizationId}" is not in registered organizations.',
        ),
      );
    }

    // Rule 5: Chronological Consistency
    if (standard.publicationDate != null && standard.withdrawalDate != null) {
      if (standard.withdrawalDate!.isBefore(standard.publicationDate!)) {
        findings.add(
          QualityFinding(
            entityId: standard.code,
            rule: 'CHRONOLOGICAL_ORDER',
            severity: QualityFindingSeverity.critical,
            message: 'Withdrawal date (${standard.withdrawalDate}) cannot predate publication date (${standard.publicationDate}).',
          ),
        );
      }
    }

    // Rule 6: Year consistency
    if (standard.year != null && (standard.year! < 1850 || standard.year! > 2100)) {
      findings.add(
        QualityFinding(
          entityId: standard.code,
          rule: 'IMPOSSIBLE_YEAR',
          severity: QualityFindingSeverity.critical,
          message: 'Publication year ${standard.year} is outside realistic boundaries.',
        ),
      );
    }

    // Rule 7: Provenance requirement
    if (standard.provenance.trim().isEmpty) {
      findings.add(
        QualityFinding(
          entityId: standard.code,
          rule: 'PROVENANCE_REQUIRED',
          severity: QualityFindingSeverity.warning,
          message: 'Provenance statement is missing for standard ${standard.code}.',
        ),
      );
    }

    return findings;
  }

  /// Detects duplicate codes and contradictory records in a candidate standard list.
  List<QualityFinding> detectCatalogDuplicates(List<Standard> catalog) {
    final findings = <QualityFinding>[];
    final seenCodes = <String, Standard>{};

    for (final std in catalog) {
      final key = std.code.trim().toUpperCase();
      if (seenCodes.containsKey(key)) {
        findings.add(
          QualityFinding(
            entityId: std.code,
            rule: 'DUPLICATE_CODE',
            severity: QualityFindingSeverity.critical,
            message: 'Duplicate standard code "$key" found in catalog.',
          ),
        );
      } else {
        seenCodes[key] = std;
      }
    }

    return findings;
  }

  /// Detects orphan relationships pointing to non-existent standards.
  List<QualityFinding> detectOrphanRelationships({
    required List<StandardRelationship> relationships,
    required List<Standard> catalog,
  }) {
    final findings = <QualityFinding>[];
    final knownCodes = catalog.map((s) => s.code.toUpperCase()).toSet();

    for (final rel in relationships) {
      final srcExists = knownCodes.any((c) => c.contains(rel.sourceStandardCode.toUpperCase()));
      final tgtExists = knownCodes.any((c) => c.contains(rel.targetStandardCode.toUpperCase()));

      if (!srcExists) {
        findings.add(
          QualityFinding(
            entityId: rel.id,
            rule: 'ORPHAN_SOURCE',
            severity: QualityFindingSeverity.warning,
            message: 'Source standard "${rel.sourceStandardCode}" not found in indexed catalog.',
          ),
        );
      }

      if (!tgtExists) {
        findings.add(
          QualityFinding(
            entityId: rel.id,
            rule: 'ORPHAN_TARGET',
            severity: QualityFindingSeverity.warning,
            message: 'Target standard "${rel.targetStandardCode}" not found in indexed catalog.',
          ),
        );
      }
    }

    return findings;
  }
}
