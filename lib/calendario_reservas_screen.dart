import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:olimpo/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarioReservasScreen extends StatefulWidget {
  const CalendarioReservasScreen({super.key});

  @override
  State<CalendarioReservasScreen> createState() =>
      _CalendarioReservasScreenState();
}

const String baseUrl = "https://olimpo-production.up.railway.app";

class _CalendarioReservasScreenState extends State<CalendarioReservasScreen>
    with RouteAware {
  List<dynamic> reservas = [];
  bool loading = true;
  bool updating = false;

  @override
  void initState() {
    super.initState();
    cargarReservas();
  }

  Future<Map<String, dynamic>?> obtenerFacility(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(
      "$baseUrl/api/Facility/GetFacilityByIdAsync?id=$id",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["data"];
      }
    } catch (_) {}

    return null;
  }

  Future<void> eliminarReserva(int reservationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(
      "$baseUrl/api/Reservation/DeleteReservation?reservationId=$reservationId",
    );

    final response = await http.delete(
      url,
      headers: {
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      // ignore: avoid_print
      print("Error al borrar reserva: ${response.body}");
    }
  }

  Future<void> confirmarEliminacion(Map reserva) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar reserva"),
        content: Text(
          "¿Estás seguro de eliminar la reserva #${reserva["id"]}?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo
              await eliminarReserva(reserva["id"]);
              cargarReservas();
              _mostrarMensaje("Reserva eliminada correctamente.");
            },
          ),
        ],
      ),
    );
  }

  Future<void> cargarReservas() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(
      "$baseUrl/api/Reservation/GetAllReservationsFront",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        reservas = json["data"] ?? [];
      } else {
        reservas = [];
      }
    } catch (_) {
      reservas = [];
    }

    setState(() => loading = false);
  }

  void abrirEditor(Map reserva) async {
    DateTime selectedDay = DateTime.parse(reserva["reservedDates"]);
    String originalHour = DateFormat("h:mm a").format(selectedDay);
    String? selectedHour = originalHour;

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
      "9:00 PM",
    ];

    // 🔥 Cargar horas ocupadas para el facility
    List<String> horasOcupadas = [];
    horasOcupadas.add(originalHour);

    try {
      final url = Uri.parse(
        "https://olimpoapi-auhcdrfuapbeg5dc.canadacentral-01.azurewebsites.net/api/Reservation/GetAllReservationsFront",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final List data = json["data"] ?? [];

        final reservasFacility =
        data.where((r) => r["facilityId"] == reserva["facilityId"]).toList();

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
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Modificar Reservación",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00205B),
                  ),
                ),
                const SizedBox(height: 20),

                // ----------------- CALENDARIO -----------------
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (_, i) {
                      final d = DateTime.now().add(Duration(days: i));
                      bool activo = d.day == selectedDay.day;

                      return GestureDetector(
                        onTap: () async {
                          setModal(() {
                            selectedDay = d;
                            selectedHour = null;
                          });

                          // Recarga horas ocupadas
                          horasOcupadas.clear();

                          final response2 = await http.get(
                            Uri.parse(
                              "https://olimpoapi-auhcdrfuapbeg5dc.canadacentral-01.azurewebsites.net/api/Reservation/GetAllReservationsFront",
                            ),
                          );

                          if (response2.statusCode == 200) {
                            final json = jsonDecode(response2.body);

                            final List all = json["data"] ?? [];

                            final reservasFacility = all
                                .where((r) =>
                            r["facilityId"] == reserva["facilityId"])
                                .toList();

                            setModal(() {
                              horasOcupadas = reservasFacility
                                  .where((r) {
                                DateTime f =
                                DateTime.parse(r["reservedDates"]);
                                return f.year == d.year &&
                                    f.month == d.month &&
                                    f.day == d.day;
                              })
                                  .map((r) {
                                DateTime f =
                                DateTime.parse(r["reservedDates"]);
                                return DateFormat("h:mm a").format(f);
                              })
                                  .toList();
                            });
                          }
                        },
                        child: Container(
                          width: 65,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: activo
                                ? const Color(0xFFDFE2E6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: activo
                                  ? const Color(0xFF8F8F8F)
                                  : Colors.grey.shade300,
                              width: activo ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${d.day}",
                                style: GoogleFonts.poppins(
                                  fontWeight: activo
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 18,
                                  color: const Color(0xFF09243F),
                                ),
                              ),
                              Text(
                                DateFormat("EEE", "es_ES")
                                    .format(d)
                                    .toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "Nuevo horario",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF09243F),
                  ),
                ),

                const SizedBox(height: 10),

                // ----------------- HORARIOS -----------------
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: horas.map((h) {
                    final esOcupada = horasOcupadas.contains(h);
                    final esActiva = h == selectedHour;

                    Color bg;
                    Color txt;

                    if (esOcupada) {
                      bg = const Color(0xFFF1F1F1);
                      txt = const Color(0xFF9E9E9E);
                    } else if (esActiva) {
                      bg = const Color(0xFF00205B);
                      txt = Colors.white;
                    } else {
                      bg = const Color(0xFFE6F2FF);
                      txt = const Color(0xFF09243F);
                    }

                    return GestureDetector(
                      onTap: esOcupada ? null : () => setModal(() => selectedHour = h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          h,
                          style: GoogleFonts.poppins(
                            color: txt,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(),

                // ----------------- GUARDAR -----------------
                ElevatedButton(
                  onPressed: selectedHour == null
                      ? null
                      : () async {
                    final nuevaFecha =
                    DateFormat("yyyy-MM-dd h:mm a").parse(
                      "${DateFormat('yyyy-MM-dd').format(selectedDay)} $selectedHour",
                    );

                    Navigator.pop(context);

                    await eliminarReserva(reserva["id"]);
                    await actualizarReserva(reserva, nuevaFecha);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00205B),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Guardar cambios",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> actualizarReserva(Map reserva, DateTime nuevaFecha) async {
    setState(() => updating = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(
      "$baseUrl/api/Reservation/UpdateReservation",
    );

    final String fechaIso = DateFormat("yyyy-MM-ddTHH:mm:00").format(nuevaFecha);

    final body = {
      "id": 0,
      "userId": reserva["userId"],
      "facilityId": reserva["facilityId"],
      "reservedDates": fechaIso,
      "estatusID": 1,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    setState(() => updating = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _mostrarMensaje("Reservación actualizada.");
      cargarReservas();
    } else {
      _mostrarMensaje("Error: ${response.body}");
    }
  }

  void _mostrarMensaje(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reservas"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00205B)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
        ),
        title: Text(
          "Mis Reservaciones",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00205B),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF00205B)),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: reservas.isEmpty
                  ? Center(
                child: Text(
                  "No tienes reservaciones por el momento",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (_, i) {
                  final r = reservas[i];
                  final fecha = DateTime.parse(r["reservedDates"]);
                  final fechaTexto = DateFormat(
                    "dd MMM yyyy – h:mm a",
                  ).format(fecha);

                  return FutureBuilder(
                    future: obtenerFacility(r["facilityId"]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text("Cargando reservas..."),
                        );
                      }

                      final fac = snapshot.data!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/bannermiderec.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            fac["name"] ?? "",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF09243F),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_forever_rounded,
                                            color: Colors.redAccent,
                                            size: 26,
                                          ),
                                          onPressed: () => confirmarEliminacion(r),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      fac["type"] ?? "",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_pin,
                                            size: 14, color: Colors.grey.shade700),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            fac["address"] ?? "",
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(color: Colors.grey.shade300),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month_rounded,
                                            size: 18, color: Color(0xFF00205B)),
                                        const SizedBox(width: 6),
                                        Text(
                                          fechaTexto,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF00205B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.group_rounded,
                                            size: 18, color: Color(0xFF00205B)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Capacidad: ${fac["capacity"]}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF00205B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => abrirEditor(r),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00205B),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          "Modificar Reservación",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
