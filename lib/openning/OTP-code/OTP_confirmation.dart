import 'dart:async';
import 'package:blogin/routes/route.dart';
import 'package:blogin/widgets/custom%20button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for InputFormatter

class VerifyCodeConfirmation extends StatefulWidget {
  final String email; // Assuming email is passed to this screen

  const VerifyCodeConfirmation({
    super.key,
    required this.email, // Made email required, removed default
  });

  @override
  State<VerifyCodeConfirmation> createState() => _VerifyCodeConfirmationState();
}

class _VerifyCodeConfirmationState extends State<VerifyCodeConfirmation> {
  // --- Countdown Timer State ---
  Timer? _timer;
  int _remainingSeconds = 300;

  // --- OTP Input State ---
  // Using separate controllers and focus nodes for exact styling control
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  final List<String> _otpValues = List.generate(
    4,
    (index) => "",
  ); // Store entered digits

  // Dummy OTP for validation
  final String _dummyOtp = "2025";

  @override
  void initState() {
    super.initState();
    _startTimer();
    _setupFocusListeners();
    // Request focus on the first box initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNodes[0].requestFocus();
    });
  }

  void _setupFocusListeners() {
    for (int i = 0; i < 4; i++) {
      _otpControllers[i].addListener(() {
        if (mounted) {
          setState(() {
            _otpValues[i] = _otpControllers[i].text;
          });
          // Auto-focus next field
          if (_otpControllers[i].text.length == 1 && i < 3) {
            _otpFocusNodes[i + 1].requestFocus();
          }
          // Optional: Auto-focus previous field on delete (if text becomes empty)
          // else if (_otpControllers[i].text.isEmpty && i > 0) {
          //   _otpFocusNodes[i - 1].requestFocus();
          // }
        }
      });
      _otpFocusNodes[i].addListener(() {
        if (mounted) {
          setState(() {}); // Rebuild for focus visual changes
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        print("Resend code timer finished");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Format seconds into mm:ss
  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    // Define text styles consistently
    const String fontFamily =
        'PlusJakartaSans-VariableFont_wght'; // Ensure configured
    final TextStyle bodyTextStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[600],
    );
    final TextStyle titleStyle = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    final TextStyle otpBoxTextStyle = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ); // Style for digits

    // --- Build OTP Input Boxes ---
    Widget buildOtpInputBoxes() {
      // Define box decoration
      BoxDecoration boxDecoration(int index, bool hasFocus) {
        Color fillColor = Colors.transparent;
        Border border;

        // Specific background for 3rd box when filled (index 2)
        if (index == 2 && _otpValues[index].isNotEmpty) {
          fillColor = Colors.grey[200]!; // Light gray background
          border = Border.all(
            color: Colors.grey[400]!,
            width: 1.0,
          ); // Use border color consistent with filled gray
        } else {
          border = Border.all(color: Colors.grey[400]!, width: 1.0);
        }

        // Add blinking cursor simulation if focused and empty
        // Note: A real TextField handles cursor automatically. Here we simulate.
        // We can use a custom painter or a simple underline for focused empty box.
        // For simplicity, let's just rely on TextField's default cursor for now.

        return BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(
            12.0,
          ), // Rounded corners like image
          border: border,
        );
      }

      List<Widget> boxes = List.generate(4, (index) {
        bool hasFocus = _otpFocusNodes[index].hasFocus;
        return Container(
          width: 60, // Adjust size to match image
          height: 60, // Adjust size to match image
          alignment: Alignment.center,
          decoration: boxDecoration(index, hasFocus),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            style: otpBoxTextStyle,
            // Changed keyboardType and added inputFormatters
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
            ],
            maxLength: 1,
            cursorColor: Colors.black,
            showCursor: hasFocus, // Show cursor when focused
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              // Focus logic moved to listener, keep setState for potential immediate UI updates if needed
              if (mounted) setState(() {});
              // Original logic was in listener, keeping minimal logic here
              if (value.length == 1 && index < 3) {
                FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
              }
              // Add back navigation on delete
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
              }
            },
          ),
        );
      });

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Spacing like image
        children: boxes,
      );
    }

    // --- Main Scaffold Build ---
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        // No title
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Main content is scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ), // Added vertical padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center vertically now?
              children: <Widget>[
                // Headline
                Text('Verify Code', style: titleStyle),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Please enter the code we just send to you email ${widget.email}',
                  style: bodyTextStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 30),
                // OTP Input Boxes
                buildOtpInputBoxes(),
                const SizedBox(height: 20),
                // Countdown Timer
                Center(
                  child: Text(
                    'Recent code in ${_formatDuration(_remainingSeconds)}',
                    style: bodyTextStyle.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 40),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Verify',
                    onPressed: () {
                      // Combine the entered digits
                      String enteredOtp =
                          _otpControllers
                              .map((controller) => controller.text)
                              .join();

                      print('Verify button pressed');
                      print('Entered OTP: $enteredOtp');

                      // Validate against the dummy OTP
                      if (enteredOtp == _dummyOtp) {
                        // OTP is correct, navigate to splash screen
                        print('OTP Correct, navigating to splashRoute');
                        Navigator.pushReplacementNamed(
                          context,
                          newPasswordRoute,
                        ); // Use pushReplacementNamed
                      } else {
                        // OTP is incorrect, show error message
                        print('OTP Incorrect');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Incorrect OTP code. Please try again.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//       ),
//     );
//   }
// }
