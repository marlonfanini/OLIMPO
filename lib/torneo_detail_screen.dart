import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TorneoDetailScreen extends StatefulWidget {
  final int id;
  final String name;
  final String discipline;
  final String category;
  final String status;
  final String facility;
  final String supervisor;

  const TorneoDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.discipline,
    required this.category,
    required this.status,
    required this.facility,
    required this.supervisor,
  });

  @override
  State<TorneoDetailScreen> createState() => _TorneoDetailScreenState();
}

const String baseUrl = "https://olimpo-production.up.railway.app";

class _TorneoDetailScreenState extends State<TorneoDetailScreen> {
  Map<String, dynamic>? torneo;
  bool loading = true;

  // Estado del usuario
  bool isRegistered = false;
  int? myParticipantId;


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await loadAndStoreUserProfile();
    await _loadTorneoDetail();
  }


  Future<void> loadAndStoreUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    final token = prefs.getString("token");

    if (userId == null || token == null) return;

    final url = "$baseUrl/api/User/GetUserEdit/$userId";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final name = json["data"]["name"];

      await prefs.setString("userName", name);
    }
  }


  Future<void> _loadTorneoDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString("userName");
      final token = prefs.getString("token");
      final userId = prefs.getInt("userId");

      final url =
          "$baseUrl/api/Tournaments/GetEditMobileDTO?id=${widget.id}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final participantes = json["data"]["participants"] ?? [];
        final encontrado =
        participantes.any((p) => p["name"] == userName);

        if (encontrado) {
          isRegistered = true;
          myParticipantId =
          participantes.firstWhere((p) => p["name"] == userName)["id"];
        }


        setState(() {
          torneo = json["data"];
          loading = false;
        });
      }
    } catch (_) {
      loading = false;
    }
  }

  Future<void> _inscribirme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userId = prefs.getInt("userId");

      if (token == null || userId == null) {
        throw Exception("Sesión no válida");
      }

      final url = "$baseUrl/api/Participants/CreateParticipant";

      final body = {
        "id": 0,
        "userID": userId,
        "tournamentID": widget.id
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Te has inscrito exitosamente")),
        );

        setState(() {
          isRegistered = true;
          loading = true;
        });

        await _loadTorneoDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al inscribirse")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
    }
  }

  Future<void> _cancelarInscripcion() async {
    if (myParticipantId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url =
          "$baseUrl/api/Participants/DeleteParticipant?id=$myParticipantId";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscripción cancelada")),
        );

        setState(() {
          isRegistered = false;
          myParticipantId = null;
        });

        _loadTorneoDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo cancelar la inscripción")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
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
          "Torneos",
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
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final nombre = torneo?["name"] ?? widget.name;
    final disciplina = torneo?["discipline"] ?? widget.discipline;
    final categoria = torneo?["category"] ?? widget.category;
    final estado = torneo?["status"] ?? widget.status;
    final supervisor = torneo?["supervisor"] ?? widget.supervisor;
    final descripcion = torneo?["description"] ?? "Sin descripción";
    final reglas = torneo?["rules"] ?? "";
    final fecha = torneo?["date"];
    final instalacion = torneo?["facility"] ?? widget.facility;
    final participantes = torneo?["participants"] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TITULO =================
          Text(
            nombre,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00205B),
            ),
          ),

          Text(
            disciplina,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 15),

          // ================= INFO PRINCIPAL =================
          Row(
            children: [
              _iconInfo(Icons.shield, categoria, Colors.redAccent),
              const SizedBox(width: 18),
              _iconInfo(Icons.local_fire_department, estado, Colors.redAccent),
              const SizedBox(width: 18),
              _iconInfo(Icons.person, supervisor, Colors.black),
            ],
          ),

          const SizedBox(height: 20),

          if (fecha != null)
            _iconInfo(Icons.calendar_today, _formatDate(fecha), Colors.black),

          const SizedBox(height: 25),

          // ================= DESCRIPCIÓN =================
          Text("Descripción",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(descripcion, style: GoogleFonts.poppins(fontSize: 15)),

          const SizedBox(height: 25),

          // ================= NORMAS =================
          Text("Normas del Torneo",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          if (reglas.isNotEmpty)
            ...reglas.split('\n').map((r) => _rule(r)),

          const SizedBox(height: 25),

          // ================= INSTALACIÓN =================
          Text(
            "Lugar:",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(instalacion, style: GoogleFonts.poppins(fontSize: 16)),

          const SizedBox(height: 25),

          // ================= PARTICIPANTES =================
          Text("Participantes:",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text("${participantes.length} inscritos",
              style: GoogleFonts.poppins()),

          const SizedBox(height: 25),

          Text("Participantes Inscritos",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00205B))),
          const SizedBox(height: 10),

          ...participantes.map<Widget>((p) => _participant(p["name"])),

          const SizedBox(height: 30),

          // ================= BOTÓN DINÁMICO =================
          GestureDetector(
            onTap: isRegistered ? _cancelarInscripcion : _inscribirme,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isRegistered ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  isRegistered ? "Cancelar inscripción" : "Inscribirme",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // HELPERS
  // =======================================================

  Widget _iconInfo(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 14)),
      ],
    );
  }

  Widget _rule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _participant(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(name, style: GoogleFonts.poppins(fontSize: 16)),
    );
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const meses = [
        "",
        "Ene",
        "Feb",
        "Mar",
        "Abr",
        "May",
        "Jun",
        "Jul",
        "Ago",
        "Sep",
        "Oct",
        "Nov",
        "Dic"
      ];
      return "${d.day} ${meses[d.month]} ${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}
