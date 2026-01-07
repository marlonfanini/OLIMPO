import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00205B), Color(0xFF001437)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 32,
          items: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.grid_view_outlined, 1),
            _buildNavItem(Icons.trending_up_outlined, 2), // 👈 Trend line
            _buildNavItem(Icons.calendar_today_outlined, 3),
            _buildNavItem(Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    final bool isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Transform.translate(
          offset: Offset(0, isSelected ? -12 : 0), // se eleva el ícono
          child: Container(
            decoration: isSelected
                ? BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            )
                : null,
            padding: EdgeInsets.all(isSelected ? 8 : 0),
            child: Icon(
              icon,
              size: 32, // 🔹 todos iguales
              color: isSelected ? Colors.redAccent : Colors.white70,
            ),
          ),
        ),
      ),
      label: "",
    );
  }
}
