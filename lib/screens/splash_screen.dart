import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import 'restaurant_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) _goTo(const OnboardingScreen());
      return;
    }

    // If logged in, check role
    final role = await _authService.getUserRole(user.uid);
    if (mounted) {
      if (role == 'restaurant') {
        _goTo(const RestaurantDashboardScreen());
      } else {
        _goTo(const MainScreen());
      }
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
              ),
              child: const Icon(Icons.restaurant_menu_rounded, size: 80, color: AppColors.primary),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).then().shimmer(duration: 1000.ms, color: AppColors.primaryLight),
            const SizedBox(height: 24),
            const Text(
              'LezzetSepeti',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.5,
              ),
            ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.5, curve: Curves.easeOutQuart),
            const SizedBox(height: 16),
            const Text(
              'En lezzetli yemekler kapında!',
              style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
