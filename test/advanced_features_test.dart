import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    'Advanced Feature 1: Standalone Knowledge Graph Screen Navigation, Standard Switching & Node Inspection',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Launch direct to /graph with transformer preset
      await tester.pumpWidget(
        const ManakSetuApp(initialLocation: '/graph?preset=transformer'),
      );
      await tester.pumpAndSettle();

      // Verify Header & Breadcrumb
      expect(find.text('STANDARDS ONTOLOGY & KNOWLEDGE GRAPH'), findsOneWidget);
      expect(find.text('IS 1180 (Part 1):2014'), findsWidgets);
      expect(find.text('BIS KNOWLEDGE GRAPH'), findsOneWidget);
      expect(find.text('CENTRAL GOVERNING ROOT'), findsOneWidget);

      // Switch Standard to HDPE Pipes via chip (scroll chip into view if needed)
      final pipeChip = find.text('IS 4984:2016');
      expect(pipeChip, findsOneWidget);
      await tester.ensureVisible(pipeChip);
      await tester.pumpAndSettle();
      await tester.tap(pipeChip);
      await tester.pumpAndSettle();

      // Verify pipe standard is now active root
      expect(find.text('IS 4984:2016'), findsWidgets);
      expect(find.text('CENTRAL GOVERNING ROOT'), findsOneWidget);
    },
  );

  testWidgets(
    'Advanced Feature 2: Standards Explorer Dual-Tab & QCO Registry Inspection',
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

      // Verify Dual Tabs are rendered
      expect(find.text('INDIAN STANDARDS'), findsOneWidget);
      expect(find.text('QUALITY CONTROL ORDERS (QCO)'), findsOneWidget);

      // Switch to QCO Registry Tab
      final qcoTab = find.text('QUALITY CONTROL ORDERS (QCO)');
      await tester.tap(qcoTab);
      await tester.pumpAndSettle();

      // Verify Statutory Notice & QCO Records
      expect(
        find.textContaining('QCOs are issued under Section 16 of the BIS Act'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Electrical Transformers (Quality Control) Order, 2024'),
        findsOneWidget,
      );
      expect(find.textContaining('S.O. 458(E)'), findsOneWidget);
      expect(find.text('STATUTORY MANDATE'), findsWidgets);

      // Search inside QCO orders
      final qcoSearchField = find.byType(TextField);
      expect(qcoSearchField, findsOneWidget);
      await tester.enterText(qcoSearchField, 'Pipes');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Pipes and Fittings (Quality Control) Order, 2020'),
        findsOneWidget,
      );
      expect(find.textContaining('S.O. 1289(E)'), findsOneWidget);

      // Switch back to Indian Standards Tab
      final standardsTab = find.text('INDIAN STANDARDS');
      await tester.tap(standardsTab);
      await tester.pumpAndSettle();
      expect(find.text('IS 1180 (Part 1):2014'), findsWidgets);
    },
  );

  testWidgets(
    'Advanced Feature 3: Tender Scrutiny BoQ Filtering by FAIL/WARN/PASS Status',
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

      // Switch to Document Upload Tab (Tab index 1)
      final uploadTab = find.text('2. Upload Document (PDF / BoQ)');
      await tester.ensureVisible(uploadTab);
      await tester.tap(uploadTab);
      await tester.pumpAndSettle();

      // Select BoQ Excel sample file
      final boqSampleBtn = find.text('BoQ Excel');
      await tester.ensureVisible(boqSampleBtn);
      await tester.tap(boqSampleBtn);
      await tester.pumpAndSettle();

      // Tap 'ANALYZE DOCUMENT'
      final analyzeBtn = find.text('ANALYZE DOCUMENT');
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      // Wait for progress animation and state delay
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify BoQ Audit Card loaded with 5 items
      expect(find.textContaining('BoQ Statutory Audit:'), findsOneWidget);
      expect(find.text('AUDITED BOQ LINE ITEMS (5)'), findsOneWidget);

      // Tap 'FAIL (2)' filter chip via Key
      final failChip = find.byKey(const Key('boq_filter_FAIL'));
      expect(failChip, findsOneWidget);
      await tester.ensureVisible(failChip);
      await tester.tap(failChip);
      await tester.pumpAndSettle();

      // Verify only 2 line items are shown
      expect(find.text('AUDITED BOQ LINE ITEMS (2)'), findsOneWidget);
      expect(find.text('Filter: FAIL'), findsOneWidget);

      // Tap 'PASS (2)' filter chip via Key
      final passChip = find.byKey(const Key('boq_filter_PASS'));
      expect(passChip, findsOneWidget);
      await tester.ensureVisible(passChip);
      await tester.tap(passChip);
      await tester.pumpAndSettle();

      expect(find.text('AUDITED BOQ LINE ITEMS (2)'), findsOneWidget);
      expect(find.text('Filter: PASS'), findsOneWidget);

      // Tap 'ALL (5)' filter chip via Key to restore
      final allChip = find.byKey(const Key('boq_filter_ALL'));
      expect(allChip, findsOneWidget);
      await tester.ensureVisible(allChip);
      await tester.tap(allChip);
      await tester.pumpAndSettle();

      expect(find.text('AUDITED BOQ LINE ITEMS (5)'), findsOneWidget);
    },
  );

  testWidgets(
    'Advanced Feature 4: Clause Image Acquisition, Preview & Honest Demo Analysis',
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

      // Switch to Image Clause Analyzer Tab (Tab index 2)
      final imageTab = find.text('3. Clause Image Analyzer');
      await tester.ensureVisible(imageTab);
      await tester.tap(imageTab);
      await tester.pumpAndSettle();

      expect(find.text('CLAUSE IMAGE ANALYZER'), findsOneWidget);
      expect(find.text('TAKE PHOTO'), findsOneWidget);
      expect(find.text('CHOOSE AN IMAGE'), findsOneWidget);

      // Tap sample clause button ('Sample Clause Image')
      final sampleBtn = find.text('Sample Clause Image');
      await tester.ensureVisible(sampleBtn);
      await tester.tap(sampleBtn);
      await tester.pumpAndSettle();

      // Verify preview card appears
      expect(find.text('sample_transformer_clause.jpg'), findsOneWidget);
      expect(find.text('CHANGE IMAGE'), findsOneWidget);
      expect(find.text('ANALYZE CLAUSE'), findsOneWidget);

      // Tap Analyze Clause
      final analyzeClauseBtn = find.text('ANALYZE CLAUSE');
      await tester.ensureVisible(analyzeClauseBtn);
      await tester.tap(analyzeClauseBtn);
      // Wait for timer intervals in simulation
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Verify Extraction Results and honest demo labeling
      expect(find.text('EXTRACTED CLAUSE'), findsOneWidget);
      expect(find.text('DETECTED STANDARD'), findsOneWidget);
      expect(find.text('IS 1180:1989'), findsWidgets);
      expect(find.text('IS 1180 (Part 1):2014'), findsWidgets);
      expect(find.text('COMPLIANCE FINDING'), findsOneWidget);
    },
  );
}
