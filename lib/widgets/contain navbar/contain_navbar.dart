import 'package:flutter/material.dart';

class ContainNavBar extends StatelessWidget {
  const ContainNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_size, color: Colors.black, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text(
              'B',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
                fontFamily: 'PlusJakartaSans-VariableFont_wght',
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'I',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined, color: Colors.black, size: 28),
            label: '',
          ),
        ],
        currentIndex: 2, // Italic is visually selected (for underline only)
        onTap: (_) {}, // No action for now
      ),
    );
  }
}
