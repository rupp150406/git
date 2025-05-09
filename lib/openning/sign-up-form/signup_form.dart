// import 'package:blogin/account/login-form/signin-form.dart';
import 'package:blogin/widgets/custom%20button/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:blogin/routes/route.dart'; // Import routes
import 'package:blogin/services/local_backend_service.dart';

// Custom Animated Checkbox Widget
class CustomAnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final Duration duration;
  final bool showError; // New parameter to indicate error state

  const CustomAnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22.0, // Default size, adjust as needed
    this.duration = const Duration(milliseconds: 200), // Default duration
    this.showError = false, // Default to false
  });

  @override
  State<CustomAnimatedCheckbox> createState() => _CustomAnimatedCheckboxState();
}

class _CustomAnimatedCheckboxState extends State<CustomAnimatedCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.value;
  }

  // Update internal state if the parent widget passes a new value
  @override
  void didUpdateWidget(CustomAnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _isChecked = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine border color based on checked state and error state
    Color borderColor = Colors.grey[400]!; // Default border color
    if (!_isChecked && widget.showError) {
      borderColor = Colors.red; // Error border color
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
          widget.onChanged(_isChecked);
        });
      },
      child: AnimatedContainer(
        duration: widget.duration,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isChecked ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0), // Slightly rounded corners
          border:
              _isChecked
                  ? null
                  : Border.all(
                    color: borderColor, // Use dynamic border color
                    width: 1.5,
                  ),
        ),
        child: AnimatedOpacity(
          duration: widget.duration,
          opacity: _isChecked ? 1.0 : 0.0,
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: widget.size * 0.75, // Adjust icon size relative to container
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false; // Changed default value to false
  bool _showTermsError = false; // New state variable for error

  @override
  void initState() {
    super.initState();
    // Initialize email in LocalBackendService if it doesn't exist
    // Ini sebaiknya dilakukan saat pengguna benar-benar memasukkan email, bukan saat halaman baru dibuat
    // LocalBackendService.instance.setEmail(_emailController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Method to toggle checkbox state
  void _toggleAgreeToTerms(bool? value) {
    if (value != null) {
      setState(() {
        _agreeToTerms = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define consistent text styles - adjust font size and weight as needed
    const String fontFamily = 'PlusJakartaSans-VariableFont_wght';
    const TextStyle labelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600, // Semi-bold
      color: Colors.black,
    );
    final TextStyle hintStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[500],
    );
    final TextStyle bodyTextStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[600],
    );
    final InputDecoration inputDecoration = InputDecoration(
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded border
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 1.5,
        ), // Focus border
      ),
      // Add other decoration properties if needed (e.g., errorBorder)
    );

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // No shadow
          leading: null, // Remove the leading widget (back button)
          automaticallyImplyLeading:
              false, // Prevent Flutter from adding a default back button
        ),
        body: SafeArea(
          // Use SafeArea to avoid overlaps with system UI
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ), // Overall horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20), // Space below AppBar
                  // Headline
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 28, // Large font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ), // Space between headline and subtitle
                  // Subtitle
                  Text(
                    'Join us today and unlock endless possibilities. It\'s quick, easy, and just a step away!',
                    style: bodyTextStyle.copyWith(
                      fontSize: 14,
                    ), // Adjust size if needed
                  ),
                  const SizedBox(height: 30), // Space before Email label
                  // Email Label
                  const Text('Email', style: labelStyle),
                  const SizedBox(height: 8), // Space between label and input
                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Enter your email address..',
                    ),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20), // Space before Password label
                  // Password Label
                  const Text('Password', style: labelStyle),
                  const SizedBox(height: 8), // Space between label and input
                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Enter your Password..',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[500],
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20), // Space before Checkbox row
                  // Terms Checkbox Row
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align items to the top
                    children: <Widget>[
                      // Use the custom checkbox
                      CustomAnimatedCheckbox(
                        value: _agreeToTerms,
                        onChanged: (newValue) {
                          setState(() {
                            _agreeToTerms = newValue;
                            // Reset error state when checkbox is changed
                            if (_showTermsError) {
                              _showTermsError = false;
                            }
                          });
                        },
                        // You can optionally adjust size/duration here:
                        // size: 20.0,
                        // duration: Duration(milliseconds: 150),
                        showError: _showTermsError,
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Adjusted space between checkbox and text
                      Expanded(
                        // Allow text to wrap
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 2.0,
                          ), // Fine-tune text alignment to match checkbox center
                          child: Text(
                            'By Creating an account, you agree to our Terms and Conditions and Privacy Notice.',
                            style: bodyTextStyle.copyWith(
                              fontSize: 12,
                            ), // Smaller text
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Space before Sign Up button
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity, // Full width
                    child: CustomButton(
                      text: 'Sign Up',
                      onPressed: () async {
                        // Get entered credentials
                        final String enteredEmail =
                            _emailController.text.trim();
                        final String enteredPassword =
                            _passwordController.text.trim();

                        // Check if terms are agreed
                        if (!_agreeToTerms) {
                          // Show terms error and do not proceed
                          setState(() {
                            _showTermsError = true;
                          });
                          print('Sign Up button pressed - Terms not agreed');
                          return; // Stop execution here
                        }

                        // Simpan email dan password ke LocalBackendService
                        await LocalBackendService.instance.setEmail(
                          enteredEmail,
                        );
                        await LocalBackendService.instance.updatePassword(
                          enteredPassword,
                        );

                        // Navigate to OTP screen
                        setState(() {
                          _showTermsError = false; // Ensure error is cleared
                        });
                        print(
                          'Sign Up button pressed - Credentials saved, navigating to OTP',
                        );
                        Navigator.pushNamed(
                          context,
                          otpRoute,
                          arguments: enteredEmail,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ), // Space before "Already have an account?" text
                  // "Already have an account?" Link
                  Center(
                    // Center the text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: bodyTextStyle.copyWith(
                          fontSize: 14,
                        ), // Default style
                        children: <TextSpan>[
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign In',
                            style: const TextStyle(
                              fontFamily: fontFamily,
                              color: Colors.blue, // Blue color for link
                              fontWeight: FontWeight.w600, // Semi-bold
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate using named route
                                    Navigator.pushNamed(context, signInRoute);
                                    // print('Sign In link tapped'); // Keep for debug if needed
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // Space at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
