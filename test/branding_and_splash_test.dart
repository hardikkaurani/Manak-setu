import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/app.dart';
import 'package:manaksetu/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ManakSetu Branding & Splash Verification', () {
    test('Source Asset: assets/branding/manaksetu_app_icon.png exists and is valid', () {
      final file = File('assets/branding/manaksetu_app_icon.png');
      expect(file.existsSync(), isTrue, reason: 'Logo asset must exist at assets/branding/manaksetu_app_icon.png');
      expect(file.lengthSync(), greaterThan(100000), reason: 'Logo asset must be high-resolution');
    });

    test('Android Launcher: Required launcher resources exist and are non-empty', () {
      final resDirs = [
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        'android/app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png',
        'android/app/src/main/res/values/colors.xml',
        'android/app/src/main/res/values-v31/styles.xml',
      ];

      for (final resPath in resDirs) {
        final f = File(resPath);
        expect(f.existsSync(), isTrue, reason: 'Resource $resPath must exist');
        expect(f.lengthSync(), greaterThan(0), reason: 'Resource $resPath must not be empty');
      }
    });

    testWidgets('SplashScreen renders centered logo on deep navy background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify deep navy background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0A192F));

      // Verify centered logo widget
      final logoFinder = find.byKey(const Key('splash_screen_logo'));
      expect(logoFinder, findsOneWidget);

      final image = tester.widget<Image>(logoFinder);
      expect((image.image as AssetImage).assetName, 'assets/branding/manaksetu_app_icon.png');
    });

    testWidgets('App launch flow: SplashScreen transitions cleanly to Command Center', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ManakSetuApp(initialLocation: '/splash'));
      await tester.pump();

      // Verify on splash screen initially
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance timer past splash transition duration (900ms + animation)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Verify navigated into Command Center (HomeScreen) with AppHeader
      expect(find.text('ManakSetu'), findsWidgets);
      expect(find.text('WELCOME, PRIYA RAO'), findsOneWidget);
      expect(find.text('ACTIVE AUDIT IN PROGRESS'), findsOneWidget);
    });
  });
}
