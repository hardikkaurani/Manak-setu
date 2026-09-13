import 'dart:math';
import '../models/standard.dart';
import '../models/international_equivalence.dart';
import 'retrieval_engine.dart';

/// A ground-truth benchmark test case for measuring retrieval and intelligence quality.
class BenchmarkTestCase {
  final String id;
  final String specificationText;
  final List<String> targetJurisdictions;
  final String productCategory;
  final List<String> expectedRelevantCodes;

  const BenchmarkTestCase({
    required this.id,
    required this.specificationText,
    required this.targetJurisdictions,
    required this.productCategory,
    required this.expectedRelevantCodes,
  });
}

/// Comprehensive retrieval performance and intelligence accuracy scorecard.
class BenchmarkScorecard {
  final int totalQueries;
  final double recallAt1;
  final double recallAt3;
  final double recallAt5;
  final double precisionAt1;
  final double precisionAt3;
  final double meanReciprocalRank;
  final double meanNdcgAt3;
  final double evidenceCoverageRate;
  final double lifecycleAccuracyRate;

  const BenchmarkScorecard({
    required this.totalQueries,
    required this.recallAt1,
    required this.recallAt3,
    required this.recallAt5,
    required this.precisionAt1,
    required this.precisionAt3,
    required this.meanReciprocalRank,
    required this.meanNdcgAt3,
    required this.evidenceCoverageRate,
    required this.lifecycleAccuracyRate,
  });

  @override
  String toString() {
    return '''
========================================
MANAKSETU RETRIEVAL BENCHMARK SCORECARD
========================================
Total Queries Tested    : $totalQueries
Recall@1                : ${(recallAt1 * 100).toStringAsFixed(1)}%
Recall@3                : ${(recallAt3 * 100).toStringAsFixed(1)}%
Recall@5                : ${(recallAt5 * 100).toStringAsFixed(1)}%
Precision@1             : ${(precisionAt1 * 100).toStringAsFixed(1)}%
Precision@3             : ${(precisionAt3 * 100).toStringAsFixed(1)}%
Mean Reciprocal Rank    : ${meanReciprocalRank.toStringAsFixed(3)}
nDCG@3                  : ${meanNdcgAt3.toStringAsFixed(3)}
Evidence Coverage Rate  : ${(evidenceCoverageRate * 100).toStringAsFixed(1)}%
Lifecycle Accuracy Rate : ${(lifecycleAccuracyRate * 100).toStringAsFixed(1)}%
========================================''';
  }
}

/// Ground-truth evaluation benchmark runner executing empirical quality measurements.
class EvaluationBenchmarkRunner {
  final HybridRetrievalEngine engine;
  final List<Standard> catalog;
  final List<InternationalEquivalence> equivalences;

  const EvaluationBenchmarkRunner({
    this.engine = const HybridRetrievalEngine(),
    required this.catalog,
    this.equivalences = const [],
  });

  /// Canonical benchmark evaluation dataset with real procurement test cases.
  static const List<BenchmarkTestCase> canonicalBenchmarkCases = [
    BenchmarkTestCase(
      id: 'tc-trans-india',
      specificationText: 'Supply of 500 kVA outdoor oil-immersed distribution transformer 11 kV / 433 V 50 Hz',
      targetJurisdictions: ['IN'],
      productCategory: 'Distribution Transformers',
      expectedRelevantCodes: ['IS 1180 (Part 1):2014', 'IS 2026 (Part 1):2011'],
    ),
    BenchmarkTestCase(
      id: 'tc-trans-iec',
      specificationText: 'Power and distribution transformers technical requirements cooling classes',
      targetJurisdictions: ['INT'],
      productCategory: 'Distribution Transformers',
      expectedRelevantCodes: ['IEC 60076-1:2011'],
    ),
    BenchmarkTestCase(
      id: 'tc-trans-us',
      specificationText: 'Liquid-immersed distribution and power transformers utility distribution',
      targetJurisdictions: ['US'],
      productCategory: 'Distribution Transformers',
      expectedRelevantCodes: ['IEEE C57.12.00-2021'],
    ),
    BenchmarkTestCase(
      id: 'tc-pipes-india',
      specificationText: 'High density polyethylene HDPE water supply pipes PN 10 PE-100 grade 110 mm',
      targetJurisdictions: ['IN'],
      productCategory: 'HDPE Pipes',
      expectedRelevantCodes: ['IS 4984:2016'],
    ),
    BenchmarkTestCase(
      id: 'tc-pipes-iso',
      specificationText: 'Polyethylene pipes for water supply systems nominal pressure PN 10',
      targetJurisdictions: ['INT'],
      productCategory: 'HDPE Pipes',
      expectedRelevantCodes: ['ISO 4427-1:2019'],
    ),
    BenchmarkTestCase(
      id: 'tc-pipes-astm',
      specificationText: 'Polyethylene PE plastic pipe DR-PR based on outside diameter water supply',
      targetJurisdictions: ['US'],
      productCategory: 'HDPE Pipes',
      expectedRelevantCodes: ['ASTM D3035-21'],
    ),
    BenchmarkTestCase(
      id: 'tc-rebar-india',
      specificationText: 'High strength deformed steel bars Fe 500D for concrete reinforcement seismic',
      targetJurisdictions: ['IN'],
      productCategory: 'Reinforcement Steel',
      expectedRelevantCodes: ['IS 1786:2008'],
    ),
    BenchmarkTestCase(
      id: 'tc-rebar-iso',
      specificationText: 'Steel for the reinforcement of concrete ribbed bars Grade B500',
      targetJurisdictions: ['INT'],
      productCategory: 'Reinforcement Steel',
      expectedRelevantCodes: ['ISO 6935-2:2019'],
    ),
    BenchmarkTestCase(
      id: 'tc-security-iso',
      specificationText: 'Information security management systems cybersecurity ISMS audit requirements',
      targetJurisdictions: ['INT'],
      productCategory: 'Cybersecurity',
      expectedRelevantCodes: ['ISO/IEC 27001:2022'],
    ),
  ];

  /// Runs the full benchmark suite and computes exact empirical metrics.
  BenchmarkScorecard runBenchmark({List<BenchmarkTestCase>? testCases}) {
    final suite = testCases ?? canonicalBenchmarkCases;
    if (suite.isEmpty) {
      return const BenchmarkScorecard(
        totalQueries: 0,
        recallAt1: 0,
        recallAt3: 0,
        recallAt5: 0,
        precisionAt1: 0,
        precisionAt3: 0,
        meanReciprocalRank: 0,
        meanNdcgAt3: 0,
        evidenceCoverageRate: 0,
        lifecycleAccuracyRate: 0,
      );
    }

    double sumRecall1 = 0;
    double sumRecall3 = 0;
    double sumRecall5 = 0;
    double sumPrec1 = 0;
    double sumPrec3 = 0;
    double sumMrr = 0;
    double sumNdcg3 = 0;
    int totalEvidenceCovered = 0;
    int totalLifecycleAccurate = 0;
    int totalRecommendationsEvaluated = 0;

    for (final testCase in suite) {
      final results = engine.retrieve(
        query: RetrievalQuery.from(
          rawText: testCase.specificationText,
          jurisdictions: testCase.targetJurisdictions,
          productCategory: testCase.productCategory,
        ),
        catalog: catalog,
        equivalences: equivalences,
      );

      final returnedCodes = results.map((r) => r.standard.code).toList();
      final expected = testCase.expectedRelevantCodes;

      // Recall@1, Recall@3, Recall@5
      final r1 = returnedCodes.take(1).where((c) => expected.any((e) => c.contains(e) || e.contains(c))).length;
      final r3 = returnedCodes.take(3).where((c) => expected.any((e) => c.contains(e) || e.contains(c))).length;
      final r5 = returnedCodes.take(5).where((c) => expected.any((e) => c.contains(e) || e.contains(c))).length;

      sumRecall1 += (r1 / expected.length).clamp(0.0, 1.0);
      sumRecall3 += (r3 / expected.length).clamp(0.0, 1.0);
      sumRecall5 += (r5 / expected.length).clamp(0.0, 1.0);

      // Precision@1, Precision@3
      sumPrec1 += returnedCodes.isNotEmpty
          ? (r1 / 1.0)
          : 0.0;
      sumPrec3 += returnedCodes.isNotEmpty
          ? (r3 / min(3, returnedCodes.length))
          : 0.0;

      // MRR
      int firstRelevantRank = 0;
      for (int i = 0; i < returnedCodes.length; i++) {
        final c = returnedCodes[i];
        if (expected.any((e) => c.contains(e) || e.contains(c))) {
          firstRelevantRank = i + 1;
          break;
        }
      }
      if (firstRelevantRank > 0) {
        sumMrr += 1.0 / firstRelevantRank;
      }

      // nDCG@3
      double dcg = 0.0;
      double idcg = 0.0;
      for (int i = 0; i < min(3, returnedCodes.length); i++) {
        final isRel = expected.any((e) => returnedCodes[i].contains(e) || e.contains(returnedCodes[i]));
        final rel = isRel ? 1.0 : 0.0;
        dcg += rel / (log(i + 2) / ln2);
      }
      for (int i = 0; i < min(3, expected.length); i++) {
        idcg += 1.0 / (log(i + 2) / ln2);
      }
      sumNdcg3 += idcg > 0 ? (dcg / idcg) : 0.0;

      // Evidence & Lifecycle checking
      for (final rec in results.take(3)) {
        totalRecommendationsEvaluated++;
        final hasEvidence = (rec.standard.evidence != null && rec.standard.evidence!.isAvailable) ||
            rec.explanation.source.isNotEmpty ||
            rec.equivalences.any((e) => e.evidence != null && e.evidence!.isAvailable);
        if (hasEvidence) {
          totalEvidenceCovered++;
        }
        if (!rec.standard.lifecycleStatus.isObsolete || rec.score < 0.8) {
          totalLifecycleAccurate++;
        }
      }
    }

    final n = suite.length.toDouble();
    return BenchmarkScorecard(
      totalQueries: suite.length,
      recallAt1: sumRecall1 / n,
      recallAt3: sumRecall3 / n,
      recallAt5: sumRecall5 / n,
      precisionAt1: sumPrec1 / n,
      precisionAt3: sumPrec3 / n,
      meanReciprocalRank: sumMrr / n,
      meanNdcgAt3: sumNdcg3 / n,
      evidenceCoverageRate: totalRecommendationsEvaluated > 0
          ? totalEvidenceCovered / totalRecommendationsEvaluated
          : 1.0,
      lifecycleAccuracyRate: totalRecommendationsEvaluated > 0
          ? totalLifecycleAccurate / totalRecommendationsEvaluated
          : 1.0,
    );
  }
}
