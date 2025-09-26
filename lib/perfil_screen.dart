import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olimpo/home_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _emailController = TextEditingController(text: "madisons@example.com");
  final TextEditingController _phoneController = TextEditingController();
  String? selectedDiscipline;
  bool receiveEmails = false;

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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00205B), size: 15),
          label: Text(
            "Atras",
            style: GoogleFonts.poppins(
              color: const Color(0xFF00205B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 10),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Completa Tu Perfil",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00205B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Completa tu perfil para empezar a disfrutar de OLIMPO.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage("assets/taekwondo.png"),
                  backgroundColor: Colors.grey[300],
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF00205B), size: 18),
                    onPressed: () {
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildTextField("Correo Electrónico", _emailController, enabled: false),

            const SizedBox(height: 20),
            _buildTextField("Número de Teléfono", _phoneController, hint: "+123 567 8900"),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Disciplina principal",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00205B),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: Text("Selecciona una disciplina", style: GoogleFonts.poppins()),
              value: selectedDiscipline,
              onChanged: (value) {
                setState(() {
                  selectedDiscipline = value;
                });
              },
              items: ["Fútbol", "Baloncesto", "Tenis", "Natación"]
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: GoogleFonts.poppins()),
              ))
                  .toList(),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Checkbox(
                  value: receiveEmails,
                  onChanged: (value) {
                    setState(() {
                      receiveEmails = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF00205B),
                ),
                Expanded(
                  child: Text(
                    "Recibir correos con novedades y promociones. Mantente al día con lo mejor de OLIMPO: eventos y torneos.",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 5,
                ),
                child: Text(
                  "Empezar",
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF00205B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
