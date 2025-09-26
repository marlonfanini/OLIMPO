import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:olimpo/login_screen.dart';
import 'main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

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

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Página Principal')),
      );
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
                      _slides[index]["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                            _slides[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _slides.length,
                                  (dotIndex) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: dotIndex == _currentPage ? 20 : 10,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: dotIndex == _currentPage ? Colors.redAccent : Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          if (index == _slides.length - 1)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF00205B),
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text(
                                "Comenzar",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),


                ],
              );
            },
          ),

          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
