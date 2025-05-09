import 'package:flutter/material.dart';
import 'package:blogin/routes/route.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF181C2E); // dark blue/gray
    const Color textColor = Colors.white;
    const Color hintColor = Color(0xFFEEEEEE);
    const Color buttonColor = Color(0xFFFFE066);
    const Color buttonTextColor = Colors.black;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // Background layer
          Positioned.fill(child: Container(color: backgroundColor)),
          // Grouping cow image and texts using Positioned and Column
          Positioned(
            top: 0, // Position the top of the Column at the top of the Stack
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Highlight image (sapi.png), positioned with Padding for top offset
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                  ), // Adjust this value to move the image up
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/sapi.png',
                      width: screenWidth * 0.61,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // 404 text
                Text(
                  '404',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                  ),
                ),
                const SizedBox(height: 1),
                // oops! page not found
                Text(
                  'oops! page not found',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                  ),
                ),
                const SizedBox(height: 8),
                // Explanatory text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'perhaps you can try to refresh the pages, sometime it works',
                    style: const TextStyle(
                      color: hintColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'PlusJakartaSans-VariableFont_wght',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Back button at the bottom center
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: Center(
              child: SizedBox(
                width: 130,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, mainPageRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'back',
                    style: TextStyle(
                      color: buttonTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      fontFamily: 'PlusJakartaSans-VariableFont_wght',
                    ),
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
