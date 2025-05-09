import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final String text;
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback? leftButtonOnPressed;
  final VoidCallback? rightButtonOnPressed;

  const CustomPopup({
    super.key,
    required this.text,
    required this.leftButtonText,
    required this.rightButtonText,
    this.leftButtonOnPressed,
    this.rightButtonOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: leftButtonOnPressed ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      leftButtonText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: rightButtonOnPressed ?? () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      rightButtonText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the popup
Future<bool?> showCustomPopup(
  BuildContext context, {
  required String text,
  required String leftButtonText,
  required String rightButtonText,
  VoidCallback? leftButtonOnPressed,
  VoidCallback? rightButtonOnPressed,
}) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => CustomPopup(
          text: text,
          leftButtonText: leftButtonText,
          rightButtonText: rightButtonText,
          leftButtonOnPressed: leftButtonOnPressed,
          rightButtonOnPressed: rightButtonOnPressed,
        ),
  );
}
