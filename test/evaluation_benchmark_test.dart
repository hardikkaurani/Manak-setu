import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/data/demo_data.dart';
import 'package:manaksetu/services/evaluation_benchmark.dart';

void main() {
  group('EvaluationBenchmarkRunner & Empirical Metric Tests', () {
    final catalog = DemoData.allGlobalStandardsCatalog;
    final equivalences = DemoData.internationalEquivalences;

    test('runs ground-truth benchmark and achieves high precision and recall', () {
      final runner = EvaluationBenchmarkRunner(
        catalog: catalog,
        equivalences: equivalences,
      );

      final scorecard = runner.runBenchmark();

      // Print empirical scorecard for verification
      // ignore: avoid_print
      print(scorecard.toString());

      expect(scorecard.totalQueries, greaterThanOrEqualTo(8));
      expect(scorecard.recallAt1, greaterThanOrEqualTo(0.70));
      expect(scorecard.recallAt3, greaterThanOrEqualTo(0.85));
      expect(scorecard.meanReciprocalRank, greaterThanOrEqualTo(0.80));
      expect(scorecard.meanNdcgAt3, greaterThanOrEqualTo(0.80));
      expect(scorecard.evidenceCoverageRate, greaterThanOrEqualTo(0.75));
      expect(scorecard.lifecycleAccuracyRate, greaterThanOrEqualTo(0.90));
    });
  });
}
