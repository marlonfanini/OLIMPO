import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart'; // ✅ NUEVO

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:olimpo/home_screen.dart';
import 'package:olimpo/login_screen.dart';
import 'package:olimpo/privacy_policy.dart'; // ✅ NUEVO
import 'package:olimpo/terms_condition_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearCuentaScreen extends StatefulWidget {
  const CrearCuentaScreen({super.key});

  @override
  State<CrearCuentaScreen> createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  static const String _baseUrl = "https://olimpo-production.up.railway.app";
  static const String _registerEndpoint = "/api/Auth/Register";

  bool _isValidEmail(String email) {
    final value = email.trim();

    final emailRegex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
    );

    return emailRegex.hasMatch(value);
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

  String _mapBackendErrorToSpanish(String e) {
    final err = e.toUpperCase().trim();

    if (err == "EMAIL_EXISTS") return "Este correo ya está registrado.";

    if (err.startsWith("WEAK_PASSWORD") || err.contains("WEAK_PASSWORD")) {
      return "La contraseña debe tener al menos 6 caracteres.";
    }

    // Fallback
    return e;
  }

  String _extractErrorMessage(dynamic decodedJson) {
    if (decodedJson is Map<String, dynamic>) {
      final errors = decodedJson["errors"];

      if (errors is List && errors.isNotEmpty) {
        final mapped = errors.map((e) => _mapBackendErrorToSpanish("$e")).toList();
        return mapped.join("\n");
      }

      final msg = decodedJson["message"];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }

    return "Ocurrió un error. Intenta de nuevo.";
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    final name = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage("Debe completar todos los campos");
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage("Correo inválido. Ej: example@gmail.com");
      return;
    }

    if (password != confirm) {
      _showMessage("Las contraseñas no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$_baseUrl$_registerEndpoint");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": 0,
          "name": name,
          "email": email,
          "password": password,
          "roleId": 1,
          "estatusID": 1,
        }),
      );

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      // ✅ OK
      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded["success"] == true) {
        final token = decoded["data"]["tokenID"];
        final userId = decoded["data"]["userID"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("userId", userId);
        await prefs.setBool("isLogged", true);

        _showMessage("Cuenta creada ✅");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }

      // ❌ Error (400, etc)
      final msg = _extractErrorMessage(decoded);
      _showMessage(msg);
    } catch (e) {
      _showMessage("Error de conexión con el servidor");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/centro.png", fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    "Crear Cuenta",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00205B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Nombre"),
                        const SizedBox(height: 8),
                        _buildInputField(_nombreController, "Juan Pérez", TextInputType.name),

                        const SizedBox(height: 20),
                        _buildLabel("Correo electrónico"),
                        const SizedBox(height: 8),
                        _buildInputField(_emailController, "correo@ejemplo.com", TextInputType.emailAddress),

                        const SizedBox(height: 20),
                        _buildLabel("Contraseña"),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),

                        const SizedBox(height: 20),
                        _buildLabel("Confirmar Contraseña"),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          onToggle: () =>
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ CAMBIO: "Política de privacidad" ahora navega al screen
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text.rich(
                      TextSpan(
                        text: "Al continuar, aceptas los ",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                        children: [
                          TextSpan(
                            text: "Términos de uso ",
                            style: GoogleFonts.poppins(color: Colors.redAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                                );
                              },
                          ),
                          const TextSpan(text: "y la "),
                          TextSpan(
                            text: "Política de privacidad",
                            style: GoogleFonts.poppins(color: Colors.redAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: GestureDetector(
                        onTap: _isLoading ? null : _handleRegister,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            "Continuar",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "¿Ya tienes cuenta? ",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Inicia sesión",
                            style: GoogleFonts.poppins(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: "********",
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
