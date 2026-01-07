import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:olimpo/torneo_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "https://olimpo-production.up.railway.app";

class HistorialTorneosScreen extends StatefulWidget {
  const HistorialTorneosScreen({super.key});

  @override
  State<HistorialTorneosScreen> createState() => _HistorialTorneosScreenState();
}

class _HistorialTorneosScreenState extends State<HistorialTorneosScreen> {
  bool loading = true;
  bool error = false;

  List<dynamic> misTorneos = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadAndStoreUserProfileIfNeeded();
    await _loadHistorial();
  }

  Future<void> _loadAndStoreUserProfileIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString("userName");

    // Si ya lo tienes guardado, no vuelvas a pedirlo
    if (userName != null && userName.trim().isNotEmpty) return;

    final userId = prefs.getInt("userId");
    final token = prefs.getString("token");
    if (userId == null || token == null) return;

    final url = "$baseUrl/api/User/GetUserEdit/$userId";

    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final name = (json["data"]?["name"] ?? "").toString();
      if (name.isNotEmpty) {
        await prefs.setString("userName", name);
      }
    }
  }

  Future<void> _loadHistorial() async {
    setState(() {
      loading = true;
      error = false;
      misTorneos = [];
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userName = (prefs.getString("userName") ?? "").trim();

      if (token == null || token.isEmpty || userName.isEmpty) {
        throw Exception("Sesión inválida o userName vacío");
      }

      // 1) Traer todos los torneos
      final listUrl = "$baseUrl/api/Tournaments/GetAllTournamentsMobile";
      final listResp = await http.get(
        Uri.parse(listUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (listResp.statusCode != 200) {
        throw Exception("No se pudieron cargar los torneos");
      }

      final listJson = jsonDecode(listResp.body);
      final torneos = (listJson["data"] ?? []) as List<dynamic>;

      // 2) Filtrar solo los torneos donde el usuario esté inscrito
      //    (haciendo request al detalle porque el listado no trae participants)
      final futures = torneos.map((t) async {
        final int id = (t["id"] ?? 0) as int;

        final detailUrl = "$baseUrl/api/Tournaments/GetEditMobileDTO?id=$id";
        final detailResp = await http.get(
          Uri.parse(detailUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (detailResp.statusCode != 200) return null;

        final detailJson = jsonDecode(detailResp.body);
        final data = detailJson["data"];
        if (data == null) return null;

        final participantes = (data["participants"] ?? []) as List<dynamic>;
        final estaInscrito = participantes.any(
              (p) => (p["name"] ?? "").toString().trim() == userName,
        );

        // Si está inscrito, devolvemos un objeto “summary” para pintar la tarjeta
        if (estaInscrito) {
          return {
            "id": data["id"] ?? id,
            "name": data["name"] ?? t["name"] ?? "",
            "category": data["category"] ?? t["category"] ?? "",
            "discipline": data["discipline"] ?? t["discipline"] ?? "",
            "status": data["status"] ?? t["status"] ?? "",
            "facility": data["facility"] ?? t["facility"] ?? "",
            "supervisor": data["supervisor"] ?? t["supervisor"] ?? "",
          };
        }

        return null;
      }).toList();

      final results = await Future.wait(futures);
      misTorneos = results.whereType<Map<String, dynamic>>().toList();

      setState(() {
        loading = false;
        error = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00205B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00205B),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadHistorial,
            icon: const Icon(Icons.refresh, color: Color(0xFF00205B)),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Error cargando historial"))
          : misTorneos.isEmpty
          ? Center(
        child: Text(
          "Aún no estás inscrito en torneos",
          style: GoogleFonts.poppins(fontSize: 15),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: misTorneos.length,
        itemBuilder: (_, index) {
          final t = misTorneos[index];
          return _buildTorneoCard(
            id: t["id"],
            name: t["name"] ?? "",
            category: t["category"] ?? "",
            discipline: t["discipline"] ?? "",
            status: t["status"] ?? "",
            facility: t["facility"] ?? "",
            supervisor: t["supervisor"] ?? "",
            image: "assets/torneocup.png",
          );
        },
      ),
    );
  }

  Widget _buildTorneoCard({
    required int id,
    required String name,
    required String category,
    required String discipline,
    required String status,
    required String facility,
    required String supervisor,
    required String image,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TorneoDetailScreen(
              id: id,
              name: name,
              discipline: discipline,
              category: category,
              status: status,
              facility: facility,
              supervisor: supervisor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image,
                width: 130,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Disciplina: $discipline",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _info(Icons.sports_soccer, "Categoría: $category"),
                  _info(Icons.flag, "Estado: $status"),
                  _info(Icons.location_on, "Instalación: $facility"),
                  _info(Icons.person, "Supervisor: $supervisor"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
