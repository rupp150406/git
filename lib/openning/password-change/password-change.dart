import 'package:blogin/widgets/custom%20button/custom_button.dart';
import 'package:flutter/material.dart';
// import 'package:blogin/routes/route.dart  '; // Import routes
import 'package:blogin/openning/password-change/password_changed_popup.dart';
import 'package:blogin/services/local_backend_service.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController(
    text: '********',
  ); // Set initial placeholder
  final _confirmPasswordController = TextEditingController(
    text: '********',
  ); // Set initial placeholder
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to toggle new password visibility
  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  // Method to toggle confirm password visibility
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define consistent text styles
    const String fontFamily =
        'PlusJakartaSans-VariableFont_wght'; // Ensure this font is in pubspec.yaml
    const TextStyle labelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600, // Semi-bold
      color: Colors.black,
    );
    final TextStyle hintStyle = TextStyle(
      // Placeholder style if needed, though we use initial value
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[500],
    );
    final TextStyle bodyTextStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[600],
    );

    // Define common input decoration parts
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // Rounded border like image
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
    );
    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: Colors.black,
        width: 1.5,
      ), // Subtle focus
    );
    final InputBorder errorBorder = OutlineInputBorder(
      // Optional: Define error border
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.red, width: 1.0),
    );

    // Base decoration for password fields
    InputDecoration passwordInputDecoration(
      String label,
      bool obscure,
      VoidCallback toggleVisibility,
    ) {
      return InputDecoration(
        // labelText: label, // Using separate Text widget for label as per design
        // labelStyle: labelStyle, // Style for floating label if used
        hintText: '********', // Use hint if controller text is empty
        hintStyle: hintStyle,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: toggleVisibility,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        border: defaultBorder, // Ensure border is always applied
        errorBorder: errorBorder, // Optional
        focusedErrorBorder: errorBorder, // Optional
        // Ensure no extra padding interferes with custom label placement
        isDense: true,
      );
    }

    // Specific decoration for Confirm Password field
    final InputDecoration confirmPasswordDecoration = passwordInputDecoration(
      'Confirm New Password',
      _obscureConfirmPassword,
      _toggleConfirmPasswordVisibility,
    ).copyWith(
      fillColor: Colors.grey[200], // Light gray background EXACTLY as image
      filled: true,
      enabledBorder: OutlineInputBorder(
        // Ensure border is minimal or non-existent when filled
        borderRadius: BorderRadius.circular(12.0),
        borderSide:
            BorderSide.none, // No border shown for filled field in image
      ),
      focusedBorder: OutlineInputBorder(
        // Maybe a subtle border on focus? Or keep none.
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none, // Keep consistent with enabled state
        // borderSide: const BorderSide(color: Colors.black, width: 1.0), // Alternative if focus border needed
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    );

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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ), // Overall horizontal padding
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20), // Space below AppBar
                  // Headline
                  const Text(
                    'New Password',
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
                    'Create a new password that is safe and easy to remember',
                    style: bodyTextStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 40), // Space before New Password label
                  // New Password Label
                  const Text('New Password', style: labelStyle),
                  const SizedBox(height: 8), // Space between label and input
                  // New Password Input
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: passwordInputDecoration(
                      'New Password',
                      _obscureNewPassword,
                      _toggleNewPasswordVisibility,
                    ),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ), // Added letter spacing for '*' effect
                    onTap: () {
                      if (_newPasswordController.text == '********') {
                        _newPasswordController.clear();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Space before Confirm Password label
                  // Confirm New Password Label
                  const Text('Confirm New Password', style: labelStyle),
                  const SizedBox(height: 8), // Space between label and input
                  // Confirm New Password Input
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration:
                        confirmPasswordDecoration, // Use the specific gray background decoration
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ), // Added letter spacing for '*' effect
                    onTap: () {
                      if (_confirmPasswordController.text == '********') {
                        _confirmPasswordController.clear();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    autovalidateMode:
                        AutovalidateMode
                            .onUserInteraction, // Validate as user types (after first interaction)
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Space before Create Button (adjust as needed based on image)
                  // Create New Password Button
                  SizedBox(
                    width: double.infinity, // Full width
                    child: CustomButton(
                      text: 'Create New Password',
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Save the new password
                          await LocalBackendService.instance.updatePassword(
                            _newPasswordController.text,
                          );
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => const PasswordChangedPopup(),
                          );
                        }
                      },
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
