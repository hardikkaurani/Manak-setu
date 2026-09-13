import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/standard_version.dart';
import 'package:manaksetu/models/standard_amendment.dart';
import 'package:manaksetu/models/lifecycle_status.dart';
import 'package:manaksetu/services/temporal_validity_engine.dart';

void main() {
  group('TemporalValidityEngine & Retrospective Reasoning Tests', () {
    const engine = TemporalValidityEngine();

    final is1180Versions = [
      StandardVersion(
        id: 'is1180-1989',
        standardCode: 'IS 1180:1989',
        edition: 'First Revision',
        publicationDate: DateTime(1989, 4, 1),
        effectiveDate: DateTime(1989, 7, 1),
        withdrawalDate: DateTime(2014, 2, 1),
        status: StandardLifecycleStatus.superseded,
        supersededByVersionId: 'is1180-2014',
      ),
      StandardVersion(
        id: 'is1180-2014',
        standardCode: 'IS 1180 (Part 1):2014',
        edition: 'Fifth Revision',
        publicationDate: DateTime(2014, 2, 1),
        effectiveDate: DateTime(2014, 8, 1),
        status: StandardLifecycleStatus.current,
        supersedesVersionId: 'is1180-1989',
      ),
    ];

    final is1180Amendments = [
      StandardAmendment(
        id: 'amd-1',
        standardCode: 'IS 1180 (Part 1):2014',
        versionId: 'is1180-2014',
        amendmentNumber: 1,
        publicationDate: DateTime(2016, 5, 1),
        effectiveDate: DateTime(2016, 8, 1),
        scope: 'Revision of maximum energy losses at 50% and 100% loading',
      ),
      StandardAmendment(
        id: 'amd-2',
        standardCode: 'IS 1180 (Part 1):2014',
        versionId: 'is1180-2014',
        amendmentNumber: 2,
        publicationDate: DateTime(2019, 3, 1),
        effectiveDate: DateTime(2019, 6, 1),
        scope: 'Inclusion of corrugated tank specifications',
      ),
    ];

    test('correctly identifies applicable version for procurement tender in 2010', () {
      final result = engine.evaluateValidityOnDate(
        standardCode: 'IS 1180',
        procurementDate: DateTime(2010, 5, 15),
        versions: is1180Versions,
        amendments: is1180Amendments,
      );

      expect(result.isApplicable, isTrue);
      expect(result.applicableVersion?.edition, 'First Revision');
      expect(result.currentVersion?.edition, 'Fifth Revision');
      expect(result.effectiveAmendments.isEmpty, isTrue);
      expect(result.rationale, contains('superseded today by Fifth Revision'));
    });

    test('correctly identifies applicable version for procurement tender in 2018 with Amendment 1', () {
      final result = engine.evaluateValidityOnDate(
        standardCode: 'IS 1180',
        procurementDate: DateTime(2018, 9, 1),
        versions: is1180Versions,
        amendments: is1180Amendments,
      );

      expect(result.isApplicable, isTrue);
      expect(result.applicableVersion?.edition, 'Fifth Revision');
      expect(result.effectiveAmendments.length, equals(1));
      expect(result.effectiveAmendments.first.amendmentNumber, equals(1));
    });

    test('correctly rejects procurement date predating standard creation', () {
      final result = engine.evaluateValidityOnDate(
        standardCode: 'IS 1180',
        procurementDate: DateTime(1975, 1, 1),
        versions: is1180Versions,
        amendments: is1180Amendments,
      );

      expect(result.isApplicable, isFalse);
      expect(result.rationale, contains('predates the first published edition'));
    });
  });
}
