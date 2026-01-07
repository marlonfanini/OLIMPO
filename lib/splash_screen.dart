import 'dart:async';
import 'package:flutter/material.dart';
import 'package:olimpo/genero_screen.dart';
import 'package:olimpo/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olimpo/onboarding_screen.dart';
import 'package:olimpo/home_screen.dart'; // o LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();

    final bool onboardingCompleted =
        prefs.getBool('onboarding_completed') ?? false;

    final String? gender = prefs.getString('gender');

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (!onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    if (gender == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GeneroScreen()),
      );
      return;
    }

    // ✅ todo listo
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/midereclogo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
