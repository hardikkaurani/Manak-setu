import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/product_taxonomy.dart';
import 'package:manaksetu/models/requirement_ontology.dart';

void main() {
  group('Product Taxonomy & Technical Synonym Tests', () {
    test('resolves colloquial synonyms to canonical category names', () {
      expect(ProductTaxonomy.resolveCategory('tmt bars'), equals('TMT Steel Rebars'));
      expect(ProductTaxonomy.resolveCategory('rebar'), equals('TMT Steel Rebars'));
      expect(ProductTaxonomy.resolveCategory('hdpe pipe'), equals('HDPE Water Supply Pipes'));
      expect(ProductTaxonomy.resolveCategory('polyethylene piping'), equals('HDPE Water Supply Pipes'));
      expect(ProductTaxonomy.resolveCategory('oil immersed transformer'), equals('Distribution Transformers'));
      expect(ProductTaxonomy.resolveCategory('hv bushing'), equals('High Voltage Bushings'));
    });

    test('expands search query with deterministic technical terms', () {
      final terms = ProductTaxonomy.expandQueryTerms('TMT rebar reinforcement');
      expect(terms, contains('tmt steel rebars'));
      expect(terms, contains('rebar'));
      expect(terms, contains('is 1786'));
      expect(terms, contains('iso 6935-2'));
    });
  });

  group('Requirement Ontology Decomposition Tests', () {
    test('decomposes clause snippet into structured requirements', () {
      const clause = '''
      1. Transformers shall achieve minimum energy efficiency 98.8% under full load.
      2. High Density Polyethylene pipes shall conform to PE-100 grade with PN 10 rating.
      3. Mandatory BIS Scheme-I certification under QCO is required.
      ''';

      final requirements = RequirementOntologyParser.parseClauseSnippet(
        domain: 'Electrotechnical & Civil',
        product: 'Industrial Equipment',
        clauseText: clause,
      );

      expect(requirements.length, greaterThanOrEqualTo(3));

      final effReq = requirements.firstWhere((r) => r.parameter == 'Energy Efficiency');
      expect(effReq.op, RequirementOperator.greaterThanOrEqual);
      expect(effReq.value, '98.8');
      expect(effReq.unit, '%');
      expect(effReq.evaluateNumericThreshold(99.0), isTrue);
      expect(effReq.evaluateNumericThreshold(97.5), isFalse);

      final matReq = requirements.firstWhere((r) => r.parameter == 'Material Grade');
      expect(matReq.value, 'PE-100');

      final qcoReq = requirements.firstWhere((r) => r.parameter == 'Statutory Certification');
      expect(qcoReq.isMandatory, isTrue);
    });
  });
}
