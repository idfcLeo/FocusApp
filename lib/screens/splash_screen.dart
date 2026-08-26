import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/food_classifier_service.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  double _progress = 0.0;
  String _loadingText = 'Initializing Focus Hub...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Stage 1: 35% - Storage & Notification Setup
    if (mounted) {
      setState(() {
        _progress = 0.35;
        _loadingText = 'Setting up reminders & storage...';
      });
    }
    try {
      await NotificationService.init();
      await StorageService.loadTasks();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));

    // Stage 2: 75% - AI Camera & Goal Plans
    if (mounted) {
      setState(() {
        _progress = 0.75;
        _loadingText = 'Loading AI Camera & Goal Plans...';
      });
    }
    try {
      await FoodClassifierService.init();
      await StorageService.loadWaterIntake();
      await StorageService.loadActivePlan();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 600));

    // Stage 3: 100% - Ready
    if (mounted) {
      setState(() {
        _progress = 1.0;
        _loadingText = 'Ready!';
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    _animationController.stop();

    Navigator.of(context).pushReplacement(
      SmoothFadeSlideRoute(page: const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Animated App Icon Badge
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.4),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: const Color(0xFF818CF8).withOpacity(0.2),
                          blurRadius: 60,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF4F46E5),
                          child: const Center(
                            child: Text('🎯', style: TextStyle(fontSize: 54)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // App Title & Tagline
              const Text(
                'Focus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Protect Your Time. Protect Your Future.',
                style: TextStyle(
                  color: Color(0xFFA5B4FC),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // Loading Progress Bar & Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuad,
                        tween: Tween<double>(begin: 0, end: _progress),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF818CF8)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _loadingText,
                        key: ValueKey<String>(_loadingText),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
