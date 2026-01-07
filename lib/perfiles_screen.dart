import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:olimpo/genero_screen.dart';
import 'package:olimpo/help_faq_screen.dart';
import 'package:olimpo/privacy_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favoritos_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

const String baseUrl = "https://olimpo-production.up.railway.app";

class _PerfilScreenState extends State<PerfilScreen> {
  bool loading = true;
  String gender = "—";

  String name = "";
  String email = "";

  String _normalizeGender(String g) {
    final v = g.trim().toLowerCase();
    if (v.startsWith("m")) return "m";
    if (v.startsWith("h")) return "m";
    if (v.startsWith("f")) return "f";
    if (v.startsWith("w")) return "f";
    return "u";
  }

  String _profileImageByGender(String g) {
    final ng = _normalizeGender(g);

    if (ng == "m") return "assets/olimpo_profile_masculine.png";
    if (ng == "f") return "assets/olimpo_profile_femenine.png";
    return "assets/user.jpg";
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(
          "Cerrar sesión",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "¿Seguro que deseas cerrar sesión?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Sí, cerrar",
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final token = prefs.getString("token");

      if (token != null && token.isNotEmpty) {
        await _revokeToken(token);
      }
    } catch (_) {}

    await prefs.remove("token");
    await prefs.remove("userId");
    await prefs.remove("isLogged");

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GeneroScreen()),
          (route) => false,
    );
  }

  Future<void> _revokeToken(String token) async {
    final url = Uri.parse("$baseUrl/api/Auth/Logout");

    await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");
      final storedGender = prefs.getString("gender");

      if (userId == null || token == null) return;

      final url = "$baseUrl/api/User/GetUserEdit/$userId";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json["data"];

        setState(() {
          name = data["name"] ?? "";
          email = data["email"] ?? "";
          gender = storedGender ?? "—";
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔵 HEADER AZUL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 25),
            decoration: const BoxDecoration(
              color: Color(0xFF00205B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Flecha y título
                Row(
                  children: [
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Mi Perfil",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.25,
                      child: Image.asset(
                        _profileImageByGender(gender),
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  gender,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Género",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            gender, // ✅ aquí va el género real
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.white38,
                      ),
                      Column(
                        children: [
                          Text(
                            "Rol",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "Atleta",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildOption(Icons.person, "Perfil", onTap: () {}),
                _buildOption(
                  Icons.star,
                  "Favoritos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritosScreen(),
                      ),
                    );
                  },
                ),
                _buildOption(
                  Icons.privacy_tip,
                  "Políticas de Privacidad",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _buildOption(Icons.settings, "Ajustes", onTap: () {}),
                _buildOption(
                  Icons.help,
                  "Ayuda",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
                    );
                  },
                ),
                _buildOption(
                  Icons.logout,
                  "Cerrar Sesión",
                  isLogout: true,
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
      IconData icon,
      String title, {
        bool isLogout = false,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.redAccent, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.redAccent : Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
