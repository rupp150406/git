import 'package:flutter/material.dart';
import 'package:blogin/routes/route.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  const CustomNavBar({super.key, this.selectedIndex = 0});

  static final List<String?> _routes = [
    mainPageRoute,
    searchPageRoute,
    libraryPageRoute,
    profilePageRoute,
  ];

  void _onItemTapped(BuildContext context, int index) {
    final route = _routes[index];
    if (route != null) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Icons.search : Icons.search_outlined,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Icons.bookmark : Icons.bookmark_outline,
              size: 24,
            ),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Icons.person : Icons.person_outline,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
