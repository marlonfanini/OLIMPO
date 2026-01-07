import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:olimpo/genero_screen.dart';
import 'package:olimpo/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> _goAfterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString("gender");

    if (!mounted) return;

    // ✅ si no hay género aún → Género
    if (gender == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GeneroScreen()),
      );
    } else {
      // ✅ si ya existe (por si acaso) → Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  final List<Map<String, dynamic>> _slides = [
    {
      "image": "assets/taekwondo.png",
      "icon": Icons.directions_run,
      "title": "Organiza Torneos Sin\nComplicaciones",
      "button": "Siguiente"
    },
    {
      "image": "assets/running.png",
      "icon": Icons.group,
      "title": "Gestiona Equipos, Horarios e\nInstalaciones Desde Un Solo Lugar",
      "button": "Siguiente"
    },
    {
      "image": "assets/houses.png",
      "icon": Icons.sports_soccer,
      "title": "Impulsa Tus Eventos\nDeportivos",
      "button": "Comenzar"
    },
  ];

  /// Guarda que el onboarding ya se completó
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  void _nextPage() async {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      await _completeOnboarding();
      await _goAfterOnboarding();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  SizedBox.expand(
                    child: Image.asset(
                      _slides[index]["image"],
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Overlay oscura
                  Container(color: Colors.black.withOpacity(0.4)),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00205B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(90),
                          topRight: Radius.circular(90),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _slides[index]["icon"],
                            size: 60,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _slides[index]["title"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Puntos indicadores
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _slides.length,
                                  (dotIndex) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: dotIndex == _currentPage ? 20 : 10,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: dotIndex == _currentPage
                                      ? Colors.redAccent
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Botón inferior dinámico
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF00205B),
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(
                              _slides[index]["button"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),

          // Botón OMITE
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () async {
                await _completeOnboarding();
                await _goAfterOnboarding();
              },
              child: const Text(
                "Omitir >",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
