import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/data/demo_data.dart';
import 'package:manaksetu/models/lifecycle_status.dart';
import 'package:manaksetu/services/retrieval_engine.dart';

void main() {
  group('HybridRetrievalEngine Multi-Factor Technical Re-Ranking Tests', () {
    const engine = HybridRetrievalEngine();
    final catalog = DemoData.allGlobalStandardsCatalog;
    final equivalences = DemoData.internationalEquivalences;

    test('retrieves Indian Standard for India-specific procurement specification', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'Procurement of outdoor oil immersed distribution transformer 25 kVA 11kV 50Hz',
          jurisdictions: ['IN'],
          productCategory: 'Distribution Transformers',
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.isNotEmpty, isTrue);
      final top = results.first;
      expect(top.standard.code, startsWith('IS 1180 (Part 1)'));
      expect(top.standard.jurisdictionId, 'IN');
      expect(top.confidenceScore, greaterThanOrEqualTo(0.80));
      expect(top.whySelected, isNotEmpty);
      expect(top.whySelected, anyElement(contains('Direct technical domain match')));
      expect(top.whySelected, anyElement(contains('Target jurisdiction match (IN)')));

      // Verifies factor breakdown is explainable
      expect(top.explanation.factorScores.containsKey('lexical'), isTrue);
      expect(top.explanation.factorScores.containsKey('technicalDomain'), isTrue);
      expect(top.explanation.factorScores.containsKey('jurisdiction'), isTrue);
      expect(top.explanation.factorScores.containsKey('lifecycle'), isTrue);
    });

    test('retrieves International IEC standard when jurisdiction is set to INT', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'Power and distribution transformers technical requirements specification',
          jurisdictions: ['INT'],
          productCategory: 'Distribution Transformers',
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.isNotEmpty, isTrue);
      final top = results.first;
      expect(top.standard.code, startsWith('IEC 60076-1'));
      expect(top.standard.jurisdictionId, 'INT');
      expect(top.standard.organizationId, 'iec');
    });

    test('retrieves US IEEE / ASTM standard when jurisdiction is set to US', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'Standard General Requirements for Liquid-Immersed Distribution, Power, and Regulating Transformers',
          jurisdictions: ['US'],
          productCategory: 'Distribution Transformers',
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.isNotEmpty, isTrue);
      final top = results.first;
      expect(top.standard.code, startsWith('IEEE C57.12.00'));
      expect(top.standard.jurisdictionId, 'US');
    });

    test('supports multi-jurisdiction query (India + US + EU + International)', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'High Density Polyethylene (HDPE) Pipes for water supply systems PN 10 PE 100',
          jurisdictions: ['IN', 'INT', 'US', 'EU'],
          productCategory: 'HDPE Pipes',
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.length, greaterThanOrEqualTo(3));
      final returnedJurisdictions = results.map((r) => r.standard.jurisdictionId).toSet();

      expect(returnedJurisdictions, contains('IN'));
      expect(returnedJurisdictions, contains('INT'));
      expect(returnedJurisdictions, contains('US'));
      expect(returnedJurisdictions, contains('EU'));
    });

    test('penalizes superseded and obsolete standards in ranking', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'HDPE water supply pipes specification',
          jurisdictions: ['IN'],
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      // Find current IS 4984 vs obsolete IS 4984:1995 if present
      final currentMatch = results.firstWhere((r) => r.standard.code.startsWith('IS 4984'));
      expect(currentMatch.standard.lifecycleStatus, StandardLifecycleStatus.current);
      expect(currentMatch.explanation.factorScores['lifecycle'], equals(1.0));
    });

    test('expands and links international equivalences onto recommendations', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'Thermo-Mechanically Treated (TMT) steel rebars for concrete reinforcement',
          jurisdictions: ['IN'],
          includeEquivalences: true,
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.isNotEmpty, isTrue);
      final is1786Rec = results.firstWhere((r) => r.standard.code.startsWith('IS 1786'));
      expect(is1786Rec.equivalences.isNotEmpty, isTrue);

      final targetCodes = is1786Rec.equivalences.map((e) => e.standardCodeB).toList();
      expect(targetCodes, anyElement(contains('ISO 6935-2')));
      expect(targetCodes, anyElement(contains('ASTM A615')));
      expect(targetCodes, anyElement(contains('BS 4449')));
    });

    test('handles queries with direct standard code mentions with priority boost', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'Specification as per IEC 60076-1 for distribution equipment',
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.standard.code, startsWith('IEC 60076-1'));
      expect(results.first.confidenceScore, greaterThanOrEqualTo(0.95));
    });

    test('filters out completely irrelevant queries cleanly', () {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: 'Astronomy planetary telescope optical lens array specification',
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      expect(results.isEmpty, isTrue);
    });
  });
}
