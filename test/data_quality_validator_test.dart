import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/data/demo_data.dart';
import 'package:manaksetu/models/standard.dart';
import 'package:manaksetu/models/standard_relationship.dart';
import 'package:manaksetu/services/data_quality_validator.dart';
import 'package:manaksetu/services/ingestion_pipeline.dart';

void main() {
  group('DataQualityValidator & Ingestion Pipeline Tests', () {
    const validator = DataQualityValidator();
    final catalog = DemoData.allGlobalStandardsCatalog;

    test('validates canonical catalog standards with 0 critical errors', () {
      final findings = <QualityFinding>[];
      for (final std in catalog) {
        findings.addAll(
          validator.validateStandard(
            std,
            knownJurisdictions: DemoData.jurisdictions,
            knownOrganizations: DemoData.standardsOrganizations,
          ),
        );
      }

      final criticals = findings.where((f) => f.severity == QualityFindingSeverity.critical);
      expect(criticals.isEmpty, isTrue);
    });

    test('catches chronological date anomalies (withdrawal before publication)', () {
      final invalidStandard = Standard(
        code: 'TEST 9999',
        title: 'Broken Chronology Standard',
        status: 'WITHDRAWN',
        publicationDate: DateTime(2020, 1, 1),
        withdrawalDate: DateTime(2010, 1, 1), // Anomaly: withdrawn 10 years before published!
      );

      final findings = validator.validateStandard(invalidStandard);
      expect(findings.any((f) => f.rule == 'CHRONOLOGICAL_ORDER'), isTrue);
    });

    test('detects duplicate codes in candidate catalog', () {
      const std1 = Standard(code: 'IS 1180', title: 'Transformer Part 1', status: 'CURRENT');
      const std2 = Standard(code: 'IS 1180', title: 'Duplicate Record', status: 'CURRENT');

      final duplicates = validator.detectCatalogDuplicates([std1, std2]);
      expect(duplicates.any((f) => f.rule == 'DUPLICATE_CODE'), isTrue);
    });

    test('detects orphan relationships pointing to missing standards', () {
      final orphanRel = StandardRelationship(
        id: 'orphan-1',
        sourceStandardCode: 'NON_EXISTENT_CODE_A',
        targetStandardCode: 'IS 1180 (Part 1):2014',
        relationshipType: RelationshipType.normativeReference,
        createdAt: DateTime.now(),
      );

      final orphans = validator.detectOrphanRelationships(
        relationships: [orphanRel],
        catalog: catalog,
      );

      expect(orphans.any((f) => f.rule == 'ORPHAN_SOURCE'), isTrue);
    });

    test('StandardsIngestionPipeline normalizes, deduplicates, and generates version info', () {
      const pipeline = StandardsIngestionPipeline();

      final runResult = pipeline.executeIngestionRun(
        targetVersionId: 'v1.0.0-test',
        rawCandidates: catalog,
      );

      expect(runResult.isSuccessful, isTrue);
      expect(runResult.versionInfo.totalRecords, equals(catalog.length));
      expect(runResult.versionInfo.versionId, 'v1.0.0-test');
      expect(runResult.versionInfo.checksumSha256, contains('v1.0.0-test'));
    });
  });
}
