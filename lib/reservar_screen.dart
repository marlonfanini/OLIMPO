import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservarScreen extends StatefulWidget {
  final String title;
  const ReservarScreen({super.key, required this.title});

  @override
  State<ReservarScreen> createState() => _ReservarScreenState();
}

class _ReservarScreenState extends State<ReservarScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  int selectedHour = -1;

  final List<String> hours = [
    "7:00 AM","8:00 AM","9:00 AM","10:00 AM","11:00 AM",
    "12:00 PM","1:00 PM","2:00 PM","3:00 PM","4:00 PM",
    "5:00 PM","6:00 PM","7:00 PM","8:00 PM","9:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title,
            style: GoogleFonts.poppins(color: const Color(0xFF00205B), fontWeight: FontWeight.bold)),
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
            // 🔹 Calendario
            Text("Calendario",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            const SizedBox(height: 10),

            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.grey),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                weekendStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: GoogleFonts.poppins(fontSize: 13),
                weekendTextStyle: GoogleFonts.poppins(fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Horarios
            Text("Horarios",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(hours.length, (index) {
                final isSelected = selectedHour == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedHour = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00205B) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00205B) : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      hours[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // 🔹 Cantidad Personas
            Text("Cant. Personas",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: "30",
                hintStyle: GoogleFonts.poppins(color: Colors.black45),
                filled: true,
                fillColor: const Color(0xFFEAF4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const Spacer(),

            // 🔹 Botón Reservar
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text("Reservar",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
