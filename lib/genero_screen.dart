import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olimpo/rol_screen.dart';

class GeneroScreen extends StatefulWidget {
  const GeneroScreen({super.key});

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF00205B),
            size: 15,
          ),
          label: Text(
            "Atras",
            style: GoogleFonts.poppins(
              color: const Color(0xFF00205B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 10)),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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

            GestureDetector(
              onTap: () {
                setState(() => selectedGender = "Masculino");
              },
              child: Column(
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      color: selectedGender == "Masculino"
                          ? const Color(0xFF00205B)
                          : Colors.white,
                      border: Border.all(
                        color: const Color(0xFF00205B),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.male,
                      size: 90,
                      color: selectedGender == "Masculino"
                          ? Colors.white
                          : const Color(0xFF00205B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Masculino",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: selectedGender == "Masculino"
                          ? const Color(0xFF00205B)
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: () {
                setState(() => selectedGender = "Femenino");
              },
              child: Column(
                children: [

                  const SizedBox(height: 15),
                  Text(
                    "Femenino",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: selectedGender == "Femenino"
                          ? const Color(0xFF00205B)
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedGender == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RolScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00205B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
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
}
