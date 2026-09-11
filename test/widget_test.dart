import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';

void main() {
  testWidgets(
    'ManakSetu Phase 2 & 3 Complete End-to-End Interactive Demo Test',
    (WidgetTester tester) async {
      // Set standard mobile phone viewport (390 x 844)
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Pump the app
      await tester
          .pumpWidget(const ManakSetuApp(initialLocation: '/tender-scrutiny'));
      await tester.pumpAndSettle();

      // 2. Verify Top Header Branding
      expect(find.text('ManakSetu'), findsOneWidget);
      expect(find.text('STANDARDS INTELLIGENCE'), findsOneWidget);
      expect(find.text('Priya Rao (DES-8842)'), findsOneWidget);

      // 3. Verify Default Selection is Preset 2: Substation Distribution Transformer
      expect(find.text('Distribution Transformers'), findsOneWidget);
      expect(find.text('Municipal Water Supply Directorate'), findsOneWidget);

      // 4. Run Compliance Audit Analysis in Tender Scrutiny
      final checkComplianceBtn = find.text('CHECK TENDER COMPLIANCE');
      expect(checkComplianceBtn, findsOneWidget);
      await tester.ensureVisible(checkComplianceBtn);
      await tester.tap(checkComplianceBtn);

      // Wait for simulated analysis delay
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // 5. Verify Defective Scorecard (5% Non-Compliant, 2 Critical, 3 High-Risk)
      expect(find.text('5%'), findsOneWidget);
      expect(find.text('NON_COMPLIANT'), findsOneWidget);
      expect(find.text('Critical Defects'), findsOneWidget);
      expect(find.text('High-Risk Violations'), findsOneWidget);

      // 6. Tap "BUILD COMPLIANT SPECIFICATION →" to trigger Phase 3 payoff
      final buildSpecBtn = find.text('BUILD COMPLIANT SPECIFICATION →').first;
      await tester.ensureVisible(buildSpecBtn);
      await tester.tap(buildSpecBtn);
      await tester.pumpAndSettle();

      // 7. Verify Navigation to Specification Builder & Header
      expect(find.text('AUTHORING / SPECIFICATION BUILDER'), findsOneWidget);
      expect(find.text('Bid-ready specification workbench'), findsOneWidget);

      // 8. Verify Initial Defective State (5% Non-Compliant) in Builder
      expect(find.text('5%'), findsOneWidget);
      expect(find.text('NON_COMPLIANT'), findsOneWidget);

      // Tap Shortcut: VIEW 100% COMPLIANT SPECIFICATION
      final viewCompliantBtn = find.text('VIEW 100% COMPLIANT SPECIFICATION');
      expect(viewCompliantBtn, findsOneWidget);
      await tester.ensureVisible(viewCompliantBtn);
      await tester.tap(viewCompliantBtn);
      await tester.pumpAndSettle();

      // Verify Dominant 100% COMPLIANT Scorecard
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('COMPLIANT'), findsOneWidget);
      expect(
        find.text('0 Critical Defects • GFR-144 & BIS Ready'),
        findsOneWidget,
      );
      expect(find.text('IS 1180 (Part 1):2014'), findsWidgets);

      // 9. Verify Statutory Checklist Banner
      expect(
        find.text('STATUTORY COMPLIANCE CHECKPOINTS (ALL VERIFIED)'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Mandatory QCO requirement addressed'),
        findsOneWidget,
      );
      expect(
        find.textContaining('100% Manufacturer-neutral specification'),
        findsOneWidget,
      );

      // 10. Verify Clause Workbench (Tab 0) Sections are Present
      expect(find.text('CLAUSE-BY-CLAUSE WORKBENCH'), findsOneWidget);
      expect(find.text('6 statutory sections'), findsOneWidget);
      expect(
        find.text('Product Scope & Operational Requirements'),
        findsOneWidget,
      );
      expect(
        find.text('Applicable Indian Standards (Normative References)'),
        findsOneWidget,
      );

      // 11. Test Section Expansion (Section 3.0: QCO Enforcement)
      final sec3 = find.text(
        'Statutory Quality Control Order (QCO) Enforcement',
      );
      await tester.ensureVisible(sec3);
      await tester.tap(sec3);
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'Distribution Transformers (Quality Control) Order, 2014',
        ),
        findsWidgets,
      );

      // 12. Test View BIS Evidence from Section Card
      final viewEvidenceBtns = find.text('VIEW BIS EVIDENCE');
      expect(viewEvidenceBtns, findsWidgets);
      await tester.ensureVisible(viewEvidenceBtns.first);
      await tester.tap(viewEvidenceBtns.first);
      await tester.pumpAndSettle();

      // Verify Evidence Sheet
      expect(find.text('BIS STATUTORY EVIDENCE'), findsOneWidget);
      expect(find.text('GAZETTED RECORD'), findsOneWidget);
      // Close sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('BIS STATUTORY EVIDENCE'), findsNothing);

      // 13. Test Action Buttons
      // Re-Check Compliance
      final recheckBtn = find.text('RE-CHECK COMPLIANCE SCORE');
      await tester.ensureVisible(recheckBtn);
      await tester.tap(recheckBtn);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Statutory re-check complete'),
        findsOneWidget,
      );
      // Wait for it to dismiss
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Copy for GeM
      final copyBtn = find.text('COPY FOR GeM');
      await tester.ensureVisible(copyBtn);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Copied bid-ready tender specification'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Download PDF
      final pdfBtn = find.text('DOWNLOAD PDF');
      await tester.ensureVisible(pdfBtn);
      await tester.tap(pdfBtn);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Vigilance & GFR-144 Audit Certificate prepared'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 14. Test Tab 1: Redline Diff Tab
      final diffTab = find.text('Redline Diff');
      await tester.ensureVisible(diffTab);
      await tester.tap(diffTab);
      await tester.pumpAndSettle();

      expect(find.text('SIDE-BY-SIDE REDLINE'), findsOneWidget);
      expect(find.text('ORIGINAL CLAUSE (DEFECTIVE)'), findsOneWidget);
      expect(find.text('RECTIFIED CLAUSE (COMPLIANT)'), findsOneWidget);
      expect(find.text('GFR-144 & BIS READY'), findsWidgets);

      // 15. Test Tab 2: Knowledge Graph Tab
      final graphTab = find.text('Knowledge Graph');
      await tester.ensureVisible(graphTab);
      await tester.tap(graphTab);
      await tester.pumpAndSettle();

      expect(find.text('BIS KNOWLEDGE GRAPH'), findsOneWidget);
      expect(find.text('CENTRAL GOVERNING ROOT'), findsOneWidget);
      expect(find.text('Distribution Transformers QCO 2014'), findsOneWidget);
      expect(find.text('IS 335:2018'), findsWidgets);

      // Test Filter Chip in Knowledge Graph
      final qcoFilterChip = find.text('Mandatory QCO (1)');
      await tester.ensureVisible(qcoFilterChip);
      await tester.tap(qcoFilterChip);
      await tester.pumpAndSettle();
      expect(find.text('Distribution Transformers QCO 2014'), findsOneWidget);

      // 16. Test Return Navigation to Tender Scrutiny
      final returnBtn = find.text('← RETURN TO TENDER SCRUTINY');
      await tester.ensureVisible(returnBtn);
      await tester.tap(returnBtn);
      await tester.pumpAndSettle();

      expect(find.text('Scrutiny'), findsWidgets);
      expect(find.text('Distribution Transformers'), findsOneWidget);

      // 17. Test Switch to Tab 2: Clause Image Analyzer
      final imageTab = find.text('3. Clause Image Analyzer');
      await tester.ensureVisible(imageTab);
      await tester.tap(imageTab);
      await tester.pumpAndSettle();

      expect(find.text('CLAUSE IMAGE ANALYZER'), findsOneWidget);
      expect(find.text('Upload Clause Image'), findsOneWidget);
      expect(find.text('CHOOSE AN IMAGE'), findsOneWidget);
      expect(find.text('Sample Clause Image'), findsOneWidget);

      // 18. Test Guard: Analyze Without Image
      final analyzeBtn = find.text('ANALYZE CLAUSE');
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Please select a clause image first.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 19. Test Select Sample Clause Image
      final sampleImgBtn = find.text('Sample Clause Image');
      await tester.ensureVisible(sampleImgBtn);
      await tester.tap(sampleImgBtn);
      await tester.pumpAndSettle();

      expect(find.text('sample_transformer_clause.jpg'), findsOneWidget);
      expect(find.text('CHANGE IMAGE'), findsOneWidget);
      expect(find.text('CLEAR IMAGE'), findsOneWidget);

      // 20. Test Analyze Clause Execution & Extracted Results
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      // Pump initial frame for progress simulation
      await tester.pump(const Duration(milliseconds: 100));
      // Pump through timer sequence to complete analysis
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('EXTRACTED CLAUSE'), findsOneWidget);
      expect(find.text('DETECTED STANDARD'), findsOneWidget);
      expect(find.text('COMPLIANCE FINDING'), findsOneWidget);
      expect(find.textContaining('IS 1180:1989'), findsWidgets);
      expect(find.textContaining('IS 1180 (Part 1):2014'), findsWidgets);
      expect(
        find.textContaining('Cited BIS Standard is Obsolete & Superseded'),
        findsOneWidget,
      );

      // 21. Test BIS Evidence Modal from Image Analyzer
      final viewEvidenceBtn = find.widgetWithText(
        TextButton,
        'VIEW BIS EVIDENCE',
      );
      await tester.ensureVisible(viewEvidenceBtn);
      await tester.tap(viewEvidenceBtn);
      await tester.pumpAndSettle();

      expect(find.text('BIS STATUTORY EVIDENCE'), findsOneWidget);
      expect(find.text('GAZETTED RECORD'), findsOneWidget);
      // Close sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('BIS STATUTORY EVIDENCE'), findsNothing);

      // 22. Test Clear Image Resets Analysis Results
      final clearBtn = find.text('CLEAR IMAGE');
      await tester.ensureVisible(clearBtn);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('EXTRACTED CLAUSE'), findsNothing);
      expect(find.text('DETECTED STANDARD'), findsNothing);
      expect(find.text('Upload Clause Image'), findsOneWidget);

      // 23. Test Navigation to Specification Builder from Image Analyzer
      await tester.ensureVisible(sampleImgBtn);
      await tester.tap(sampleImgBtn);
      await tester.pumpAndSettle();

      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final openSpecBuilderBtn = find.text('OPEN SPECIFICATION BUILDER →');
      await tester.ensureVisible(openSpecBuilderBtn);
      await tester.tap(openSpecBuilderBtn);
      await tester.pumpAndSettle();

      expect(find.text('5%'), findsOneWidget);
      expect(find.text('Primary: IS 1180 (Part 1):2014'), findsOneWidget);

      final finalViewBtn = find.text('VIEW 100% COMPLIANT SPECIFICATION');
      await tester.ensureVisible(finalViewBtn);
      await tester.tap(finalViewBtn);
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    },
  );
}
