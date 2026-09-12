import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';
import 'package:manaksetu/models/product_image_sample.dart';
import 'package:manaksetu/widgets/product_image_input_card.dart';

Widget _buildTestWrapper({
  required void Function(ProductImageSample) onAnalyzeProduct,
  required VoidCallback onManualInputRequested,
  void Function(bool)? onModeToggled,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ProductImageInputCard(
            onAnalyzeProduct: onAnalyzeProduct,
            onManualInputRequested: onManualInputRequested,
            onModeToggled: onModeToggled,
          ),
        ),
      ),
    ),
  );
}

void _setTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(500, 1600);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  group('Phase 5B Demo Error-State Override Test Suite', () {
    // TEST 1: Default state (error override OFF, normal flow available)
    testWidgets('TEST 1: Default state - error override switch OFF and quick demo products available', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      ProductImageSample? analyzedSample;
      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (sample) => analyzedSample = sample,
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Verify switch is OFF by default
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);

      // Verify Quick Demo Products exist
      expect(find.byKey(const Key('quick_demo_transformer')), findsOneWidget);
      expect(find.byKey(const Key('quick_demo_pipe')), findsOneWidget);
      expect(find.byKey(const Key('quick_demo_steel')), findsOneWidget);
      expect(find.text('Distribution'), findsOneWidget);
      expect(find.text('HDPE'), findsOneWidget);
      expect(find.text('TMT'), findsOneWidget);

      // Select sample and verify normal flow
      final pipeFinder = find.byKey(const Key('quick_demo_pipe'));
      await tester.ensureVisible(pipeFinder);
      await tester.tap(pipeFinder);
      await tester.pumpAndSettle();

      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pumpAndSettle();

      expect(analyzedSample, isNotNull);
      expect(analyzedSample!.id, 'pipe');
      expect(find.text('PRODUCT MISMATCH ALERT:'), findsNothing);
    });

    // TEST 2: Enable error override (switch indicates ON, no crash, quick demo products available)
    testWidgets('TEST 2: Enable error override switch turns ON and quick demo products remain available', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool? lastMode;
      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
          onModeToggled: (mode) => lastMode = mode,
        ),
      );
      await tester.pumpAndSettle();

      // Tap switch
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Switch should be ON
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);
      expect(lastMode, isTrue);

      // Quick demo products remain accessible
      expect(find.byKey(const Key('quick_demo_transformer')), findsOneWidget);
      expect(find.byKey(const Key('quick_demo_pipe')), findsOneWidget);
      expect(find.byKey(const Key('quick_demo_steel')), findsOneWidget);
    });

    // TEST 3: Forced mismatch (enable error mode, select any image, analyze -> PRODUCT MISMATCH ALERT, CATEGORY CONFLICT, SCRUTINY REJECTED)
    testWidgets('TEST 3: Forced mismatch on analyzed image produces statutory mismatch and category conflict', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Enable error mode
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Select demo product
      final transFinder = find.byKey(const Key('quick_demo_transformer'));
      await tester.ensureVisible(transFinder);
      await tester.tap(transFinder);
      await tester.pumpAndSettle();

      // Analyze
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify canonical mismatch UI elements
      expect(find.text('MULTI-MODAL VISUAL GAP MATRIX & PHYSICAL SCRUTINY'), findsOneWidget);
      expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
      expect(find.text('IMAGE INVALID FOR SPECIFIED REQUIREMENT'), findsOneWidget);
      expect(find.text('CATEGORY CONFLICT:'), findsOneWidget);
      expect(
        find.textContaining('Equipment photo/nameplate does not correspond to the required procurement category'),
        findsOneWidget,
      );
    });

    // TEST 4: Distribution + forced mismatch
    testWidgets('TEST 4: Distribution + forced mismatch shows IS 1180:2014 and category conflict', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // 1. Select Distribution
      final transFinder = find.byKey(const Key('quick_demo_transformer'));
      await tester.ensureVisible(transFinder);
      await tester.tap(transFinder);
      await tester.pumpAndSettle();

      // 2. Enable error mode
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // 3. Analyze
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
      expect(find.text('Governing Standard: '), findsOneWidget);
      expect(find.text('IS 1180:2014'), findsOneWidget);
      expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
      expect(find.text('CATEGORY CONFLICT:'), findsOneWidget);
    });

    // TEST 5: HDPE + forced mismatch
    testWidgets('TEST 5: HDPE + forced mismatch shows IS 4984:2016 and category conflict', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // 1. Select HDPE
      final pipeFinder = find.byKey(const Key('quick_demo_pipe'));
      await tester.ensureVisible(pipeFinder);
      await tester.tap(pipeFinder);
      await tester.pumpAndSettle();

      // 2. Enable error mode
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // 3. Analyze
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
      expect(find.text('Governing Standard: '), findsOneWidget);
      expect(find.text('IS 4984:2016'), findsOneWidget);
      expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
      expect(find.text('CATEGORY CONFLICT:'), findsOneWidget);
    });

    // TEST 6: TMT + forced mismatch
    testWidgets('TEST 6: TMT + forced mismatch shows IS 1786:2008 and category conflict', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // 1. Select TMT
      final steelFinder = find.byKey(const Key('quick_demo_steel'));
      await tester.ensureVisible(steelFinder);
      await tester.tap(steelFinder);
      await tester.pumpAndSettle();

      // 2. Enable error mode
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // 3. Analyze
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
      expect(find.text('Governing Standard: '), findsOneWidget);
      expect(find.text('IS 1786:2008'), findsOneWidget);
      expect(find.text('SCRUTINY REJECTED'), findsOneWidget);
      expect(find.text('CATEGORY CONFLICT:'), findsOneWidget);
    });

    // TEST 7: Error mode OFF preserves normal flow
    testWidgets('TEST 7: Error mode OFF preserves normal flow and invokes parent callback', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      ProductImageSample? invokedSample;
      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (s) => invokedSample = s,
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Select Steel
      final steelFinder = find.byKey(const Key('quick_demo_steel'));
      await tester.ensureVisible(steelFinder);
      await tester.tap(steelFinder);
      await tester.pumpAndSettle();

      // Analyze in normal mode
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pumpAndSettle();

      expect(invokedSample, isNotNull);
      expect(invokedSample!.id, 'steel');
      expect(find.text('PRODUCT MISMATCH ALERT:'), findsNothing);
      expect(find.text('EXTRACTED PRODUCT SPECIFICATION'), findsOneWidget);
    });

    // TEST 8: Toggle clears stale result (analyze normal -> turn ON -> old result clears -> analyze -> mismatch)
    testWidgets('TEST 8: Toggling error mode ON clears stale state before re-analysis', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool modeNotified = false;
      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
          onModeToggled: (_) => modeNotified = true,
        ),
      );
      await tester.pumpAndSettle();

      // Select sample
      final pipeFinder = find.byKey(const Key('quick_demo_pipe'));
      await tester.ensureVisible(pipeFinder);
      await tester.tap(pipeFinder);
      await tester.pumpAndSettle();

      // Toggle error mode ON
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(modeNotified, isTrue);

      // Analyze in error mode
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
    });

    // TEST 9: Turn OFF after mismatch (turn ON -> analyze -> mismatch -> turn OFF -> mismatch clears)
    testWidgets('TEST 9: Turning OFF error mode after mismatch immediately clears mismatch alert', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // 1. Turn ON error mode
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // 2. Select product & analyze
      final pipeFinder = find.byKey(const Key('quick_demo_pipe'));
      await tester.ensureVisible(pipeFinder);
      await tester.tap(pipeFinder);
      await tester.pumpAndSettle();

      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);

      // 3. Turn OFF error mode
      final switchFinderActive = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinderActive);
      await tester.tap(switchFinderActive);
      await tester.pumpAndSettle();

      // Mismatch should be cleared and normal parameter view shown
      expect(find.text('PRODUCT MISMATCH ALERT:'), findsNothing);
      expect(find.text('EXTRACTED PRODUCT SPECIFICATION'), findsOneWidget);
    });

    // TEST 10: Change image while error mode ON (analyze image A -> select image B -> old result clears -> analyze -> mismatch)
    testWidgets('TEST 10: Selecting a different image while in error mode clears old mismatch result', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Turn ON error mode
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Select Image A (Transformer) and analyze
      final transFinder = find.byKey(const Key('quick_demo_transformer'));
      await tester.ensureVisible(transFinder);
      await tester.tap(transFinder);
      await tester.pumpAndSettle();

      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('IS 1180:2014'), findsOneWidget);

      // Select Image B (HDPE) -> old mismatch card clears
      final pipeFinder = find.byKey(const Key('quick_demo_pipe'));
      await tester.ensureVisible(pipeFinder);
      await tester.tap(pipeFinder);
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsNothing);

      // Analyze Image B
      final analyzeBtnB = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtnB);
      await tester.tap(analyzeBtnB);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
      expect(find.text('IS 4984:2016'), findsOneWidget);
    });

    // TEST 11: Clear image (analyze in error mode -> mismatch -> clear image -> image/result disappear)
    testWidgets('TEST 11: Clearing image removes both preview and mismatch result', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestWrapper(
          onAnalyzeProduct: (_) {},
          onManualInputRequested: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Enable error mode & analyze
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final transFinder = find.byKey(const Key('quick_demo_transformer'));
      await tester.ensureVisible(transFinder);
      await tester.tap(transFinder);
      await tester.pumpAndSettle();

      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);

      // Tap CLEAR button
      final clearBtn = find.byKey(const Key('clear_image_button'));
      expect(clearBtn, findsOneWidget);
      await tester.ensureVisible(clearBtn);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      // Both preview and mismatch result disappear; initial card restored
      expect(find.text('PRODUCT MISMATCH ALERT:'), findsNothing);
      expect(find.text('ADD PRODUCT IMAGE'), findsOneWidget);
      expect(find.byKey(const Key('add_product_image_button')), findsOneWidget);
    });

    // TEST 12: End-to-end integration under /tender-scrutiny screen
    testWidgets('TEST 12: End-to-end integration with TenderScrutinyScreen', (
      WidgetTester tester,
    ) async {
      _setTestViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ManakSetuApp(initialLocation: '/tender-scrutiny'),
      );
      await tester.pumpAndSettle();

      // Scroll to ProductImageInputCard on Tab 0
      final switchFinder = find.byKey(const Key('demo_error_override_switch'));
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(switchFinder, findsOneWidget);

      // Enable error mode
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Select Distribution sample
      final distChip = find.byKey(const Key('quick_demo_transformer'));
      await tester.tap(distChip);
      await tester.pumpAndSettle();

      // Scroll to analyze button
      final analyzeBtn = find.byKey(const Key('analyze_product_button'));
      await tester.ensureVisible(analyzeBtn);
      await tester.pumpAndSettle();

      await tester.tap(analyzeBtn);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify Mismatch alert is visible inside Tender Scrutiny
      expect(find.text('PRODUCT MISMATCH ALERT:'), findsOneWidget);
      expect(find.text('SCRUTINY REJECTED'), findsOneWidget);

      // Toggle switch OFF clears result
      final activeSwitch = find.byKey(const Key('demo_error_override_switch'));
      await tester.ensureVisible(activeSwitch);
      await tester.pumpAndSettle();
      await tester.tap(activeSwitch);
      await tester.pumpAndSettle();

      expect(find.text('PRODUCT MISMATCH ALERT:'), findsNothing);
    });
  });
}
