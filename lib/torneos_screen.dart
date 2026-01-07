import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:olimpo/torneo_detail_screen.dart';
import 'package:olimpo/historial_torneos_screen.dart'; // ✅ NUEVO
import 'package:shared_preferences/shared_preferences.dart';

class TorneosScreen extends StatefulWidget {
  const TorneosScreen({super.key});

  @override
  State<TorneosScreen> createState() => _TorneosScreenState();
}

const String baseUrl = "https://olimpo-production.up.railway.app";

class _TorneosScreenState extends State<TorneosScreen> {
  int selectedFilter = 0;

  final List<String> filtros = [
    "Todo",
  ];

  List<dynamic> torneos = [];
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _loadTorneos();
  }

  Future<void> _loadTorneos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = "$baseUrl/api/Tournaments/GetAllTournamentsMobile";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        torneos = json["data"] ?? [];
        loading = false;
        error = false;
      } else {
        error = true;
        loading = false;
      }
    } catch (e) {
      error = true;
      loading = false;
    }

    setState(() {});
  }

  List<dynamic> get filtered {
    if (selectedFilter == 0) return torneos;

    String tipo = filtros[selectedFilter].toLowerCase();

    return torneos.where((e) {
      final d = (e["discipline"] ?? "").toString().toLowerCase();
      return d.contains(tipo);
    }).toList();
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
          "Torneos",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00205B),
          ),
        ),
        centerTitle: true,

        // ✅ CAMBIO: quitamos el icono de user y ponemos el botón "Ver historial"
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialTorneosScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00205B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(
                "Ver historial",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00205B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Error cargando torneos"))
          : Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final t = filtered[index];

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
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00205B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00205B)
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  filtros[index],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF00205B),
                  ),
                ),
              ),
            ),
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
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return "${d.day} ${_month(d.month)}.";
    } catch (_) {
      return date;
    }
  }

  String _month(int m) {
    const meses = [
      "",
      "Ene.",
      "Feb.",
      "Mar.",
      "Abr.",
      "May.",
      "Jun.",
      "Jul.",
      "Ago.",
      "Sept.",
      "Oct.",
      "Nov.",
      "Dic."
    ];
    return meses[m];
  }
}
