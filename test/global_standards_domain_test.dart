import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/data/demo_data.dart';
import 'package:manaksetu/models/international_equivalence.dart';
import 'package:manaksetu/models/lifecycle_status.dart';
import 'package:manaksetu/models/standard.dart';
import 'package:manaksetu/repositories/standards_repository.dart';

void main() {
  group('StandardLifecycleStatus Domain Tests', () {
    test('supports all 8 non-boolean lifecycle states', () {
      expect(StandardLifecycleStatus.values.length, 8);
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.current));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.amended));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.superseded));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.withdrawn));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.draft));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.unknown));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.conflicting));
      expect(StandardLifecycleStatus.values, contains(StandardLifecycleStatus.unverified));
    });

    test('parses from string correctly', () {
      expect(StandardLifecycleStatus.fromString('CURRENT'), StandardLifecycleStatus.current);
      expect(StandardLifecycleStatus.fromString('SUPERSEDED'), StandardLifecycleStatus.superseded);
      expect(StandardLifecycleStatus.fromString('AMENDED'), StandardLifecycleStatus.amended);
      expect(StandardLifecycleStatus.fromString('WITHDRAWN'), StandardLifecycleStatus.withdrawn);
      expect(StandardLifecycleStatus.fromString('DRAFT'), StandardLifecycleStatus.draft);
      expect(StandardLifecycleStatus.fromString('UNKNOWN'), StandardLifecycleStatus.unknown);
      expect(StandardLifecycleStatus.fromString('CONFLICTING'), StandardLifecycleStatus.conflicting);
      expect(StandardLifecycleStatus.fromString('UNVERIFIED'), StandardLifecycleStatus.unverified);
      expect(StandardLifecycleStatus.fromString('SOMETHING_ELSE'), StandardLifecycleStatus.unknown);
    });

    test('evaluates isObsolete and isActive correctly', () {
      expect(StandardLifecycleStatus.current.isActive, isTrue);
      expect(StandardLifecycleStatus.amended.isActive, isTrue);
      expect(StandardLifecycleStatus.superseded.isActive, isFalse);
      expect(StandardLifecycleStatus.withdrawn.isActive, isFalse);

      expect(StandardLifecycleStatus.superseded.isObsolete, isTrue);
      expect(StandardLifecycleStatus.withdrawn.isObsolete, isTrue);
      expect(StandardLifecycleStatus.current.isObsolete, isFalse);
    });
  });

  group('Jurisdiction & Standards Organization Registry Tests', () {
    test('verifies canonical jurisdictions exist', () {
      final jurisdictions = DemoData.jurisdictions;
      final ids = jurisdictions.map((j) => j.jurisdictionId).toList();

      expect(ids, contains('IN'));
      expect(ids, contains('INT'));
      expect(ids, contains('US'));
      expect(ids, contains('EU'));
      expect(ids, contains('GB'));
      expect(ids, contains('DE'));
      expect(ids, contains('JP'));
    });

    test('verifies canonical standards organizations exist', () {
      final orgs = DemoData.standardsOrganizations;
      final orgIds = orgs.map((o) => o.organizationId).toList();

      expect(orgIds, contains('bis'));
      expect(orgIds, contains('iso'));
      expect(orgIds, contains('iec'));
      expect(orgIds, contains('astm'));
      expect(orgIds, contains('ieee'));
      expect(orgIds, contains('asme'));
      expect(orgIds, contains('cen'));
      expect(orgIds, contains('bsi'));
      expect(orgIds, contains('jisc'));
    });

    test('verifies standard families registry', () {
      final families = DemoData.standardFamilies;
      final familyPrefixes = families.map((f) => f.prefix).toList();

      expect(familyPrefixes, contains('IS'));
      expect(familyPrefixes, contains('ISO'));
      expect(familyPrefixes, contains('IEC'));
      expect(familyPrefixes, contains('ASTM'));
      expect(familyPrefixes, contains('IEEE'));
      expect(familyPrefixes, contains('ASME'));
      expect(familyPrefixes, contains('EN'));
      expect(familyPrefixes, contains('BS'));
      expect(familyPrefixes, contains('JIS'));
    });
  });

  group('International Equivalence Matrix Tests', () {
    test('supports all degrees of equivalence', () {
      expect(EquivalenceDegree.values.length, 7);
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.exactEquivalent));
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.technicallyAligned));
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.adoptedVersion));
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.modifiedAdoption));
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.partialCorrespondence));
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.relatedOnly));
      expect(EquivalenceDegree.values, contains(EquivalenceDegree.unknown));
    });

    test('resolves equivalences for IS 1180 to IEC 60076-1, IEEE C57.12.00, and EN 50588-1', () {
      final equivalences = DemoData.getEquivalencesForStandard('IS 1180 (Part 1)');
      expect(equivalences.isNotEmpty, isTrue);

      final targetCodes = equivalences.map((e) => e.standardCodeB).toList();
      expect(targetCodes, anyElement(contains('IEC 60076-1')));
      expect(targetCodes, anyElement(contains('IEEE C57.12.00')));
      expect(targetCodes, anyElement(contains('EN 50588-1')));

      final iecEquivalence = equivalences.firstWhere((e) => e.standardCodeB.contains('IEC 60076-1'));
      expect(iecEquivalence.degree, EquivalenceDegree.technicallyAligned);
      expect(iecEquivalence.confidence, greaterThanOrEqualTo(0.90));
      expect(iecEquivalence.differences, isNotEmpty);
      expect(iecEquivalence.evidence, isNotNull);
    });

    test('resolves bidirectional equivalence lookup', () {
      final fromIec = DemoData.getEquivalencesForStandard('IEC 60076-1');
      expect(fromIec.isNotEmpty, isTrue);
      final hasIs1180 = fromIec.any((e) => e.standardCodeA.contains('IS 1180') || e.standardCodeB.contains('IS 1180'));
      expect(hasIs1180, isTrue);
    });

    test('resolves equivalences for HDPE Pipe (IS 4984 ↔ ISO 4427-1, ASTM D3035)', () {
      final equivalences = DemoData.getEquivalencesForStandard('IS 4984');
      final targets = equivalences.map((e) => e.standardCodeB).toList();

      expect(targets, anyElement(contains('ISO 4427-1')));
      expect(targets, anyElement(contains('ASTM D3035')));
      expect(targets, anyElement(contains('EN 12201-2')));
    });

    test('resolves equivalences for Steel Rebars (IS 1786 ↔ ISO 6935-2, ASTM A615, BS 4449)', () {
      final equivalences = DemoData.getEquivalencesForStandard('IS 1786');
      final targets = equivalences.map((e) => e.standardCodeB).toList();

      expect(targets, anyElement(contains('ISO 6935-2')));
      expect(targets, anyElement(contains('ASTM A615')));
      expect(targets, anyElement(contains('BS 4449')));
    });
  });

  group('Standard Domain Model Global Upgrades & Backward Compatibility', () {
    test('preserves backward compatibility with legacy fields', () {
      const legacyStd = Standard(
        code: 'IS 9999',
        title: 'Test Standard',
        division: 'ETD',
        status: 'CURRENT',
      );

      // Default global values are safely populated
      expect(legacyStd.standardId, 'IS 9999');
      expect(legacyStd.jurisdictionId, 'IN');
      expect(legacyStd.country, 'India');
      expect(legacyStd.organizationId, 'bis');
      expect(legacyStd.standardFamily, 'IS');
      expect(legacyStd.lifecycleStatus, StandardLifecycleStatus.current);
      expect(legacyStd.isObsolete, isFalse);
    });

    test('populates and exposes global fields for international standards', () {
      final iec = DemoData.allGlobalStandardsCatalog.firstWhere((s) => s.code.contains('IEC 60076-1'));

      expect(iec.jurisdictionId, 'INT');
      expect(iec.organizationId, 'iec');
      expect(iec.standardFamily, 'IEC');
      expect(iec.lifecycleStatus, StandardLifecycleStatus.current);
      expect(iec.productCategories, contains('Distribution Transformers'));
      expect(iec.technicalDomains, anyElement(contains('Electrotechnology')));
      expect(iec.provenance, isNotNull);
      expect(iec.verificationStatus, 'VERIFIED');
    });
  });

  group('DemoStandardsRepository Global Operations Tests', () {
    const repo = DemoStandardsRepository();

    test('getAllJurisdictions returns full registry', () {
      final list = repo.getAllJurisdictions();
      expect(list.length, greaterThanOrEqualTo(7));
    });

    test('getAllOrganizations returns global bodies', () {
      final list = repo.getAllOrganizations();
      expect(list.length, greaterThanOrEqualTo(9));
    });

    test('searchGlobalStandards filters by jurisdiction', () {
      final usStandards = repo.searchGlobalStandards(jurisdictions: ['US']);
      expect(usStandards.isNotEmpty, isTrue);
      expect(usStandards.every((s) => s.jurisdictionId == 'US'), isTrue);

      final codes = usStandards.map((s) => s.code).toList();
      expect(codes, anyElement(contains('IEEE C57.12.00')));
      expect(codes, anyElement(contains('ASTM D3035')));
      expect(codes, anyElement(contains('ASTM A615')));
    });

    test('searchGlobalStandards filters by family', () {
      final astmStandards = repo.searchGlobalStandards(families: ['ASTM']);
      expect(astmStandards.isNotEmpty, isTrue);
      expect(astmStandards.every((s) => s.standardFamily == 'ASTM'), isTrue);
    });

    test('searchGlobalStandards query works across title, code, and product categories', () {
      final results = repo.searchGlobalStandards(query: 'Transformer');
      expect(results.length, greaterThanOrEqualTo(3));
      final codes = results.map((s) => s.code).toList();
      expect(codes, anyElement(contains('IS 1180 (Part 1)')));
      expect(codes, anyElement(contains('IEC 60076-1')));
      expect(codes, anyElement(contains('IEEE C57.12.00')));
    });
  });
}
