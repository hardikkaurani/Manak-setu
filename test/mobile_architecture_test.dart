import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';
import 'package:manaksetu/services/workspace_controller.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    '1. App Launch & Home Command Center Renders Correctly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ManakSetuApp(initialLocation: '/home'));
      await tester.pumpAndSettle();

      // Verify Header and Officer Credentials
      expect(find.text('ManakSetu'), findsOneWidget);
      expect(find.text('STANDARDS INTELLIGENCE'), findsOneWidget);
      expect(find.text('WELCOME, PRIYA RAO'), findsOneWidget);
      expect(find.text('GFR-144 AUDITOR'), findsOneWidget);

      // Verify Active Audit Hero Banner
      expect(find.text('ACTIVE AUDIT IN PROGRESS'), findsOneWidget);
      expect(find.text('RESUME AUDIT WORKBENCH'), findsOneWidget);

      // Verify Quick Action Grid Tiles
      expect(find.text('Analyze Spec'), findsOneWidget);
      expect(find.text('Upload PDF'), findsOneWidget);
      expect(find.text('Audit BoQ Excel'), findsOneWidget);
      expect(find.text('Scan Clause'), findsOneWidget);

      // Verify 5-Tab Navigation Bar in Shell
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Analyze'), findsOneWidget);
      expect(find.text('Standards'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    },
  );

  testWidgets(
    '2. 5-Tab Navigation Shell Transitions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ManakSetuApp(initialLocation: '/home'));
      await tester.pumpAndSettle();

      // Tap Standards Tab
      await tester.tap(find.text('Standards'));
      await tester.pumpAndSettle();
      expect(find.text('Standards & QCO Explorer'), findsOneWidget);
      expect(
        find.text('Search by standard number, keyword, or QCO...'),
        findsOneWidget,
      );

      // Tap Work Tab
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      expect(find.text('Saved Tenders & Analyses'), findsOneWidget);
      expect(find.text('Saved Procurement Tenders'), findsOneWidget);

      // Tap More Tab
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Credentials & Statutory Rules'), findsOneWidget);
      expect(find.text('Procurement Officer Profile'), findsOneWidget);

      // Return to Analyze (Tender Scrutiny)
      await tester.tap(find.text('Analyze'));
      await tester.pumpAndSettle();
      expect(find.text('Tender Scrutiny & Ingestion'), findsOneWidget);
      expect(find.text('WORKSPACE / NEW ANALYSIS'), findsOneWidget);
    },
  );

  testWidgets(
    '3. Scrutiny Results with Structured Intelligence and Evidence Modal',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ManakSetuApp(initialLocation: '/tender-scrutiny'),
      );
      await tester.pumpAndSettle();

      // Trigger Scrutiny Analysis
      final checkBtn = find.text('CHECK TENDER COMPLIANCE');
      await tester.ensureVisible(checkBtn);
      await tester.tap(checkBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify Intelligence Sections Rendered
      expect(find.text('STATUTORY COMPLIANCE INDEX'), findsOneWidget);
      expect(
        find.textContaining('Detected Technical Requirements'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Detected Standards & Statutory Status'),
        findsOneWidget,
      );
      expect(find.text('Standards Lifecycle & Gazette Status'), findsOneWidget);
      expect(
        find.text('Regulatory QCO & Mandatory Certification'),
        findsOneWidget,
      );
      expect(
        find.textContaining('CVC Anti-Tailoring & Vigilance Flags'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Allied & Normative Reference Standards'),
        findsOneWidget,
      );
      expect(find.textContaining('Specification Gap Analysis'), findsOneWidget);
      expect(
        find.textContaining('Recommended Statutory Remedies'),
        findsOneWidget,
      );
      expect(find.text('Human Review & Officer Sign-off'), findsOneWidget);

      // Open BIS Evidence Sheet
      final viewEvidenceBtn = find.text('VIEW BIS EVIDENCE').first;
      await tester.ensureVisible(viewEvidenceBtn);
      await tester.tap(viewEvidenceBtn);
      await tester.pumpAndSettle();

      // Verify Evidence Sheet modal contents
      expect(find.text('BIS STATUTORY EVIDENCE'), findsOneWidget);

      // Close modal using close icon button
      final closeBtn = find.byIcon(Icons.close).first;
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    '4. Parameter Editing, Statutory Conflict Detection & Purchaser Clauses',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ManakSetuApp(
          initialLocation: '/specification-builder?preset=pipe',
        ),
      );
      await tester.pumpAndSettle();

      // Verify Specification Builder Loaded for Pipe Preset
      expect(find.text('Primary: IS 4984:2016'), findsOneWidget);
      expect(find.text('STATUTORY PARAMETER SIMULATION'), findsOneWidget);

      // Verify Parameters Rendered
      expect(find.text('Material Grade'), findsOneWidget);
      expect(find.text('Pressure Rating'), findsOneWidget);

      // Test Controller Conflict Evaluation
      final controller = WorkspaceController();
      controller.updateParameterValue('pipe', 'pipe-mat', 'PE-63');
      await tester.pumpAndSettle();

      // Verify Conflict is Detected and Displayed
      expect(find.text('CONFLICT'), findsWidgets);
      expect(
        find.textContaining('PE-63 material is obsolete'),
        findsWidgets,
      );

      // Rectify Parameter to PE-100
      controller.updateParameterValue('pipe', 'pipe-mat', 'PE-100');
      await tester.pumpAndSettle();
      expect(find.text('VERIFIED'), findsWidgets);

      // Verify Purchaser Clauses Section
      expect(find.text('Purchaser-Defined Requirements (0)'), findsOneWidget);
      expect(find.text('+ ADD PURCHASER REQUIREMENT'), findsOneWidget);

      // Add a custom purchaser clause
      controller.addPurchaserClause(
        title: 'Mandatory 5-Year Comprehensive Defect Liability',
        content:
            'Contractor shall maintain pipeline integrity with 24h response time.',
      );
      await tester.pumpAndSettle();

      expect(find.text('Purchaser-Defined Requirements (1)'), findsOneWidget);
      expect(find.text('PURCHASER-DEFINED'), findsWidgets);
      expect(
        find.text('Mandatory 5-Year Comprehensive Defect Liability'),
        findsOneWidget,
      );
      expect(find.text('Note: Not mandated by BIS standards.'), findsOneWidget);
    },
  );

  testWidgets(
    '5. Standards Explorer Search and Filter',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ManakSetuApp(initialLocation: '/standards'),
      );
      await tester.pumpAndSettle();

      // Search for IS 4984
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, '4984');
      await tester.pumpAndSettle();

      expect(find.text('IS 4984:2016'), findsOneWidget);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Drag horizontal chip filter row to reveal 'CIVIL'
      final chipScrollFinder = find.byType(SingleChildScrollView);
      await tester.drag(chipScrollFinder.first, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Filter Chip 'CIVIL'
      final civilChip = find.text('CIVIL');
      expect(civilChip, findsOneWidget);
      await tester.tap(civilChip);
      await tester.pumpAndSettle();

      expect(find.text('IS 4984:2016'), findsOneWidget);
      expect(find.text('IS 1786:2008'), findsOneWidget);
    },
  );
}
