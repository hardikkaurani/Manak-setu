import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';
import 'package:manaksetu/models/knowledge_state.dart';
import 'package:manaksetu/repositories/standards_repository.dart';
import 'package:manaksetu/widgets/decision_trace_sheet.dart';
import 'package:manaksetu/widgets/why_this_standard_sheet.dart';
import 'package:manaksetu/widgets/amendment_diff_sheet.dart';
import 'package:manaksetu/widgets/standards_comparison_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SIH 2026 Production Hardening — Domain & Data Integrity', () {
    const StandardsRepository repo = DemoStandardsRepository();

    test('Decision Trace: retrieves complete 8-stage audit trail for all canonical presets', () {
      for (final pid in ['pipe', 'transformer', 'steel']) {
        final trace = repo.getDecisionTraceForPreset(pid);
        expect(trace.tenderId.isNotEmpty, isTrue);
        expect(trace.inputClause.isNotEmpty, isTrue);
        expect(trace.extractedRequirements.isNotEmpty, isTrue);
        expect(trace.retrievedCandidates.isNotEmpty, isTrue);
        expect(trace.selectionReason.isNotEmpty, isTrue);
        expect(trace.selectedStandard, isNotNull);
        expect(trace.verificationState, KnowledgeState.verified);
        expect(trace.humanApprovalState, isNotEmpty);
      }
    });

    test('Decision Trace: handles out-of-coverage / unknown preset gracefully', () {
      final trace = repo.getDecisionTraceForPreset('out_of_coverage');
      expect(trace.verificationState, KnowledgeState.outOfCoverage);
      expect(trace.selectedStandard, isNull);
      expect(trace.humanApprovalState, 'MANUAL ACTION REQUIRED');
      expect(trace.selectionReason, contains('coverage'));
      expect(trace.lifecycleState, 'OUT-OF-COVERAGE');
    });

    test('Why This Standard: provides matched criteria and rejected alternatives for IS 1180', () {
      final rationale = repo.getWhyThisStandard('IS 1180 (Part 1):2014');
      expect(rationale.standardCode, 'IS 1180 (Part 1):2014');
      expect(rationale.matchedRequirements.isNotEmpty, isTrue);
      expect(rationale.alternativesConsidered.length, greaterThanOrEqualTo(2));
      expect(rationale.knowledgeState, KnowledgeState.verified);

      // Check rejection reason on superseded alternative
      final supersededAlt = rationale.alternativesConsidered.firstWhere(
        (a) => a.standardCode == 'IS 1180:1989',
      );
      expect(supersededAlt.whyRejected, contains('Superseded'));
      expect(supersededAlt.status, KnowledgeState.conflicting);
    });

    test('Why This Standard: provides fallback for unindexed/unknown standard code', () {
      final rationale = repo.getWhyThisStandard('IS 99999:2099');
      expect(rationale.isEvidenceAvailable, isFalse);
      expect(rationale.verificationSummary, contains('Reason unavailable'));
    });

    test('Amendment Diff: provides verified editions and amendments without fake clause diffs', () {
      final diff = repo.getAmendmentDiff('IS 1180 (Part 1):2014');
      expect(diff.currentEdition, contains('Fifth Revision'));
      expect(diff.previousEdition, contains('Fourth Revision'));
      expect(diff.amendments.length, 4);
      expect(diff.hasClauseDiffData, isFalse);
      expect(diff.diffNotice, contains('Detailed amendment diff unavailable'));
    });

    test('Knowledge States: badge presents distinct institutional labels and colors', () {
      expect(KnowledgeState.verified.label, 'VERIFIED');
      expect(KnowledgeState.inferred.label, 'INFERRED');
      expect(KnowledgeState.unknown.label, 'UNKNOWN');
      expect(KnowledgeState.conflicting.label, 'CONFLICTING');
      expect(KnowledgeState.outOfCoverage.label, 'OUT-OF-COVERAGE');
    });
  });

  group('SIH 2026 Production Hardening — Widget & Modal Interaction', () {
    testWidgets('DecisionTraceSheet renders 8 stages correctly', (tester) async {
      const StandardsRepository repo = DemoStandardsRepository();
      final trace = repo.getDecisionTraceForPreset('transformer');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DecisionTraceSheet(trace: trace),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STATUTORY AUDIT & REASONING CHAIN'), findsOneWidget);
      expect(find.text('TENDER SPECIFICATION CLAUSE'), findsOneWidget);
      expect(find.text('EXTRACTED TECHNICAL REQUIREMENTS'), findsOneWidget);
      expect(find.text('RETRIEVED CANDIDATES & RANKING SIGNALS'), findsOneWidget);
      expect(find.text('SELECTION & EXCLUSION JUSTIFICATION'), findsOneWidget);
      expect(find.text('STANDARD LIFECYCLE & GAZETTE STATE'), findsOneWidget);
      expect(find.text('AUTHORITATIVE BIS EVIDENCE & CITATIONS'), findsOneWidget);
      expect(find.text('STATUTORY VERIFICATION STATE'), findsOneWidget);
      expect(find.text('FINAL RECOMMENDATION & HUMAN APPROVAL GATE'), findsOneWidget);
    });

    testWidgets('WhyThisStandardSheet renders matched requirements and alternatives', (tester) async {
      const StandardsRepository repo = DemoStandardsRepository();
      final rationale = repo.getWhyThisStandard('IS 4984:2016');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhyThisStandardSheet(data: rationale),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TECHNICAL SELECTION RATIONALE'), findsOneWidget);
      expect(find.text('MATCHED SPECIFICATION REQUIREMENTS'), findsOneWidget);
      expect(find.text('ALTERNATIVES CONSIDERED & EXCLUSION REASONS'), findsOneWidget);
      expect(find.text('IS 4984:1995'), findsOneWidget);
      expect(find.text('ASTM D3035'), findsOneWidget);
    });

    testWidgets('StandardsComparisonSheet renders side-by-side technical matrix', (tester) async {
      const StandardsRepository repo = DemoStandardsRepository();
      final std1 = repo.getStandardByCode('IS 1180 (Part 1):2014')!;
      final std2 = repo.getStandardByCode('IS 4984:2016')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StandardsComparisonSheet(standards: [std1, std2]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STANDARDS COMPARATIVE ANALYSIS'), findsOneWidget);
      expect(find.text('Comparing 2 Standards'), findsOneWidget);
      expect(find.text('IS 1180 (Part 1):2014'), findsWidgets);
      expect(find.text('IS 4984:2016'), findsWidgets);
      expect(find.text('QCO STATUS'), findsOneWidget);
      expect(find.text('DIVISION'), findsOneWidget);
    });

    testWidgets('AmendmentDiffSheet renders supersession transition without faking diffs', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const StandardsRepository repo = DemoStandardsRepository();
      final diff = repo.getAmendmentDiff('IS 1786:2008');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmendmentDiffSheet(diff: diff),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EDITION & AMENDMENT HISTORY'), findsOneWidget);
      expect(find.text('LIFECYCLE TRANSITION'), findsOneWidget);
      expect(find.text('GAZETTED AMENDMENTS (2)'), findsOneWidget);
      expect(find.textContaining('Detailed amendment diff unavailable in current dataset', skipOffstage: false), findsOneWidget);
    });
  });

  group('SIH 2026 Production Hardening — Full App Scrutiny & Failure Hardening', () {
    testWidgets('Tender Scrutiny: Decision Trace launches from Audit Scorecard', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ManakSetuApp(initialLocation: '/tender-scrutiny'));
      await tester.pumpAndSettle();

      // Run compliance check on default Substation Transformer preset
      final checkBtn = find.text('CHECK TENDER COMPLIANCE');
      expect(checkBtn, findsOneWidget);
      await tester.ensureVisible(checkBtn);
      await tester.tap(checkBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify AuditScorecard is rendered with VIEW AUDIT DECISION TRACE & EVIDENCE CHAIN button
      final traceBtn = find.text('VIEW AUDIT DECISION TRACE & EVIDENCE CHAIN');
      expect(traceBtn, findsOneWidget);
      await tester.ensureVisible(traceBtn);
      await tester.tap(traceBtn);
      await tester.pumpAndSettle();

      // Verify Decision Trace Modal is displayed
      expect(find.text('STATUTORY AUDIT & REASONING CHAIN'), findsOneWidget);
      expect(find.text('TENDER SPECIFICATION CLAUSE'), findsOneWidget);

      // Close modal
      final closeBtn = find.byIcon(Icons.close);
      await tester.tap(closeBtn.first);
      await tester.pumpAndSettle();

      // Verify WHY THIS STANDARD button exists in Detected Standards section
      final whyStdBtn = find.text('WHY THIS STANDARD?');
      expect(whyStdBtn, findsWidgets);
      await tester.ensureVisible(whyStdBtn.first);
      await tester.tap(whyStdBtn.first);
      await tester.pumpAndSettle();

      expect(find.text('TECHNICAL SELECTION RATIONALE'), findsOneWidget);
    });

    testWidgets('Tender Scrutiny: Failure Mode 1 (empty clause) triggers validation warning', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ManakSetuApp(initialLocation: '/tender-scrutiny'));
      await tester.pumpAndSettle();

      // Clear the technical clause text field (index 2: category is 0, department is 1, clause is 2)
      final textField = find.byType(TextField).at(2);
      await tester.ensureVisible(textField);
      await tester.enterText(textField, '');
      await tester.pumpAndSettle();

      // Tap Check Tender Compliance
      final checkBtn = find.text('CHECK TENDER COMPLIANCE');
      await tester.ensureVisible(checkBtn);
      await tester.tap(checkBtn);
      await tester.pumpAndSettle();

      // Verify SnackBar warning
      expect(find.text('Specification clause cannot be empty. Enter clause text or select a preset.'), findsOneWidget);
    });

    testWidgets('Standards Explorer: Comparison workflow allows selecting and comparing 2 standards', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ManakSetuApp(initialLocation: '/standards'));
      await tester.pumpAndSettle();

      // Locate COMPARE buttons on cards
      final compareButtons = find.text('COMPARE');
      expect(compareButtons, findsWidgets);

      // Select first standard
      await tester.tap(compareButtons.at(0));
      await tester.pumpAndSettle();

      // Select second standard
      await tester.tap(compareButtons.at(1));
      await tester.pumpAndSettle();

      // Bottom dock should appear with "2/3 SELECTED" and "COMPARE" action
      expect(find.text('2/3 SELECTED'), findsOneWidget);
      final dockCompareBtn = find.widgetWithText(ElevatedButton, 'COMPARE');
      expect(dockCompareBtn, findsOneWidget);

      // Tap compare in dock
      await tester.tap(dockCompareBtn);
      await tester.pumpAndSettle();

      // Verify comparison sheet opened
      expect(find.text('STANDARDS COMPARATIVE ANALYSIS'), findsOneWidget);
      expect(find.text('Comparing 2 Standards'), findsOneWidget);
    });
  });
}
