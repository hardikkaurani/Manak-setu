import '../models/standard.dart';
import '../models/standard_version.dart';
import '../models/standard_amendment.dart';
import '../models/lifecycle_status.dart';

/// Assessment of a standard's legal and technical validity at a specific point in time.
class TemporalValidityResult {
  final String standardCode;
  final DateTime targetDate;
  final bool isApplicable;
  final StandardVersion? applicableVersion;
  final List<StandardAmendment> effectiveAmendments;
  final StandardVersion? currentVersion;
  final String? supersededByCode;
  final String rationale;

  const TemporalValidityResult({
    required this.standardCode,
    required this.targetDate,
    required this.isApplicable,
    this.applicableVersion,
    this.effectiveAmendments = const [],
    this.currentVersion,
    this.supersededByCode,
    required this.rationale,
  });

  @override
  String toString() =>
      'Validity for $standardCode on ${targetDate.toIso8601String().split("T").first}: '
      '${isApplicable ? "VALID (${applicableVersion?.edition ?? 'Current'})" : "INVALID / SUPERSEDED"}';
}

/// Reasoning engine for temporal validity, historical version retrieval, and supersession tracking.
class TemporalValidityEngine {
  const TemporalValidityEngine();

  /// Evaluates which edition and amendments of a standard were legally applicable on [procurementDate].
  TemporalValidityResult evaluateValidityOnDate({
    required String standardCode,
    required DateTime procurementDate,
    required List<StandardVersion> versions,
    List<StandardAmendment> amendments = const [],
    Standard? catalogStandard,
  }) {
    if (versions.isEmpty) {
      // Fall back to catalog standard if explicit version history is not indexed
      if (catalogStandard != null) {
        final pubDate = catalogStandard.publicationDate;
        final withDate = catalogStandard.withdrawalDate;

        final isAfterPub = pubDate == null || !procurementDate.isBefore(pubDate);
        final isBeforeWith = withDate == null || !procurementDate.isAfter(withDate);
        final isApplicable = isAfterPub && isBeforeWith && !catalogStandard.isObsolete;

        return TemporalValidityResult(
          standardCode: standardCode,
          targetDate: procurementDate,
          isApplicable: isApplicable,
          supersededByCode: catalogStandard.replacementCode,
          rationale: isApplicable
              ? 'Catalog standard was active on ${procurementDate.toIso8601String().split("T").first}.'
              : (catalogStandard.replacementCode != null
                  ? 'Standard was superseded by ${catalogStandard.replacementCode}.'
                  : 'Standard was withdrawn or not yet published.'),
        );
      }

      return TemporalValidityResult(
        standardCode: standardCode,
        targetDate: procurementDate,
        isApplicable: false,
        rationale: 'No version history or catalog record found for standard $standardCode.',
      );
    }

    // Sort versions by effective date ascending
    final sortedVersions = List<StandardVersion>.from(versions)
      ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    StandardVersion? applicableVersion;
    for (final v in sortedVersions) {
      if (v.isApplicableOn(procurementDate)) {
        applicableVersion = v;
      }
    }

    final currentVersion = sortedVersions.firstWhere(
      (v) => v.status == StandardLifecycleStatus.current,
      orElse: () => sortedVersions.last,
    );

    if (applicableVersion == null) {
      // Check if procurement date was before the first published edition
      if (procurementDate.isBefore(sortedVersions.first.effectiveDate)) {
        return TemporalValidityResult(
          standardCode: standardCode,
          targetDate: procurementDate,
          isApplicable: false,
          currentVersion: currentVersion,
          rationale: 'Procurement date predates the first published edition (${sortedVersions.first.edition}).',
        );
      }

      // If after all versions and all are withdrawn
      final lastVersion = sortedVersions.last;
      return TemporalValidityResult(
        standardCode: standardCode,
        targetDate: procurementDate,
        isApplicable: false,
        currentVersion: currentVersion,
        supersededByCode: lastVersion.supersededByVersionId,
        rationale: 'Standard was already withdrawn or superseded on this date. Replaced by ${lastVersion.supersededByVersionId ?? "newer standard"}.',
      );
    }

    // Find amendments effective on the procurement date
    final effectiveAmds = amendments.where((a) {
      return a.versionId == applicableVersion!.id && a.isEffectiveOn(procurementDate);
    }).toList();

    final isCurrent = applicableVersion.id == currentVersion.id;

    return TemporalValidityResult(
      standardCode: standardCode,
      targetDate: procurementDate,
      isApplicable: true,
      applicableVersion: applicableVersion,
      effectiveAmendments: effectiveAmds,
      currentVersion: currentVersion,
      supersededByCode: applicableVersion.supersededByVersionId,
      rationale: isCurrent
          ? 'Active edition (${applicableVersion.edition}) with ${effectiveAmds.length} effective amendment(s).'
          : 'Historical edition (${applicableVersion.edition}) was legally in force on this date, but is superseded today by ${currentVersion.edition}.',
    );
  }

  /// Compares two versions and summarizes architectural and requirement differences.
  String summarizeVersionChanges(StandardVersion oldVersion, StandardVersion newVersion) {
    if (newVersion.changeSummary != null && newVersion.changeSummary!.isNotEmpty) {
      return newVersion.changeSummary!;
    }
    return 'Revision upgrade from ${oldVersion.edition} (${oldVersion.effectiveDate.year}) '
        'to ${newVersion.edition} (${newVersion.effectiveDate.year}).';
  }
}
