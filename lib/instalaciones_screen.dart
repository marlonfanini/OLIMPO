import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'instalacion_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstalacionesScreen extends StatefulWidget {
  const InstalacionesScreen({super.key});

  @override
  State<InstalacionesScreen> createState() => _InstalacionesScreenState();
}
const String baseUrl = "https://olimpo-production.up.railway.app";

class _InstalacionesScreenState extends State<InstalacionesScreen> {
  int selectedFilter = 0;

  final List<String> filtros = ["Todo"];

  List<dynamic> instalaciones = [];
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = "$baseUrl/api/Facility/GetAllFacilitiesAsyncMobile";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        instalaciones = json["data"] ?? [];
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
    if (selectedFilter == 0) return instalaciones;

    String tipo = filtros[selectedFilter].toLowerCase();

    return instalaciones.where((e) {
      final t = (e["type"] ?? "").toString().toLowerCase();
      return t.contains(tipo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Instalaciones",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00205B),
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Error cargando instalaciones"))
          : Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: filtered.map((item) {
                return _buildCard(
                  item["name"] ?? "Nombre",
                  item["address"] ?? "Dirección", "50 Minutos",
                  item["status_ID"] == 1 ? "Disponible" : "No Disp.",
                  item["type"] ?? "Tipo",
                  "${item["capacity"] ?? 0} personas",
                  "assets/iconostandar.png",
                  item["id"],
                );
              }).toList(),
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
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00205B) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF00205B) : Colors.grey.shade400,
                ),
              ),
              child: Center(
                child: Text(
                  filtros[index],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
      String title,
      String subtitle,
      String tiempo,
      String estado,
      String tipo,
      String capacidad,
      String img,
      int facilityId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InstalacionDetailScreen(
              title: title,
              subtitle: subtitle,
              tiempo: tiempo,
              estado: estado,
              tipo: tipo,
              capacidad: capacidad,
              img: img,
              facilityId: facilityId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: Image.asset(img, width: 120, height: 100, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF00205B))),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _buildInfo(Icons.timer, tiempo),
                        _buildInfo(Icons.check_circle, estado,
                            color: estado == "Disponible"
                                ? Colors.green
                                : Colors.red),
                        _buildInfo(Icons.apartment, tipo),
                        _buildInfo(Icons.group, capacidad),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text, {Color color = Colors.black54}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }
}
