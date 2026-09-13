import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/requirement_ontology.dart';
import 'package:manaksetu/models/specification_gap_analysis.dart';
import 'package:manaksetu/services/gap_analysis_engine.dart';

void main() {
  group('Specification Gap Analysis Engine Tests', () {
    test('Identifies COVERED requirements with authoritative evidence', () {
      final reqs = [
        const ProcurementRequirement(
          id: 'req-eff-1',
          domain: 'electrical',
          product: 'transformer',
          requirementType: RequirementType.performance,
          parameter: 'efficiency',
          op: RequirementOperator.greaterThanOrEqual,
          value: '99',
          unit: '%',
          sourceClause: 'Transformer total losses at 50% and 100% shall meet Star 1 efficiency levels.',
        ),
      ];

      final analysis = GapAnalysisEngine.analyzeSpecificationGaps(
        analysisId: 'test-gap-1',
        tenderTitle: 'Distribution Transformer Tender',
        targetStandardCode: 'IS 1180 (Part 1):2014',
        extractedRequirements: reqs,
      );

      expect(analysis.coveragePercentage, 100.0);
      expect(analysis.coveredCount, 1);
      expect(analysis.missingCount, 0);
      expect(analysis.items.first.status, GapStatus.covered);
      expect(analysis.items.first.evidence, isNotNull);
      expect(analysis.items.first.evidence!.standardCode, 'IS 1180 (Part 1):2014');
    });

    test('Identifies PARTIAL requirements and pinpoints missing test methods', () {
      final reqs = [
        const ProcurementRequirement(
          id: 'req-corr-1',
          domain: 'materials',
          product: 'transformer',
          requirementType: RequirementType.material,
          parameter: 'corrosion resistance',
          op: RequirementOperator.mandatoryConformity,
          value: 'applicable standard',
          sourceClause: 'Tender requires corrosion resistance coating for coastal installation.',
        ),
      ];

      final analysis = GapAnalysisEngine.analyzeSpecificationGaps(
        analysisId: 'test-gap-2',
        tenderTitle: 'Coastal Transformer Substation',
        targetStandardCode: 'IS 1180 (Part 1):2014',
        extractedRequirements: reqs,
      );

      expect(analysis.partialCount, 1);
      expect(analysis.items.first.status, GapStatus.partial);
      expect(analysis.items.first.missingElement, contains('ASTM B117'));
      expect(analysis.items.first.engineeringRecommendation, contains('salt spray'));
    });

    test('Identifies MISSING domain standard for unaddressed seismic requirements', () {
      final reqs = [
        const ProcurementRequirement(
          id: 'req-seismic-1',
          domain: 'civil',
          product: 'transformer',
          requirementType: RequirementType.safety,
          parameter: 'seismic withstand qualification',
          op: RequirementOperator.greaterThanOrEqual,
          value: 'Zone V',
          sourceClause: 'Equipment must withstand Zone V seismic forces as per earthquake design.',
        ),
      ];

      final analysis = GapAnalysisEngine.analyzeSpecificationGaps(
        analysisId: 'test-gap-3',
        tenderTitle: 'Seismic Substation Project',
        targetStandardCode: 'IS 1180 (Part 1):2014',
        extractedRequirements: reqs,
      );

      expect(analysis.missingCount, 1);
      expect(analysis.items.first.status, GapStatus.missing);
      expect(analysis.hasCriticalGaps, isTrue);
      expect(analysis.items.first.missingElement, contains('IEEE 693'));
    });
  });
}
