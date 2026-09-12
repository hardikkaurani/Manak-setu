import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';

void main() {
  testWidgets('Product Image Analysis workflow tests in Tender Scrutiny', (
    WidgetTester tester,
  ) async {
    // Set large viewport for complete UI rendering
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Launch App directly at Tender Scrutiny
    await tester.pumpWidget(
      const ManakSetuApp(initialLocation: '/tender-scrutiny'),
    );
    await tester.pumpAndSettle();

    // Verify Tender Scrutiny title and input section
    expect(find.text('WORKSPACE / NEW ANALYSIS'), findsOneWidget);
    expect(find.text('ADD PRODUCT IMAGE'), findsOneWidget);
    expect(
      find.text('Analyze a product photo instead of typing specifications.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('add_product_image_button')), findsOneWidget);

    // 2. Tap "TAKE PHOTO OR CHOOSE IMAGE" to open source picker
    await tester.tap(find.byKey(const Key('add_product_image_button')));
    await tester.pumpAndSettle();

    // Verify source picker sheet contents
    expect(find.text('PRODUCT PHOTO SOURCE'), findsOneWidget);
    expect(find.text('Take Photo with Camera'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    expect(find.text('Distribution Transformer (Oil-Immersed 250 kVA)'), findsOneWidget);

    // 3. Select "Distribution Transformer" canonical demo sample
    await tester.tap(
      find.text('Distribution Transformer (Oil-Immersed 250 kVA)'),
    );
    await tester.pumpAndSettle();

    // Verify preview and extraction card is rendered
    expect(find.text('PRODUCT IMAGE ANALYSIS'), findsOneWidget);
    expect(find.text('Physical Equipment Specification'), findsOneWidget);
    expect(find.text('OFFLINE PRODUCT IMAGE DEMO'), findsOneWidget);
    expect(find.text('transformer_photo.jpg'), findsOneWidget);
    expect(find.text('EXTRACTED PRODUCT SPECIFICATION'), findsOneWidget);
    expect(find.text('Distribution Transformers'), findsAtLeast(1));
    expect(find.text('TECHNICAL PARAMETERS'), findsOneWidget);
    expect(find.text('250 kVA, 11 kV / 433 V, 50 Hz, 3-Phase'), findsOneWidget);
    expect(find.byKey(const Key('analyze_product_button')), findsOneWidget);

    // 4. Test Switching product category chip to "HDPE Pipe"
    final pipeChip = find.byKey(const Key('product_sample_chip_pipe'));
    await tester.ensureVisible(pipeChip);
    await tester.tap(pipeChip);
    await tester.pumpAndSettle();

    expect(find.text('HDPE Water Supply Pipes'), findsAtLeast(1));
    expect(find.text('110 mm Nominal Outer Diameter, PN-10 rating, SDR 13.6'), findsOneWidget);

    // 5. Test Switching to "Unknown / Other" (triggers unidentifiable fallback)
    final unknownChip = find.byKey(const Key('product_sample_chip_unknown'));
    await tester.ensureVisible(unknownChip);
    await tester.tap(unknownChip);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Product identification unavailable — manual specification input required.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('switch_to_manual_button')), findsOneWidget);

    // Tap "CONTINUE WITH MANUAL TEXT INPUT"
    await tester.tap(find.byKey(const Key('switch_to_manual_button')));
    await tester.pumpAndSettle();

    // 6. Switch back to supported product and analyze
    await tester.tap(find.byKey(const Key('product_sample_chip_transformer')));
    await tester.pumpAndSettle();

    // Tap "ANALYZE APPLICABLE STANDARDS"
    final analyzeBtn = find.byKey(const Key('analyze_product_button'));
    await tester.ensureVisible(analyzeBtn);
    await tester.tap(analyzeBtn);
    await tester.pump(); // Start analysis progress
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify transition into existing Tender Scrutiny result pipeline
    expect(find.text('COMPLIANCE EVALUATION'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(find.text('NON_COMPLIANT'), findsOneWidget);
    expect(find.text('Critical Defects'), findsOneWidget);
    expect(find.text('High-Risk Violations'), findsOneWidget);
    expect(find.text('Regulatory QCO & Mandatory Certification'), findsOneWidget);
    expect(find.text('BUILD COMPLIANT SPECIFICATION →'), findsWidgets);

    // 7. Test REMOVE PHOTO returns back to initial card
    final removeBtn = find.byKey(const Key('product_image_remove_button'));
    await tester.ensureVisible(removeBtn);
    await tester.tap(removeBtn);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add_product_image_button')), findsOneWidget);
  });
}
