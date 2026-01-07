import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          "Políticas de Privacidad",
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
            _CardHeader(
              title: "Tu privacidad es importante",
              subtitle:
              "Aquí explicamos qué información recopilamos, cómo la usamos y cómo la protegemos.",
            ),
            const SizedBox(height: 14),

            _Section(
              title: "1. Información que recopilamos",
              body:
              "Podemos recopilar información básica cuando utilizas la aplicación, como tu nombre, correo electrónico, y datos necesarios para operar funciones como reservas, torneos y favoritos. También podemos recopilar información técnica del dispositivo para mejorar el rendimiento (por ejemplo, errores o eventos de la app).",
            ),
            _Section(
              title: "2. Cómo usamos tu información",
              body:
              "Usamos la información para brindarte acceso a tu cuenta, mostrar tu perfil, gestionar reservas y funcionalidades del sistema, personalizar tu experiencia y mejorar la calidad del servicio. No vendemos tu información personal.",
            ),
            _Section(
              title: "3. Compartir información con terceros",
              body:
              "Solo compartimos información cuando es necesario para operar el servicio (por ejemplo, proveedores de infraestructura) o cuando la ley lo requiera. En esos casos, buscamos que se mantengan medidas de seguridad adecuadas.",
            ),
            _Section(
              title: "4. Seguridad de la información",
              body:
              "Aplicamos medidas técnicas y organizativas razonables para proteger tu información. Aun así, ningún sistema es 100% infalible. Te recomendamos no compartir tu contraseña y mantener tu dispositivo protegido.",
            ),
            _Section(
              title: "5. Cookies y tecnologías similares",
              body:
              "En caso de usar WebViews o módulos web, pueden utilizarse cookies o tecnologías similares para mantener la sesión y mejorar el servicio. Esto depende del módulo utilizado y la configuración del sistema.",
            ),
            _Section(
              title: "6. Retención de datos",
              body:
              "Conservamos tu información el tiempo necesario para prestarte el servicio y cumplir con obligaciones legales o administrativas. Puedes solicitar la eliminación o actualización de tus datos cuando aplique.",
            ),
            _Section(
              title: "7. Tus derechos",
              body:
              "Puedes solicitar acceso, corrección o eliminación de tus datos. También puedes retirar permisos (cuando aplique) desde tu dispositivo. Si necesitas ayuda, contáctanos desde la sección de Ayuda.",
            ),
            _Section(
              title: "8. Cambios a esta política",
              body:
              "Podemos actualizar estas políticas ocasionalmente. Si hay cambios importantes, te lo informaremos a través de la app. La fecha de actualización aparecerá reflejada en esta pantalla.",
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
