import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olimpo/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneroScreen extends StatefulWidget {
  const GeneroScreen({super.key});

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  String? selectedGender;

  Future<void> _guardarGenero() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("gender", selectedGender!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF00205B), size: 15),
          label: Text(
            "Atras",
            style: GoogleFonts.poppins(
              color: const Color(0xFF00205B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "¿Con Qué Género\nTe Identificas?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00205B),
              ),
            ),
            const SizedBox(height: 40),

            _buildGender(
              icon: Icons.male,
              label: "Masculino",
            ),

            const SizedBox(height: 40),

            _buildGender(
              icon: Icons.female,
              label: "Femenino",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedGender == null
                    ? null
                    : () async {
                  await _guardarGenero();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00205B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(
                  "Continuar",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildGender({required IconData icon, required String label}) {
    final selected = selectedGender == label;

    return GestureDetector(
      onTap: () => setState(() => selectedGender = label),
      child: Column(
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF00205B) : Colors.white,
              border: Border.all(color: const Color(0xFF00205B), width: 3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 90,
              color: selected ? Colors.white : const Color(0xFF00205B),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: selected ? const Color(0xFF00205B) : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
