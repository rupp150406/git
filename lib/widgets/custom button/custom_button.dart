import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Add onPressed callback

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed, // Make onPressed optional
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black, // Black background
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ), // Example padding
        shape: RoundedRectangleBorder(
          // Optional: define shape if needed
          borderRadius: BorderRadius.circular(
            30.0,
          ), // Increased border radius for fully rounded ends
        ),
      ),
      onPressed: onPressed, // Use the passed onPressed callback
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, // White text color
          fontSize: 15.2, // Example font size
        ),
      ),
    );
  }
}
