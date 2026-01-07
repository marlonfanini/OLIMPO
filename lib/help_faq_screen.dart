import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  int _tabIndex = 0;

  final List<String> _categories = ["General", "Cuenta", "Servicios"];
  String _selectedCategory = "General";
  String _search = "";

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      category: "Cuenta",
      question: "¿Cómo recupero mi contraseña?",
      answer:
      "En la pantalla de inicio de sesión, pulsa “¿Olvidaste tu contraseña?” y sigue los pasos para restablecerla.",
    ),
    _FaqItem(
      category: "Servicios",
      question: "¿Dónde puedo ver mis reservas de instalaciones?",
      answer:
      "Puedes ver tus reservas desde la sección “Reservas” en el menú principal. Ahí verás el historial y el estado de cada reserva.",
    ),
    _FaqItem(
      category: "Cuenta",
      question: "¿Cómo actualizo mis datos personales?",
      answer:
      "En “Mi Perfil” entra a “Ajustes” y actualiza tus datos. Luego guarda los cambios.",
    ),
    _FaqItem(
      category: "General",
      question: "¿Qué significa OLIMPO?",
      answer:
      "OLIMPO es la plataforma para gestionar eventos deportivos, torneos, reservas de instalaciones y más, desde un solo lugar.",
    ),
  ];

  final List<_ContactItem> _contacts = const [
    _ContactItem(
      title: "Correo Electrónico",
      subtitle: "support@olimpo.com",
      icon: Icons.email,
    ),
    _ContactItem(
      title: "Página Web",
      subtitle: "www.olimpo.com",
      icon: Icons.public,
    ),
    _ContactItem(
      title: "Número de Teléfono",
      subtitle: "+1 (809) 533-1010",
      icon: Icons.phone,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _tabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredFaqs {
    final byCategory =
    _faqs.where((f) => f.category == _selectedCategory).toList();
    if (_search.trim().isEmpty) return byCategory;

    final s = _search.toLowerCase();
    return byCategory
        .where((f) =>
    f.question.toLowerCase().contains(s) ||
        f.answer.toLowerCase().contains(s))
        .toList();
  }

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
          "Ayuda",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: navy,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            Text(
              "¿Cómo Podemos Ayudarte?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: navy,
              ),
            ),
            const SizedBox(height: 14),

            // Tabs tipo “píldora”
            _PillTabs(
              leftText: "Preguntas\nfrecuentes",
              rightText: "Contáctanos",
              selectedIndex: _tabIndex,
              onChanged: (i) {
                setState(() => _tabIndex = i);
                _tabController.animateTo(i);
              },
            ),

            const SizedBox(height: 14),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFaqTab(),
                  _buildContactTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab() {
    const navy = Color(0xFF00205B);

    return Column(
      children: [
        // Chips de categoría (General / Cuenta / Servicios)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _categories.map((c) {
            final selected = c == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => setState(() => _selectedCategory = c),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? navy : const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    c,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : navy,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 14),

        // Barra de búsqueda
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black45, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: "Busca",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black38,
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Lista de FAQs
        Expanded(
          child: ListView.builder(
            itemCount: _filteredFaqs.length,
            itemBuilder: (context, index) {
              final item = _filteredFaqs[index];
              return _FaqTile(
                question: item.question,
                answer: item.answer,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final c = _contacts[index];
        return _ContactTile(
          icon: c.icon,
          title: c.title,
          subtitle: c.subtitle,
        );
      },
    );
  }
}

class _PillTabs extends StatelessWidget {
  final String leftText;
  final String rightText;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PillTabs({
    required this.leftText,
    required this.rightText,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF00205B);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  leftText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == 0 ? Colors.white : navy,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  rightText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == 1 ? Colors.white : navy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF00205B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          iconColor: navy,
          collapsedIconColor: navy,
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: navy,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF00205B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 56, bottom: 10),
          iconColor: navy,
          collapsedIconColor: navy,
          leading: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class _ContactItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ContactItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
