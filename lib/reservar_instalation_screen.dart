import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:olimpo/calendario_reservas_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservarInstalacionScreen extends StatefulWidget {
  final int facilityId;
  final String title;

  const ReservarInstalacionScreen({
    super.key,
    required this.facilityId,
    required this.title,
  });

  @override
  State<ReservarInstalacionScreen> createState() =>
      _ReservarInstalacionScreenState();
}
const String baseUrl = "https://olimpo-production.up.railway.app";

class _ReservarInstalacionScreenState
    extends State<ReservarInstalacionScreen> {
  DateTime selectedDay = DateTime.now();
  String? selectedHour;
  bool isLoading = false;

  TextEditingController personasController =
  TextEditingController(text: "30");

  List<String> horas = [
    "7:00 AM",
    "8:00 AM",
    "9:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "1:00 PM",
    "2:00 PM",
    "3:00 PM",
    "4:00 PM",
    "5:00 PM",
    "6:00 PM",
    "7:00 PM",
    "8:00 PM",
    "9:00 PM"
  ];

  // 🔥 Lista de horas ocupadas del día seleccionado
  List<String> horasOcupadas = [];

  @override
  void initState() {
    super.initState();
    cargarReservas();
  }

  Future<void> cargarReservas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse(
        "$baseUrl/api/Reservation/GetAllReservationsFront",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json["data"] ?? [];

        final reservasFacility = data
            .where((r) =>
        r["facilityId"].toString() ==
            widget.facilityId.toString())
            .toList();

        setState(() {
          horasOcupadas = reservasFacility
              .where((r) {
            DateTime fecha = DateTime.parse(r["reservedDates"]);
            return fecha.year == selectedDay.year &&
                fecha.month == selectedDay.month &&
                fecha.day == selectedDay.day;
          })
              .map((r) {
            DateTime d = DateTime.parse(r["reservedDates"]);
            return DateFormat("h:mm a").format(d);
          })
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> enviarReserva() async {
    if (selectedHour == null) {
      _mostrarMensaje("Selecciona un horario antes de reservar.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userId = prefs.getInt("userId");

      if (token == null || userId == null) {
        throw Exception("Sesión no válida");
      }

      // 1) Fecha/hora de inicio seleccionada
      final DateTime start = DateFormat("yyyy-MM-dd h:mm a").parse(
        "${DateFormat('yyyy-MM-dd').format(selectedDay)} $selectedHour",
      );

      // 2) Fecha/hora de fin (50 minutos)
      final DateTime end = start.add(const Duration(minutes: 50));

      // 3) Formato ISO (más confiable)
      final String startIso = start.toIso8601String();
      final String endIso = end.toIso8601String();

      final url = Uri.parse("$baseUrl/api/Reservation/AddReservation");

      final body = {
        "id": 0,
        "userId": userId,
        "facilityId": widget.facilityId,
        "reservedDates": startIso,
        "endReservedDate": endIso,
        "estatusID": 1,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Reservación"),
            content: const Text("Reserva enviada correctamente."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => CalendarioReservasScreen()),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        _mostrarMensaje("No se pudo reservar. Código: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarMensaje("Error enviando la reserva");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          selectedHour = null;
        });
      }
    }
  }

  void _mostrarMensaje(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reservación"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF09243F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reservar Instalación",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF09243F),
          ),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.person, color: Color(0xFF09243F)),
          )
        ],
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF09243F),
              ),
            ),

            const SizedBox(height: 6),

            // ICONOS SUPERIORES
            Row(
              children: [
                _meta(Icons.timer, "50 Minutes"),
                const SizedBox(width: 12),
                _meta(Icons.check_circle, "Disponible"),
                const SizedBox(width: 12),
                _meta(Icons.apartment, "Pabellon"),
                const SizedBox(width: 12),
                _meta(Icons.group, "30 Max."),
              ],
            ),

            const SizedBox(height: 25),

            // CALENDARIO
            Text(
              "Calendario",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF09243F),
              ),
            ),

            const SizedBox(height: 10),
            _calendarRow(),

            const SizedBox(height: 30),

            // HORARIOS
            Text(
              "Horarios",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF09243F),
              ),
            ),

            const SizedBox(height: 10),

            _horariosGrid(),

            const SizedBox(height: 30),

            const SizedBox(height: 20),

            // BOTÓN RESERVAR
            Center(
              child: GestureDetector(
                onTap: isLoading || selectedHour == null
                    ? null
                    : () => enviarReserva(),
                child: Container(
                  width: 200,
                  height: 46,
                  decoration: BoxDecoration(
                    color: selectedHour == null
                        ? const Color(0xFFBFC3C8)
                        : const Color(0xFF00205B),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "Reservar",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // COMPONENTES
  // -----------------------------------------------------

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF09243F),
          ),
        ),
      ],
    );
  }

  // -------------------- CALENDARIO ---------------------
  Widget _calendarRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 MES ACTUAL
        Text(
          DateFormat("MMMM yyyy", "es_ES").format(DateTime.now()).toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09243F),
          ),
        ),
        const SizedBox(height: 8),

        // 🔹 CALENDARIO (7 días desde mañana)
        SizedBox(
          height: 95,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (_, i) {
              DateTime day = DateTime.now().add(Duration(days: i + 1));
              bool active = day.day == selectedDay.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                    selectedHour = null;
                    horasOcupadas.clear();
                  });
                  cargarReservas();
                },
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFDFE2E6) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: active ? const Color(0xFF8F8F8F) : Colors.grey.shade300,
                      width: active ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat("d").format(day),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          color: const Color(0xFF09243F),
                        ),
                      ),
                      Text(
                        DateFormat("EEE", "es_ES").format(day).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ------------------ HORARIOS --------------------
  Widget _horariosGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: horas.map((h) {
        bool esOcupada = horasOcupadas.contains(h);
        bool esActiva = h == selectedHour;

        Color bgColor;
        Color textColor;
        Color borderColor;

        if (esOcupada) {
          bgColor = const Color(0xFFF1F1F1);
          textColor = const Color(0xFF9E9E9E);
          borderColor = Colors.transparent;
        } else if (esActiva) {
          bgColor = const Color(0xFF00205B);
          textColor = Colors.white;
          borderColor = const Color(0xFF00205B);
        } else {
          bgColor = const Color(0xFFE6F2FF);
          textColor = const Color(0xFF09243F);
          borderColor = Colors.transparent;
        }

        return GestureDetector(
          onTap: esOcupada
              ? null
              : () => setState(() => selectedHour = h),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              h,
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
