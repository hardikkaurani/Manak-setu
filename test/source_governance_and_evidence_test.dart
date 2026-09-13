import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/evidence.dart';

void main() {
  group('Source Governance & Evidence Model Tests', () {
    test('SourceTier correctly classifies authoritative vs unverified tiers', () {
      expect(SourceTier.tier1Authoritative.isAuthoritative, isTrue);
      expect(SourceTier.tier2OfficialMirror.isAuthoritative, isTrue);
      expect(SourceTier.tier3ReputableSecondary.isAuthoritative, isFalse);
      expect(SourceTier.tier4UnverifiedWeb.isAuthoritative, isFalse);

      expect(SourceTier.tier1Authoritative.trustWeight, equals(1.0));
      expect(SourceTier.tier4UnverifiedWeb.trustWeight, lessThan(0.5));
    });

    test('instantiates valid Evidence with cryptographic hash', () {
      final evidence = Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        clause: 'Foreword Cl. 0.3',
        page: '1',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt: 'IS 1180:1989 stands superseded by IS 1180 (Part 1):2014.',
        sourceTier: SourceTier.tier1Authoritative,
        sourceOrganization: 'Bureau of Indian Standards',
      );

      expect(evidence.isAvailable, isTrue);
      expect(evidence.sourceTier, SourceTier.tier1Authoritative);
      expect(evidence.citation, contains('IS 1180 (Part 1):2014'));
      expect(evidence.citation, contains('Clause Foreword Cl. 0.3'));
      expect(evidence.citation, contains('Page 1'));
    });

    test('Evidence.unavailable returns EVIDENCE_UNAVAILABLE without hallucinating citations', () {
      final unavailable = Evidence.unavailable(
        standardCode: 'JIS G 3101',
        clause: '4.1',
        reason: 'Japanese standard text not indexed in licensed store.',
      );

      expect(unavailable.isAvailable, isFalse);
      expect(unavailable.verificationStatus, 'EVIDENCE_UNAVAILABLE');
      expect(unavailable.textExcerpt, contains('EVIDENCE_UNAVAILABLE'));
      expect(unavailable.sourceTier, SourceTier.tier4UnverifiedWeb);
      expect(unavailable.citation, contains('EVIDENCE_UNAVAILABLE'));
    });

    test('computeHash produces deterministic SHA-256 hash', () {
      final hash1 = Evidence.computeHash(
        standardCode: 'IS 4984:2016',
        clause: 'Scope',
        excerpt: 'High Density Polyethylene pipes for water supply.',
        sourceFile: 'is4984.pdf',
      );

      final hash2 = Evidence.computeHash(
        standardCode: 'IS 4984:2016',
        clause: 'Scope',
        excerpt: 'High Density Polyethylene pipes for water supply.',
        sourceFile: 'is4984.pdf',
      );

      final hash3 = Evidence.computeHash(
        standardCode: 'IS 4984:2016',
        clause: 'Cl. 5.1',
        excerpt: 'Different excerpt text.',
        sourceFile: 'is4984.pdf',
      );

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
      expect(hash1.length, equals(16));
    });
  });
}
