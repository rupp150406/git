// import 'package:blogin/account/sign-up-form/signup_form.dart';
import 'package:blogin/widgets/custom%20button/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:blogin/routes/route.dart'; // Import routes
import 'package:blogin/services/local_backend_service.dart'; // Import LocalBackendService

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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

  @override
  Widget build(BuildContext context) {
    // Define consistent text styles based on the image and previous context
    // IMPORTANT: Ensure 'PlusJakartaSans-VariableFont_wght' is configured in pubspec.yaml
    const String fontFamily = 'PlusJakartaSans-VariableFont_wght';
    const TextStyle labelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600, // Semi-bold appearance
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
    ); // For subtitles and links
    final TextStyle smallLinkStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      color: Colors.grey[700],
    ); // For Forgot Password

    // Define consistent input decoration
    final InputDecoration inputDecoration = InputDecoration(
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12.0,
        ), // Rounded border like the image
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 1.5,
        ), // Subtle focus highlight
      ),
      border: OutlineInputBorder(
        // Ensure border is always defined
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: const BackButton(color: Colors.black),
        // actions: [
        //   IconButton(
        //     padding: const EdgeInsets.only(right: 24),
        //     onPressed: () {
        //       Navigator.pushNamed(context, signUpRoute);
        //     },
        //     icon: const Icon(Icons.person_add_alt_1_outlined),
        //   ),
        // ],
        // No titles
      ),
      body: SafeArea(
        child: LayoutBuilder(
          // Use LayoutBuilder to get constraints for bottom positioning
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                // Ensure Column takes at least screen height
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ), // Consistent horizontal padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        // Top content group
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20), // Space below AppBar
                          // Headline
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 28, // Large size like image
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8), // Spacing like image
                          // Subtitle
                          Text(
                            'Enter your registered account to Sign In',
                            style: bodyTextStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 40,
                          ), // More space before form fields
                          // Email Label
                          const Text('Email', style: labelStyle),
                          const SizedBox(height: 8),

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
                          const SizedBox(height: 20), // Space between fields
                          // Password Label
                          const Text('Password', style: labelStyle),
                          const SizedBox(height: 8),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: inputDecoration.copyWith(
                              hintText: 'Enter your Password..',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons
                                          .visibility_off_outlined // Eye icons like image
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                  size: 20, // Adjust size if needed
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ), // Space before Forgot Password
                          // Forgot Password? Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Navigate using named route
                                Navigator.pushNamed(context, emailInputRoute);
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    EdgeInsets.zero, // Remove default padding
                                minimumSize:
                                    Size.zero, // Remove minimum size constraint
                                tapTargetSize:
                                    MaterialTapTargetSize
                                        .shrinkWrap, // Minimize tap area
                                alignment: Alignment.centerRight,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: smallLinkStyle,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ), // Space before Sign In button
                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              // Use the custom button
                              text: 'Sign In',
                              onPressed: () async {
                                // Get entered credentials
                                final String enteredEmail =
                                    _emailController.text.trim();
                                final String enteredPassword =
                                    _passwordController.text.trim();

                                // Get stored credentials from LocalBackendService
                                final String? storedEmail =
                                    await LocalBackendService.instance
                                        .getEmail();
                                final String? storedPassword =
                                    await LocalBackendService.instance
                                        .getPassword();

                                // Validate credentials against stored data
                                if (enteredEmail == storedEmail &&
                                    enteredPassword == storedPassword) {
                                  // Credentials match, navigate to main page
                                  Navigator.pushReplacementNamed(
                                    context,
                                    mainPageRoute,
                                  );
                                } else {
                                  // Credentials don't match, show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invalid email or password. Please try again.',
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

                      // Moved "Don't have an account?" Link here
                      const SizedBox(
                        height: 30,
                      ), // Space between button and link
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 20.0,
                        ), // Keep padding from bottom edge
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: bodyTextStyle.copyWith(
                                fontSize: 14,
                              ), // Default style for this section
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Don\'t have an account? ',
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    fontFamily: fontFamily,
                                    color: Colors.blue, // Blue color for link
                                    fontWeight:
                                        FontWeight.w600, // Make link semi-bold
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          // Navigate using named route
                                          Navigator.pushReplacementNamed(
                                            context,
                                            signUpRoute,
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
