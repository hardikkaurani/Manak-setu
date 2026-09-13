import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/services/cross_jurisdiction_engine.dart';

void main() {
  group('Cross-Jurisdiction Comparison Engine Tests', () {
    test('Builds multi-jurisdiction comparison matrix for Distribution Transformers', () {
      final matrix = CrossJurisdictionEngine.buildComparisonMatrix(productId: 'transformer');

      expect(matrix.productId, 'transformer');
      expect(matrix.comparedJurisdictions, containsAll(['IN', 'INT', 'US', 'EU', 'GB']));
      expect(matrix.rows.isNotEmpty, isTrue);

      final ambientRow = matrix.rows.firstWhere((r) => r.parameterName.contains('Ambient'));
      expect(ambientRow.isHarmonized, isFalse);
      expect(ambientRow.jurisdictionValues.containsKey('IN'), isTrue);
      expect(ambientRow.jurisdictionValues['IN']!.standardCode, contains('IS 1180'));
      expect(ambientRow.jurisdictionValues['IN']!.requirementSpecification, contains('50°C'));

      expect(ambientRow.jurisdictionValues.containsKey('INT'), isTrue);
      expect(ambientRow.jurisdictionValues['INT']!.standardCode, contains('IEC 60076-1'));
      expect(ambientRow.jurisdictionValues['INT']!.requirementSpecification, contains('40°C'));

      expect(ambientRow.jurisdictionValues['IN']!.evidence, isNotNull);
      expect(ambientRow.jurisdictionValues['INT']!.evidence, isNotNull);
    });

    test('Builds multi-jurisdiction matrix for HDPE Pipes and identifies harmonized MRS', () {
      final matrix = CrossJurisdictionEngine.buildComparisonMatrix(productId: 'pipe');

      expect(matrix.productId, 'pipe');
      expect(matrix.comparedJurisdictions, containsAll(['IN', 'INT', 'US', 'EU']));

      final mrsRow = matrix.rows.first;
      expect(mrsRow.isHarmonized, isTrue);
      expect(mrsRow.jurisdictionValues['IN']!.standardCode, contains('IS 4984'));
      expect(mrsRow.jurisdictionValues['INT']!.standardCode, contains('ISO 4427-1'));
      expect(mrsRow.jurisdictionValues['US']!.standardCode, contains('ASTM D3035'));
    });

    test('Builds multi-jurisdiction matrix for TMT Steel Rebars with ductility ratios', () {
      final matrix = CrossJurisdictionEngine.buildComparisonMatrix(productId: 'steel');

      expect(matrix.productId, 'steel');
      final yieldRow = matrix.rows.first;
      expect(yieldRow.jurisdictionValues['IN']!.requirementSpecification, contains('Fe 500D'));
      expect(yieldRow.jurisdictionValues['US']!.standardCode, contains('ASTM A706'));
      expect(yieldRow.jurisdictionValues['US']!.requirementSpecification, contains('Grade 60'));
    });
  });
}
