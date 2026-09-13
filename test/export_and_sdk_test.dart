import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/multi_factor_confidence.dart';
import 'package:manaksetu/models/specification_gap_analysis.dart';
import 'package:manaksetu/services/export_service.dart';
import 'package:manaksetu/services/manaksetu_client_sdk.dart';
import 'package:manaksetu/services/unified_analysis_workspace.dart';

void main() {
  group('Export Service, Client SDK & Unified Workspace Tests', () {
    test('ExportService generates valid JSON, CSV and Executive Summary', () {
      final gapItem = GapAnalysisItem(
        id: 'gap-1',
        parameterName: 'Total Losses',
        tenderRequirement: 'Must meet BEE Star 1',
        standardRequirement: 'Max loss values as per Table 6',
        standardCode: 'IS 1180 (Part 1):2014',
        status: GapStatus.covered,
        engineeringRecommendation: 'Verified against Table 6',
      );

      final gap = SpecificationGapAnalysis(
        analysisId: 'ana-test-1',
        tenderTitle: 'Distribution Transformer Tender',
        targetStandardCode: 'IS 1180 (Part 1):2014',
        items: [gapItem],
        coveragePercentage: 100.0,
        coveredCount: 1,
        partialCount: 0,
        missingCount: 0,
        conflictingCount: 0,
        evaluatedAt: DateTime.now(),
      );

      final confidence = MultiFactorConfidence.evaluate(
        retrievalScore: 0.95,
        technicalScore: 0.90,
        lifecycleScore: 0.95,
        evidenceScore: 0.95,
      );

      final pkg = ExportService.buildExportPackage(
        reportId: 'REP-001',
        title: 'Distribution Transformer Tender Scrutiny',
        organizationName: 'Municipal Water Supply Directorate',
        department: 'Electrical Division',
        executiveSummary: 'Full statutory compliance confirmed.',
        inputRequirements: ['Must meet BEE Star 1 efficiency levels.'],
        recommendedStandards: [
          {
            'code': 'IS 1180 (Part 1):2014',
            'title': 'Outdoor Distribution Transformers',
            'status': 'CURRENT',
            'evidence': 'IS 1180-1:2014 Clause 6.8 Table 6',
          }
        ],
        gapAnalysis: gap,
        decisionTraceSummary: {'selection_reason': 'Product & parameter match'},
        confidence: confidence,
        humanReviewSignoff: {
          'status': 'Accepted / Approved',
          'officer_name': 'Superintending Engineer',
          'officer_id': 'SE-4421',
          'comment': 'Approved for tender release',
        },
      );

      // JSON format test
      final jsonStr = ExportService.exportJson(pkg);
      expect(jsonStr, contains('REP-001'));
      expect(jsonStr, contains('Municipal Water Supply Directorate'));
      expect(jsonStr, contains('IS 1180 (Part 1):2014'));

      // CSV format test
      final csvStr = ExportService.exportCsv(pkg);
      expect(csvStr, contains('Parameter,Requirement,Standard Code'));
      expect(csvStr, contains('Total Losses'));
      expect(csvStr, contains('COVERED'));

      // Text dossier test
      final summaryText = ExportService.exportExecutiveSummaryText(pkg);
      expect(summaryText, contains('MANAKSETU STANDARDS INTELLIGENCE & COMPLIANCE DOSSIER'));
      expect(summaryText, contains('OVERALL DECISION STATE: VERIFIED'));
      expect(summaryText, contains('Superintending Engineer'));
    });

    test('ManakSetuClient executes programmatic analysis, search and CLI commands', () async {
      final client = ManakSetuClient();

      // Programmatic analysis
      final recs = await client.analyze('HDPE water supply pipeline 110mm PN 10');
      expect(recs.isNotEmpty, isTrue);
      expect(recs.first.standard.code, contains('IS 4984'));

      // Global catalog search
      final searchResults = await client.searchStandards('transformer', jurisdiction: 'IN');
      expect(searchResults.isNotEmpty, isTrue);
      expect(searchResults.first.code, contains('IS 1180'));

      // Cross-jurisdiction comparison
      final comparison = await client.compareStandards('pipe');
      expect(comparison.productId, 'pipe');
      expect(comparison.rows.isNotEmpty, isTrue);

      // CLI command execution
      final cliResult = await client.executeCliCommand(['analyze', 'Distribution', 'Transformers']);
      expect(cliResult['status'], 'success');
      expect(cliResult['command'], 'analyze');

      final cliCompare = await client.executeCliCommand(['compare', 'transformer']);
      expect(cliCompare['status'], 'success');
      expect(cliCompare['command'], 'compare');
    });

    test('UnifiedAnalysisWorkspace executes 9-step pipeline and returns complete outcome', () async {
      const tenderText =
          'Distribution Transformer shall be 500 kVA rating with copper windings. Total losses at 50% and 100% shall not exceed BEE Star 1 efficiency levels. Material must withstand tropical ambient conditions.';

      final outcome = await UnifiedAnalysisWorkspace.executePipeline(
        inputMode: AnalysisInputMode.tenderClause,
        rawInput: tenderText,
        targetJurisdiction: 'IN',
        productCategory: 'Distribution Transformers',
      );

      expect(outcome.analysisId, startsWith('UAW-'));
      expect(outcome.inputMode, AnalysisInputMode.tenderClause);
      expect(outcome.extractedRequirements.isNotEmpty, isTrue);
      expect(outcome.recommendations.isNotEmpty, isTrue);
      expect(outcome.recommendations.first.standard.code, contains('IS 1180'));
      expect(outcome.gapAnalysis, isNotNull);
      expect(outcome.decisionTrace, isNotNull);
      expect(outcome.confidence.compositeScore, greaterThan(0.5));
      expect(outcome.exportPackage.recommendedStandards.isNotEmpty, isTrue);
    });
  });
}
