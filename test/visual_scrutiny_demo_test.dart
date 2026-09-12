import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';
import 'package:manaksetu/models/demo_image_analysis.dart';

void main() {
  group('Phase 5B Multi-Modal Visual Scrutiny Unit Tests', () {
    test('Filename normalization and compliance validation', () {
      // Test 1 & 4: Compliant and case variants
      expect(
        DemoImageAnalysis.isCompliantImage('IMG-2-260912-WA0005.jpg'),
        isTrue,
      );
      expect(
        DemoImageAnalysis.isCompliantImage('IMG-2-260912-WA0005.JPG'),
        isTrue,
      );
      expect(
        DemoImageAnalysis.isCompliantImage('img-2-260912-wa0005.jpg'),
        isTrue,
      );
      expect(
        DemoImageAnalysis.isCompliantImage('  IMG-2-260912-WA0005.jpg  '),
        isTrue,
      );
      expect(
        DemoImageAnalysis.isCompliantImage(
          r'C:\Users\Downloads\IMG-2-260912-WA0005.jpg',
        ),
        isTrue,
      );
      expect(
        DemoImageAnalysis.isCompliantImage(
          '/storage/emulated/0/DCIM/IMG-2-260912-WA0005.JPG',
        ),
        isTrue,
      );

      // Former demo names should NOT be compliant anymore
      expect(DemoImageAnalysis.isCompliantImage('hdpe_water_pipe.jpg'), isFalse);
      expect(DemoImageAnalysis.isCompliantImage('hdpe_water_pipe.jpeg'), isFalse);

      // Test 2 & 3: Mismatch inputs
      expect(DemoImageAnalysis.isCompliantImage('transformer.jpg'), isFalse);
      expect(DemoImageAnalysis.isCompliantImage('random_photo.jpg'), isFalse);
      expect(DemoImageAnalysis.isCompliantImage('tmt_steel.png'), isFalse);
      expect(DemoImageAnalysis.isCompliantImage(''), isFalse);
      expect(DemoImageAnalysis.isCompliantImage(null), isFalse);
    });

    test('Compliant evaluation returns canonical HDPE Water scenario', () {
      final result = DemoImageAnalysis.evaluate('IMG-2-260912-WA0005.jpg');
      expect(result.isCompliant, isTrue);
      expect(result.displayTitle, 'HDPE Water Supply Pipe');
      expect(result.governingStandard, 'IS 4984:2016');
      expect(result.procurementCategory, 'Water Supply / HDPE Pipeline');
      expect(result.status, 'PRODUCT MATCH CONFIRMED');
      expect(result.builderPresetId, 'pipe');
    });

    test('Non-compliant evaluation returns statutory mismatch alert', () {
      final result = DemoImageAnalysis.evaluate(
        'transformer.jpg',
        tenderStandard: 'IS 4984:2016',
      );
      expect(result.isCompliant, isFalse);
      expect(
        result.resultTitle,
        'PRODUCT MISMATCH ALERT: IMAGE INVALID FOR SPECIFIED REQUIREMENT',
      );
      expect(result.status, 'SCRUTINY REJECTED');
      expect(result.governingStandard, 'IS 4984:2016');
      expect(
        result.resultDescription,
        contains('uploaded equipment image does not correspond'),
      );
      expect(
        result.categoryConflict,
        contains('Equipment photo/nameplate does not correspond'),
      );
    });
  });

  group('Phase 5B Multi-Modal Visual Scrutiny Widget Tests', () {
    testWidgets(
      'TEST 1 & 7: Compliant image analysis and specification builder navigation',
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

        // 1. Switch to Tab 2 (Image Analyzer)
        final imageTab = find.text('3. Clause Image Analyzer');
        await tester.ensureVisible(imageTab);
        await tester.tap(imageTab);
        await tester.pumpAndSettle();

        expect(find.text('CLAUSE IMAGE ANALYZER'), findsOneWidget);
        expect(
          find.text('MULTI-MODAL VISUAL GAP MATRIX & PHYSICAL SCRUTINY'),
          findsOneWidget,
        );

        // 2. Select compliant quick-demo chip
        final compliantChip = find.byKey(const Key('demo_chip_compliant'));
        await tester.ensureVisible(compliantChip);
        await tester.tap(compliantChip);
        await tester.pumpAndSettle();

        expect(find.text('IMG-2-260912-WA0005.jpg'), findsOneWidget);

        // 3. Trigger Analysis
        final analyzeBtn = find.byKey(const Key('analyze_visual_button'));
        await tester.ensureVisible(analyzeBtn);
        await tester.tap(analyzeBtn);

        // Progress simulation ticks
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Verify Compliant result UI
        expect(find.text('PHYSICAL SCRUTINY RESULT'), findsOneWidget);
        expect(find.text('COMPLIANT'), findsOneWidget);
        expect(find.text('HDPE WATER SUPPLY PIPE'), findsOneWidget);
        expect(find.text('PRODUCT MATCH CONFIRMED'), findsWidgets);
        expect(find.text('IS 4984:2016'), findsOneWidget);
        expect(find.text('Water Supply / HDPE Pipeline'), findsOneWidget);
        expect(
          find.byKey(const Key('open_spec_builder_button')),
          findsOneWidget,
        );

        // TEST 7: Open Specification Builder navigates to Water preset
        final openSpecBtn = find.byKey(const Key('open_spec_builder_button'));
        await tester.ensureVisible(openSpecBtn);
        await tester.tap(openSpecBtn);
        await tester.pumpAndSettle();

        // Check Water preset in builder
        expect(find.text('Primary: IS 4984:2016'), findsOneWidget);
        expect(find.text('8%'), findsOneWidget);
        expect(find.textContaining('HDPE Water Supply Pipes'), findsWidgets);
      },
    );

    testWidgets(
      'TEST 2: Different image (transformer.jpg) produces PRODUCT MISMATCH ALERT',
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

        // Switch to Tab 2
        final imageTab = find.text('3. Clause Image Analyzer');
        await tester.ensureVisible(imageTab);
        await tester.tap(imageTab);
        await tester.pumpAndSettle();

        // Select mismatch chip (transformer.jpg)
        final mismatchChip = find.byKey(
          const Key('demo_chip_mismatch_transformer'),
        );
        await tester.ensureVisible(mismatchChip);
        await tester.tap(mismatchChip);
        await tester.pumpAndSettle();

        expect(find.text('transformer.jpg'), findsOneWidget);

        // Analyze
        final analyzeBtn = find.byKey(const Key('analyze_visual_button'));
        await tester.ensureVisible(analyzeBtn);
        await tester.tap(analyzeBtn);

        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Verify Red Mismatch Alert
        expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
        expect(
          find.text('IMAGE INVALID FOR SPECIFIED REQUIREMENT'),
          findsOneWidget,
        );
        expect(find.text('PRODUCT MISMATCH DETECTED:'), findsOneWidget);
        expect(find.text('CATEGORY CONFLICT:'), findsOneWidget);
        expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
        expect(find.text('COMPLIANT'), findsNothing);
      },
    );

    testWidgets(
      'TEST 3 & 4: Arbitrary image mismatch and uppercase normalization test',
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

        // Switch to Tab 2
        final imageTab = find.text('3. Clause Image Analyzer');
        await tester.ensureVisible(imageTab);
        await tester.tap(imageTab);
        await tester.pumpAndSettle();

        // Select arbitrary mismatch chip (random_equipment.jpg)
        final randomChip = find.byKey(
          const Key('demo_chip_mismatch_random'),
        );
        await tester.ensureVisible(randomChip);
        await tester.tap(randomChip);
        await tester.pumpAndSettle();

        // Analyze
        final analyzeBtn = find.byKey(const Key('analyze_visual_button'));
        await tester.ensureVisible(analyzeBtn);
        await tester.tap(analyzeBtn);

        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
        expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
        expect(find.text('COMPLIANT'), findsNothing);
      },
    );

    testWidgets(
      'TEST 5: Clear action removes image preview and analysis result',
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

        final imageTab = find.text('3. Clause Image Analyzer');
        await tester.ensureVisible(imageTab);
        await tester.tap(imageTab);
        await tester.pumpAndSettle();

        // Select and analyze
        final chip = find.byKey(const Key('demo_chip_compliant'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();

        final analyzeBtn = find.byKey(const Key('analyze_visual_button'));
        await tester.ensureVisible(analyzeBtn);
        await tester.tap(analyzeBtn);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.text('COMPLIANT'), findsOneWidget);

        // Tap CLEAR IMAGE
        final clearBtn = find.byKey(const Key('clear_image_button'));
        await tester.ensureVisible(clearBtn);
        await tester.tap(clearBtn);
        await tester.pumpAndSettle();

        expect(find.text('COMPLIANT'), findsNothing);
        expect(find.text('Upload Clause Image'), findsOneWidget);
      },
    );

    testWidgets(
      'TEST 6: Stale state prevention when replacing image',
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

        final imageTab = find.text('3. Clause Image Analyzer');
        await tester.ensureVisible(imageTab);
        await tester.tap(imageTab);
        await tester.pumpAndSettle();

        // 1. Analyze compliant image
        final chip1 = find.byKey(const Key('demo_chip_compliant'));
        await tester.ensureVisible(chip1);
        await tester.tap(chip1);
        await tester.pumpAndSettle();

        final analyzeBtn = find.byKey(const Key('analyze_visual_button'));
        await tester.ensureVisible(analyzeBtn);
        await tester.tap(analyzeBtn);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.text('COMPLIANT'), findsOneWidget);

        // 2. Select different image (transformer.jpg)
        // Previous COMPLIANT result must immediately disappear!
        final chip2 = find.byKey(const Key('demo_chip_mismatch_transformer'));
        await tester.ensureVisible(chip2);
        await tester.tap(chip2);
        await tester.pumpAndSettle();

        expect(find.text('COMPLIANT'), findsNothing);
        expect(find.text('PRODUCT MATCH CONFIRMED'), findsNothing);

        // 3. Analyze second image -> shows mismatch
        await tester.ensureVisible(analyzeBtn);
        await tester.tap(analyzeBtn);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
        expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
      },
    );

    testWidgets(
      'TEST 8: Responsive layout verification at 360x800 and 390x844 without overflow',
      (WidgetTester tester) async {
        for (final size in [const Size(360, 800), const Size(390, 844)]) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const ManakSetuApp(initialLocation: '/tender-scrutiny'),
          );
          await tester.pumpAndSettle();

          final imageTab = find.text('3. Clause Image Analyzer');
          await tester.ensureVisible(imageTab);
          await tester.tap(imageTab);
          await tester.pumpAndSettle();

          // Check empty state
          expect(tester.takeException(), isNull);

          // Select compliant
          final chip = find.byKey(const Key('demo_chip_compliant'));
          await tester.ensureVisible(chip);
          await tester.tap(chip);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Analyze
          final analyzeBtn = find.byKey(const Key('analyze_visual_button'));
          await tester.ensureVisible(analyzeBtn);
          await tester.tap(analyzeBtn);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();

          expect(find.text('COMPLIANT'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Select mismatch
          final mismatchChip = find.byKey(
            const Key('demo_chip_mismatch_transformer'),
          );
          await tester.ensureVisible(mismatchChip);
          await tester.tap(mismatchChip);
          await tester.pumpAndSettle();

          await tester.ensureVisible(analyzeBtn);
          await tester.tap(analyzeBtn);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();

          expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
          final err = tester.takeException();
          expect(err, isNull);
        }
      },
    );
  });
}
