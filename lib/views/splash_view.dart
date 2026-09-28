import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  Timer? _progressStartTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Main staggered animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Pulse (loop) for logo glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Progress bar
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Logo fade: 0% → 40%
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Logo scale: 0% → 50% (elastic)
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Logo glow pulsing
    _glowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Title: 30% → 60%
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Subtitle: 45% → 75%
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    // Pulse for scale
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress bar fill
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start animations
    _mainController.forward();
    _progressStartTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _progressController.forward();
    });

    // Navigate after animation
    _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Get.offAllNamed(Routes.MAIN);
      }
    });
  }

  @override
  void dispose() {
    _progressStartTimer?.cancel();
    _navigationTimer?.cancel();
    _mainController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo with glow & pulse
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _mainController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: _glowAnimation.value + 20,
                                  spreadRadius: _glowAnimation.value / 2,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.newspaper_rounded,
                                size: 64,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // Title — staggered
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: const Text(
                      'NewsHub',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle — staggered
                FadeTransition(
                  opacity: _subtitleFade,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: Text(
                      'Stay Updated with Latest News',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _subtitleFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
