import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportarScreen extends StatefulWidget {
  final String title;
  final int facilityId;

  const ReportarScreen({
    super.key,
    required this.title,
    required this.facilityId,
  });

  @override
  State<ReportarScreen> createState() => _ReportarScreenState();
}

const String baseUrl = "https://olimpo-production.up.railway.app";


class _ReportarScreenState extends State<ReportarScreen> {
  final TextEditingController descController = TextEditingController();
  bool isLoading = false;

  Future<void> _reportarProblema() async {
    if (descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe escribir una descripción")),
      );
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

      final now = DateTime.now();
      final start = now.toIso8601String().split(".")[0];
      final end = now.add(const Duration(hours: 1))
          .toIso8601String()
          .split(".")[0];

      final body = {
        "id": 0,
        "facilityId": widget.facilityId,
        "description": descController.text,
        "startDate": start,
        "endDate": end,
        "userId": userId,
        "estatusID": 1
      };

      final url = Uri.parse(
        "$baseUrl/api/Maintenance/CreateMaintenance",
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // 👈 JWT
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reporte enviado correctamente")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error enviando el reporte")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins(color: const Color(0xFF00205B))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00205B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Descripción del Problema",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
            const SizedBox(height: 6),

            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe el problema encontrado...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: isLoading ? null : _reportarProblema,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Reportar",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
