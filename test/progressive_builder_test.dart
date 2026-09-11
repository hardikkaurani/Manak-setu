import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';

void main() {
  testWidgets(
    'Phase 5A Progressive Specification Builder Sequential & Shortcut Tests',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Pump App
      await tester.pumpWidget(const ManakSetuApp());
      await tester.pumpAndSettle();

      // Run compliance check on default preset (Preset 2: Transformer)
      final checkBtn = find.text('CHECK TENDER COMPLIANCE');
      await tester.ensureVisible(checkBtn);
      await tester.tap(checkBtn);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to Specification Builder
      final buildBtn = find.text('BUILD COMPLIANT SPECIFICATION →').first;
      await tester.ensureVisible(buildBtn);
      await tester.tap(buildBtn);
      await tester.pumpAndSettle();

      // ==========================================
      // 1. INITIAL DEFECTIVE STATE IN BUILDER
      // ==========================================
      expect(find.text('5%'), findsOneWidget);
      expect(find.text('NON_COMPLIANT'), findsOneWidget);
      expect(
        find.text('4 Corrections Pending • Rectification Required'),
        findsOneWidget,
      );

      // Verify Step 1 is available and Step 2 is pending/locked
      final step1Btn = find.text('ADD TO SPEC (5% ➔ 30%)');
      expect(step1Btn, findsOneWidget);

      final step2Locked = find.text('STEP PENDING (Complete Step 1 first)');
      expect(step2Locked, findsOneWidget);

      // ==========================================
      // 2. APPLY STEP 1 (T1: IS 1180:1989 -> IS 1180:2014)
      // ==========================================
      await tester.ensureVisible(step1Btn);
      await tester.tap(step1Btn);
      await tester.pumpAndSettle();

      // Score increased to 30%
      expect(find.text('30%'), findsOneWidget);
      expect(find.text('PARTIALLY_COMPLIANT'), findsOneWidget);
      expect(find.text('✓ ADDED TO SPECIFICATION (30%)'), findsOneWidget);

      // Step 2 is now unlocked!
      final step2Btn = find.text('ADD TO SPEC (30% ➔ 55%)');
      expect(step2Btn, findsOneWidget);

      // Section 2.0 now reflects active revision IS 1180 (Part 1):2014 in-place
      expect(find.textContaining('IS 1180 (Part 1):2014'), findsWidgets);

      // ==========================================
      // 3. APPLY STEP 2 (T2: IS 335:1993 -> IS 335:2018)
      // ==========================================
      await tester.ensureVisible(step2Btn);
      await tester.tap(step2Btn);
      await tester.pumpAndSettle();

      expect(find.text('55%'), findsOneWidget);
      expect(find.text('✓ ADDED TO SPECIFICATION (55%)'), findsOneWidget);

      // ==========================================
      // 4. APPLY STEP 3 (T3: Brand Neutrality)
      // ==========================================
      final step3Btn = find.text('ADD TO SPEC (55% ➔ 75%)');
      expect(step3Btn, findsOneWidget);
      await tester.ensureVisible(step3Btn);
      await tester.tap(step3Btn);
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('✓ ADDED TO SPECIFICATION (75%)'), findsOneWidget);

      // ==========================================
      // 5. APPLY STEP 4 (T4: Mandatory QCO Enforcement)
      // ==========================================
      final step4Btn = find.text('ADD TO SPEC (75% ➔ 100%)');
      expect(step4Btn, findsOneWidget);
      await tester.ensureVisible(step4Btn);
      await tester.tap(step4Btn);
      await tester.pumpAndSettle();

      // Score reaches 100% COMPLIANT
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('COMPLIANT'), findsOneWidget);
      expect(
        find.text('0 Critical Defects • GFR-144 & BIS Ready'),
        findsOneWidget,
      );

      // Completion Banner is visible and user remains on screen
      expect(
        find.text('100% SPECIFICATION READY FOR PROCUREMENT'),
        findsOneWidget,
      );

      // ==========================================
      // 6. TEST RESET SPECIFICATION ACTION
      // ==========================================
      final resetBtn = find.text('RESET SPECIFICATION');
      await tester.ensureVisible(resetBtn);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // Back to initial 5% state
      expect(find.text('5%'), findsOneWidget);
      expect(find.text('NON_COMPLIANT'), findsOneWidget);
      expect(find.text('ADD TO SPEC (5% ➔ 30%)'), findsOneWidget);

      // ==========================================
      // 7. TEST SHORTCUT: VIEW 100% COMPLIANT SPECIFICATION
      // ==========================================
      final shortcutBtn = find.text('VIEW 100% COMPLIANT SPECIFICATION');
      await tester.ensureVisible(shortcutBtn);
      await tester.tap(shortcutBtn);
      await tester.pumpAndSettle();

      // Immediately 100%
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('COMPLIANT'), findsOneWidget);
      expect(
        find.text('✓ SPECIFICATION FULLY COMPLIANT (100%)'),
        findsOneWidget,
      );

      // ==========================================
      // 8. TEST TABS: REDLINE DIFF & KNOWLEDGE GRAPH
      // ==========================================
      // Diff Tab
      final diffTab = find.text('Redline Diff');
      await tester.ensureVisible(diffTab);
      await tester.tap(diffTab);
      await tester.pumpAndSettle();

      expect(
        find.text('Specification Redline: Distribution Transformers'),
        findsOneWidget,
      );
      expect(find.textContaining('ORIGINAL CLAUSE'), findsOneWidget);
      expect(find.textContaining('RECTIFIED CLAUSE'), findsOneWidget);

      // Knowledge Graph Tab
      final graphTab = find.text('Knowledge Graph');
      await tester.ensureVisible(graphTab);
      await tester.tap(graphTab);
      await tester.pumpAndSettle();

      expect(find.text('BIS KNOWLEDGE GRAPH'), findsOneWidget);
      expect(find.text('CENTRAL GOVERNING ROOT'), findsOneWidget);
    },
  );
}
