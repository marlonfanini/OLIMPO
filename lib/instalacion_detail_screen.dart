import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:olimpo/reservar_instalation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reportar_screen.dart';

class InstalacionDetailScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String tiempo;
  final String estado;
  final String tipo;
  final String capacidad;
  final String img;
  final int facilityId;

  const InstalacionDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tiempo,
    required this.estado,
    required this.tipo,
    required this.capacidad,
    required this.img,
    required this.facilityId,
  });

  @override
  State<InstalacionDetailScreen> createState() => _InstalacionDetailScreenState();
}

class _InstalacionDetailScreenState extends State<InstalacionDetailScreen> {
  static const String _baseUrl = "https://olimpo-production.up.railway.app";

  int? _userId;
  String? _token;

  bool _isFav = false;
  bool _favLoading = false;

  int? _favoriteId; // ✅ ESTE es el que se usa para DELETE (viene como "id" en el GET)

  @override
  void initState() {
    super.initState();
    _initAuthAndFav();
  }

  Future<void> _initAuthAndFav() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    final token = prefs.getString("token");

    if (!mounted) return;

    setState(() {
      _userId = userId;
      _token = token;
    });

    if (userId != null && token != null) {
      await _loadFavoriteStatus();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Helpers para leer distintos formatos de respuesta ---
  List<dynamic> _extractFavoritesList(dynamic decoded) {
    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      final data = decoded["data"];
      if (data is List) return data;
      if (decoded["favorites"] is List) return decoded["favorites"] as List;
      if (data is Map && data["favorites"] is List) return data["favorites"] as List;
    }
    return [];
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  // ✅ facilityId viene como "facilityID" en tu GET
  int? _getFacilityIdFromItem(Map item) {
    return _toInt(item["facilityId"]) ??
        _toInt(item["facilityID"]) ??
        _toInt(item["FacilityID"]) ??
        _toInt(item["FacilityId"]);
  }

  // ✅ favoriteId viene como "id" en tu GET
  int? _getFavoriteIdFromItem(Map item) {
    return _toInt(item["id"]) ??
        _toInt(item["favoriteId"]) ??
        _toInt(item["favoriteID"]) ??
        _toInt(item["FavoriteID"]);
  }

  Map<String, String> _headers() {
    final h = <String, String>{"Content-Type": "application/json"};
    if (_token != null && _token!.isNotEmpty) {
      h["Authorization"] = "Bearer $_token";
    }
    return h;
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final url = Uri.parse("$_baseUrl/api/FavoriteFacility/GetFavoriteFacilities/${_userId!}");
      final res = await http.get(url, headers: _headers());

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = null;
      }

      final list = _extractFavoritesList(decoded);

      bool found = false;
      int? favId;

      for (final x in list) {
        if (x is Map) {
          final facId = _getFacilityIdFromItem(x);
          if (facId == widget.facilityId) {
            found = true;
            favId = _getFavoriteIdFromItem(x); // ✅ guardamos el favoriteId
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isFav = found;        // ✅ rellena el corazón
        _favoriteId = favId;   // ✅ necesario para DELETE
      });
    } catch (_) {
      // Si falla, no rompas la pantalla
    }
  }

  Future<void> _addFavorite() async {
    final url = Uri.parse("$_baseUrl/api/FavoriteFacility/AddFavoriteFacility").replace(
      queryParameters: {
        "userID": _userId.toString(),
        "facilityID": widget.facilityId.toString(),
      },
    );

    final res = await http.post(url, headers: _headers());

    if (res.statusCode == 200) {
      // ✅ re-consultamos para obtener el favoriteId real (id)
      await _loadFavoriteStatus();
      _showMessage("Añadido a favoritos ❤️");
      return;
    }

    _showMessage("No se pudo agregar a favoritos");
  }

  Future<void> _removeFavorite() async {
    // ✅ El delete necesita el FAVORITE ID (id del registro favorito), no facilityId
    if (_favoriteId == null) {
      await _loadFavoriteStatus(); // por si acaso
      if (_favoriteId == null) {
        _showMessage("No se encontró el id del favorito para eliminar");
        return;
      }
    }

    final url = Uri.parse("$_baseUrl/api/FavoriteFacility/DeleteFavoriteFacility/${_favoriteId!}");
    final res = await http.delete(url, headers: _headers());

    if (res.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        _isFav = false;
        _favoriteId = null;
      });
      _showMessage("Eliminado de favoritos");
      return;
    }

    _showMessage("No se pudo eliminar de favoritos");
  }

  Future<void> _toggleFavorite() async {
    if (_favLoading) return;

    if (_userId == null || _token == null) {
      _showMessage("Debes iniciar sesión para usar favoritos");
      return;
    }

    setState(() => _favLoading = true);
    try {
      if (_isFav) {
        await _removeFavorite();
      } else {
        await _addFavorite();
      }
    } finally {
      if (mounted) setState(() => _favLoading = false);
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00205B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00205B),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _favLoading ? null : _toggleFavorite,
            icon: _favLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? Colors.redAccent : const Color(0xFF00205B),
            ),
            tooltip: _isFav ? "Quitar de favoritos" : "Agregar a favoritos",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 15,
              runSpacing: 8,
              children: [
                _buildInfo(Icons.timer, widget.tiempo),
                _buildInfo(Icons.check_circle, widget.estado, color: Colors.green),
                _buildInfo(Icons.apartment, widget.tipo),
                _buildInfo(Icons.group, widget.capacidad),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.img,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Descripción",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF00205B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${widget.title} está diseñado para prácticas y competencias oficiales.",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservarInstalacionScreen(
                          facilityId: widget.facilityId,
                          title: widget.title,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00205B),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    "Reservar",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportarScreen(
                          title: widget.title,
                          facilityId: widget.facilityId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    "Reportar",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text, {Color color = Colors.redAccent}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}
