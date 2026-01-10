import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olimpo/calendario_reservas_screen.dart';
import 'package:olimpo/instalaciones_screen.dart';
import 'package:olimpo/perfiles_screen.dart';
import 'package:olimpo/torneos_screen.dart';
import 'package:olimpo/widget/custom_bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const String baseUrl = "https://olimpo-production.up.railway.app";

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<dynamic> torneos = [];
  bool loadingTorneos = true;
  String userName = "—";
  bool loadingUser = true;

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      if (userId == null || token == null) {
        setState(() {
          loadingUser = false;
          userName = "—";
        });
        return;
      }

      final url = Uri.parse("$baseUrl/api/User/GetUserEdit/$userId");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json["data"];

        setState(() {
          userName = (data["name"] ?? "—").toString();
          loadingUser = false;
        });
      } else {
        setState(() => loadingUser = false);
      }
    } catch (_) {
      setState(() => loadingUser = false);
    }
  }

  final List<String> torneoImages = [
    "assets/taekwondo.png",
    "assets/centro.png",
    "assets/running.png",
    "assets/natacion.jpeg",
  ];
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  List<dynamic> noticias = [];
  bool loadingNoticias = true;

  final List<String> noticiaImages = [
    "assets/houses.png",
    "assets/campo.jpg",
    "assets/running.png",
  ];

  Future<void> _loadNoticias() async {
    final url = "$baseUrl/api/News/GetAllNewsMobile";

    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          noticias = json["data"] ?? [];
          loadingNoticias = false;
        });
      } else {
        loadingNoticias = false;
      }
    } catch (e) {
      loadingNoticias = false;
    }
  }


  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const meses = [
        "", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
      ];
      return "${d.day} ${meses[d.month]}";
    } catch (_) {
      return raw;
    }
  }

  Future<void> _loadTorneos() async {
    final url = "$baseUrl/api/Tournaments/GetAllTournamentsMobile";

    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          torneos = json["data"] ?? [];
          loadingTorneos = false;
        });
      }
    } catch (e) {
      loadingTorneos = false;
    }
  }


  List<dynamic> instalaciones = [];
  bool loadingInstalaciones = true;

  Future<void> _loadInstalaciones() async {
    final url = "$baseUrl/api/Facility/GetAllFacilitiesAsyncMobile";

    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          instalaciones = json["data"] ?? [];
          loadingInstalaciones = false;
        });
      }
    } catch (e) {
      loadingInstalaciones = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTorneos();
    _loadInstalaciones();
    _loadNoticias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() => selectedIndex = index);
        },
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          // 👇 Pantalla 0 - Tu pantalla original (no la tocamos)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, ${loadingUser ? "..." : userName}",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00205B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "¡Es momento de superar tus marcas en OLIMPO!",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF00205B), width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.person_outline, size: 22, color: Color(0xFF00205B)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),
                  buildQuickActionsRow(),
                  const SizedBox(height: 22),

                  // TORNEOS
                  Text(
                    "Próximos Torneos",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00205B),
                    ),
                  ),

                  const SizedBox(height: 15),

                  loadingTorneos
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: torneos.length,
                      itemBuilder: (context, index) {
                        final t = torneos[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildTorneoCard(
                            t["name"] ?? "",
                            _formatDate(t["date"]),
                            t["facility"] ?? "",
                            torneoImages[index % torneoImages.length], // 👈 imagen por orden
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),


                  const SizedBox(height: 25),

                  // INSTALACIONES
                  Text(
                    "Instalaciones",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00205B),
                    ),
                  ),

                  const SizedBox(height: 15),

                  loadingInstalaciones
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: instalaciones.map<Widget>((fac) {
                      return _buildInstalacionCard(fac);
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // NOTICIAS
                  Text(
                    "Noticias",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00205B),
                    ),
                  ),

                  const SizedBox(height: 15),

                  loadingNoticias
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: noticias.length,
                      itemBuilder: (context, index) {
                        final n = noticias[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: _buildNewsCard(
                            n["description"] ?? "Sin título",
                            noticiaImages[index % noticiaImages.length],
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),


          const InstalacionesScreen(),

          TorneosScreen(),

          CalendarioReservasScreen(),

          const PerfilScreen(),
        ],
      ),
    );
  }

  // 🔹 Quick Actions
  Widget buildQuickActionsRow() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickAction(Icons.fitness_center, "Torneos", 0),
          _buildDivider(),
          _buildQuickAction(Icons.assignment, "Instalaciones", 1),
          _buildDivider(),
          _buildQuickAction(Icons.access_time_outlined, "Torneos", 2),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.redAccent : const Color(0xFF00205B), size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.redAccent : const Color(0xFF00205B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 1,
      height: 40,
      color: const Color(0xFF00205B).withOpacity(0.3),
    );
  }

  // 🔹 Cards
  Widget _buildTorneoCard(String title, String date, String place, String imagePath) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.asset(imagePath, width: 220, height: 120, fit: BoxFit.cover),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: Color(0xFF00205B)),
                    const SizedBox(width: 6),
                    Text(date, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF00205B)),
                    const SizedBox(width: 6),
                    Text(place, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String imagePath) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(imagePath, width: 170, height: 100, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 160,
          child: Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

Widget _buildInstalacionCard(Map<String, dynamic> fac) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4),
      ],
    ),
    child: Row(
      children: [
        Icon(Icons.location_on, color: Colors.redAccent, size: 32),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fac["name"] ?? "",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF00205B),
              ),
            ),
            Text(
              fac["type"] ?? "",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
