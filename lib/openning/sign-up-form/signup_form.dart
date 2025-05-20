// import 'package:blogin/account/login-form/signin-form.dart';
import 'package:blogin/widgets/custom%20button/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:blogin/routes/route.dart'; // Import routes
import 'package:blogin/services/user_service.dart';

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
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showTermsError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Method to toggle confirm password visibility
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
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

  Future<void> _handleSignUp() async {
    final String enteredName = _nameController.text.trim();
    final String enteredUsername = _usernameController.text.trim();
    final String enteredEmail = _emailController.text.trim();
    final String enteredPassword = _passwordController.text.trim();
    final String enteredConfirmPassword =
        _confirmPasswordController.text.trim();

    // Validate passwords match
    if (enteredPassword != enteredConfirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if terms are agreed
    if (!_agreeToTerms) {
      setState(() {
        _showTermsError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showTermsError = false;
    });

    try {
      // Register user using UserService
      final response = await UserService.instance.register(
        name: enteredName,
        username: enteredUsername,
        email: enteredEmail,
        password: enteredPassword,
        passwordConfirmation: enteredConfirmPassword,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to next screen
        Navigator.pushNamed(
          context,
          nameFormDoneSplashRoute,
          arguments: enteredEmail,
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define consistent text styles - adjust font size and weight as needed
    const String fontFamily = 'PlusJakartaSans-VariableFont_wght';
    const TextStyle labelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join us today and unlock endless possibilities. It\'s quick, easy, and just a step away!',
                    style: bodyTextStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // Name Field
                  const Text('Full Name', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Enter your full name..',
                    ),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username Field
                  const Text('Username', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Enter your username..',
                    ),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  const Text('Email', style: labelStyle),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 20),

                  // Password Field
                  const Text('Password', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Enter your password..',
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
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  const Text('Confirm Password', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Confirm your password..',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[500],
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms Checkbox Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomAnimatedCheckbox(
                        value: _agreeToTerms,
                        onChanged: (newValue) {
                          setState(() {
                            _agreeToTerms = newValue;
                            if (_showTermsError) {
                              _showTermsError = false;
                            }
                          });
                        },
                        showError: _showTermsError,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'By Creating an account, you agree to our Terms and Conditions and Privacy Notice.',
                            style: bodyTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Sign Up',
                      onPressed: _handleSignUp,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign In Link
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: bodyTextStyle.copyWith(fontSize: 14),
                        children: <TextSpan>[
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign In',
                            style: const TextStyle(
                              fontFamily: fontFamily,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, signInRoute);
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
