import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';

void main() {
  testWidgets('Phase 5A Preset Navigation & Deterministic Audit Test', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Pump the App
    await tester.pumpWidget(const ManakSetuApp());
    await tester.pumpAndSettle();

    // ==========================================
    // TEST PRESET 1: WATER SUPPLY HDPE PIPELINE
    // ==========================================
    final preset1Card = find.text('Preset 1: Water Supply HDPE Pipeline');
    expect(preset1Card, findsOneWidget);
    await tester.ensureVisible(preset1Card);
    await tester.tap(preset1Card);
    await tester.pumpAndSettle();

    // Verify Preset 1 text loaded in Scrutiny input
    expect(find.text('HDPE Water Supply Pipes'), findsWidgets);
    expect(
      find.textContaining('IS 4984:1995 (Fourth Revision) or ASTM D3035'),
      findsOneWidget,
    );

    // Run Audit on Preset 1
    final checkComplianceBtn = find.text('CHECK TENDER COMPLIANCE');
    await tester.ensureVisible(checkComplianceBtn);
    await tester.tap(checkComplianceBtn);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify Preset 1 Scorecard (8% Non-Compliant)
    expect(find.text('8%'), findsOneWidget);
    expect(find.text('NON_COMPLIANT'), findsOneWidget);
    expect(find.text('IS 4984:1995'), findsWidgets);
    expect(find.text('Replace with: IS 4984:2016'), findsWidgets);
    expect(find.text('ASTM D3035'), findsWidgets);
    expect(find.text('Supreme / Astral'), findsWidgets);

    // Navigate to Specification Builder for Preset 1
    final buildSpecBtn = find.text('BUILD COMPLIANT SPECIFICATION →').first;
    await tester.ensureVisible(buildSpecBtn);
    await tester.tap(buildSpecBtn);
    await tester.pumpAndSettle();

    // Verify Preset 1 in Builder
    expect(find.text('Primary: IS 4984:2016'), findsOneWidget);
    expect(find.text('8%'), findsOneWidget);
    expect(find.text('NON_COMPLIANT'), findsOneWidget);
    expect(find.text('Step 1: W1'), findsOneWidget);

    // Return to Tender Scrutiny
    final returnBtn = find.text('← RETURN TO TENDER SCRUTINY');
    await tester.ensureVisible(returnBtn);
    await tester.tap(returnBtn);
    await tester.pumpAndSettle();

    // ==========================================
    // TEST PRESET 3: CIVIL WORKS TMT REBARS
    // ==========================================
    final preset3Card = find.text('Preset 3: Civil Works TMT Rebars');
    expect(preset3Card, findsOneWidget);
    await tester.ensureVisible(preset3Card);
    await tester.tap(preset3Card);
    await tester.pumpAndSettle();

    // Verify Preset 3 text loaded in Scrutiny input
    expect(find.text('TMT Reinforcement Steel'), findsWidgets);
    expect(
      find.textContaining('Tata Tiscon or Jindal Panther make only'),
      findsOneWidget,
    );

    // Run Audit on Preset 3
    await tester.ensureVisible(checkComplianceBtn);
    await tester.tap(checkComplianceBtn);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify Preset 3 Scorecard (12% Non-Compliant)
    expect(find.text('12%'), findsOneWidget);
    expect(find.text('NON_COMPLIANT'), findsOneWidget);
    expect(find.text('ASTM A615 Grade 60'), findsWidgets);
    expect(find.text('Replace with: IS 1786:2008'), findsOneWidget);
    expect(find.text('Tata Tiscon / Jindal Panther'), findsWidgets);

    // Navigate to Specification Builder for Preset 3
    await tester.ensureVisible(buildSpecBtn);
    await tester.tap(buildSpecBtn);
    await tester.pumpAndSettle();

    // Verify Preset 3 in Builder
    expect(find.text('Primary: IS 1786:2008'), findsOneWidget);
    expect(find.text('12%'), findsOneWidget);
    expect(find.text('NON_COMPLIANT'), findsOneWidget);
    expect(find.text('Step 1: S1'), findsOneWidget);
  });
}
