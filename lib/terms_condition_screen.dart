import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF00205B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Términos y Condiciones",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: navy,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(
              title: "Bienvenido/a a Olimpo",
              subtitle:
              "Estos términos y condiciones regulan el uso de la aplicación Olimpo. Al registrarte o utilizar la app, aceptas lo descrito a continuación.",
            ),
            const SizedBox(height: 14),

            const _Section(
              title: "1. Aceptación de los términos",
              body:
              "Al crear una cuenta o utilizar la aplicación, confirmas que has leído y aceptas estos Términos y Condiciones y nuestra Política de Privacidad. Si no estás de acuerdo, debes dejar de usar la aplicación.",
            ),
            const _Section(
              title: "2. Uso de la aplicación",
              body:
              "Olimpo permite gestionar funciones relacionadas con torneos, reservas, instalaciones y otras herramientas deportivas. Te comprometes a usar la app de forma responsable y conforme a la ley, sin afectar a otros usuarios ni a la plataforma.",
            ),
            const _Section(
              title: "3. Cuenta y seguridad",
              body:
              "Eres responsable de mantener la confidencialidad de tu contraseña y de cualquier actividad realizada desde tu cuenta. Si sospechas de un acceso no autorizado, debes notificarlo y cambiar tu contraseña lo antes posible.",
            ),
            const _Section(
              title: "4. Contenido y conducta",
              body:
              "No debes publicar o compartir contenido ofensivo, ilegal, fraudulento o que viole derechos de terceros. Olimpo puede suspender o limitar el acceso en caso de incumplimiento de estas normas.",
            ),
            const _Section(
              title: "5. Inscripciones y cancelaciones",
              body:
              "Las inscripciones a torneos y reservas pueden estar sujetas a disponibilidad y reglas del organizador. En caso de cancelaciones, aplicarán las políticas definidas por el torneo/instalación cuando corresponda.",
            ),
            const _Section(
              title: "6. Disponibilidad del servicio",
              body:
              "Olimpo intenta mantener el servicio disponible, pero puede presentar interrupciones por mantenimiento, actualizaciones o causas externas. No garantizamos disponibilidad ininterrumpida.",
            ),
            const _Section(
              title: "7. Propiedad intelectual",
              body:
              "La marca, diseño, logos, contenido visual y software de Olimpo son propiedad de sus titulares. No está permitido copiar, modificar o distribuir sin autorización.",
            ),
            const _Section(
              title: "8. Limitación de responsabilidad",
              body:
              "Olimpo no se hace responsable por daños indirectos o pérdidas derivadas del uso o imposibilidad de uso de la app. La responsabilidad, si aplica, se limitará a lo permitido por la ley.",
            ),
            const _Section(
              title: "9. Cambios en los términos",
              body:
              "Podemos actualizar estos términos en cualquier momento. Si hay cambios importantes, se notificará dentro de la app. El uso continuo de la app implica aceptación de la versión vigente.",
            ),
            const _Section(
              title: "10. Contacto",
              body:
              "Si tienes dudas sobre estos términos, puedes contactarnos desde la sección de Ayuda en la aplicación.",
            ),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: navy, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Última actualización: 20/12/2025",
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: navy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CardHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF00205B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF00205B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
