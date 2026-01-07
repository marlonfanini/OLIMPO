import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  static const String _baseUrl = "https://olimpo-production.up.railway.app";

  bool _loading = true;
  bool _deleting = false;

  int? _userId;
  String? _token;

  List<FavoriteItem> _items = [];

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt("userId");
    _token = prefs.getString("token");

    if (_userId == null || _token == null) {
      setState(() => _loading = false);
      return;
    }

    await _loadFavorites();
  }

  Map<String, String> _headers() {
    final h = <String, String>{"Content-Type": "application/json"};
    if (_token != null && _token!.isNotEmpty) {
      h["Authorization"] = "Bearer $_token";
    }
    return h;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() => _loading = true);

      final url = Uri.parse("$_baseUrl/api/FavoriteFacility/GetFavoriteFacilities/${_userId!}");
      final res = await http.get(url, headers: _headers());

      if (res.statusCode != 200) {
        setState(() {
          _items = [];
          _loading = false;
        });
        _showMessage("No se pudieron cargar los favoritos");
        return;
      }

      final decoded = jsonDecode(res.body);
      final data = (decoded is Map && decoded["data"] is List) ? decoded["data"] as List : [];

      final parsed = data
          .whereType<Map>()
          .map((m) => FavoriteItem.fromMap(m))
          .toList();

      if (!mounted) return;
      setState(() {
        _items = parsed;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
      });
      _showMessage("Error cargando favoritos");
    }
  }

  Future<void> _deleteFavorite(int favoriteId) async {
    if (_deleting) return;

    setState(() => _deleting = true);
    try {
      final url = Uri.parse("$_baseUrl/api/FavoriteFacility/DeleteFavoriteFacility/$favoriteId");
      final res = await http.delete(url, headers: _headers());

      if (res.statusCode == 200) {
        // Remover local y listo (sin recargar)
        _items.removeWhere((x) => x.id == favoriteId);
        if (mounted) setState(() {});
        _showMessage("Eliminado de favoritos");
      } else {
        _showMessage("No se pudo eliminar");
      }
    } catch (_) {
      _showMessage("Error eliminando favorito");
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _confirmDelete(FavoriteItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar favorito"),
        content: Text("¿Quieres quitar \"${item.name}\" de favoritos?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteFavorite(item.id);
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
          "Favoritos",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00205B),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadFavorites,
            icon: const Icon(Icons.refresh, color: Color(0xFF00205B)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_userId == null || _token == null)
          ? Center(
        child: Text(
          "Debes iniciar sesión para ver favoritos",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _items.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                "Aún no tienes favoritos ❤️",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _items.length,
          itemBuilder: (_, i) {
            final item = _items[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.redAccent),
                title: Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00205B),
                  ),
                ),
                subtitle: Text(
                  "FacilityID: ${item.facilityId}",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),
                trailing: IconButton(
                  onPressed: _deleting ? null : () => _confirmDelete(item),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FavoriteItem {
  final int id; // favoriteId
  final String name;
  final int facilityId;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.facilityId,
  });

  factory FavoriteItem.fromMap(Map m) {
    int toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? "") ?? 0;
    }

    return FavoriteItem(
      id: toInt(m["id"]),
      name: (m["name"] ?? "").toString(),
      facilityId: toInt(m["facilityID"] ?? m["facilityId"]),
    );
  }
}
