import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Professional institutional startup screen for ManakSetu.
/// Displays the exact user-supplied logo against a deep navy background
/// before cleanly transitioning into the Command Center.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _timer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              'assets/branding/manaksetu_app_icon.png',
              key: const Key('splash_screen_logo'),
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
