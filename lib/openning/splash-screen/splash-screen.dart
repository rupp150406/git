import 'dart:async';
// import 'package:blogin/account/sign-up-form/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom%20button/custom_button.dart'; // Import the custom button
import 'package:blogin/routes/route.dart'; // Import routes
import 'package:blogin/services/local_backend_service.dart';
import 'package:blogin/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSecondStage = false;

  @override
  void initState() {
    super.initState();
    // Show first stage splash screen for 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _checkAuthAndNavigate();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Check if user has a saved auth token
      final token = await LocalBackendService.instance.getToken();

      if (token != null && token.isNotEmpty) {
        // Token exists, try to verify it's still valid by fetching profile
        try {
          await UserService.instance.getProfile();
          // Profile fetch successful, token is valid
          if (mounted) {
            Navigator.pushReplacementNamed(context, mainPageRoute);
            return;
          }
        } catch (e) {
          // Token is invalid or expired, continue to check credentials
          print('Token validation failed: $e');
        }
      }

      // If token validation failed or no token exists,
      // check if we have saved credentials
      final email = await LocalBackendService.instance.getEmail();
      final password = await LocalBackendService.instance.getPassword();

      if (email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        // Try to log in with saved credentials
        try {
          await UserService.instance.login(email: email, password: password);

          // Login successful, navigate to main page
          if (mounted) {
            Navigator.pushReplacementNamed(context, mainPageRoute);
            return;
          }
        } catch (e) {
          // Login with saved credentials failed
          print('Auto-login failed: $e');
        }
      }

      // If we reach here, we need to show the second stage
      if (mounted) {
        setState(() {
          _showSecondStage = true;
        });
      }
    } catch (e) {
      // For any unexpected errors, show the second stage
      print('Authentication check error: $e');
      if (mounted) {
        setState(() {
          _showSecondStage = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Use FadeTransition for smooth cross-fade
          return FadeTransition(opacity: animation, child: child);
        },
        child: _showSecondStage ? _buildSecondStage() : _buildFirstStage(),
      ),
    );
  }

  // Widget for the first stage of the splash screen
  Widget _buildFirstStage() {
    return Container(
      key: const ValueKey('stage1'), // Key for AnimatedSwitcher
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Use Image.asset for the icon, assuming it's black on transparent
            // Image.asset(
            //   'assets/images/splash-icon.png',
            //   height: 100, // Adjust size as needed
            //   // Assuming the icon itself is black. If not, color might be needed.
            // ),
            const SizedBox(height: 10), // Spacing
            const Text(
              'Blogin',
              style: TextStyle(
                fontSize: 48, // Large font size
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'SFPRODISPLAYLIGHTITALIC',
              ),
            ),
            const SizedBox(height: 5), // Spacing
            const Text(
              'Write, Share, Live Your Story.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54, // Slightly lighter color
                fontFamily: 'SFPRODISPLAYLIGHTITALIC',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the second stage of the splash screen
  Widget _buildSecondStage() {
    return Container(
      key: const ValueKey('stage2'), // Key for AnimatedSwitcher
      color: Colors.white, // Background for the bottom part
      child: Column(
        children: <Widget>[
          // Image at the top
          Expanded(
            flex: 5, // Adjust flex factor based on desired image height
            child: ClipRRect(
              // Clip image with rounded corners at the bottom
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              child: Image.asset(
                'assets/images/splash-image.png',
                fit: BoxFit.cover, // Cover the area
                width: double.infinity,
              ),
            ),
          ),
          // Text content and button at the bottom
          Expanded(
            flex: 4, // Adjust flex factor for the bottom content
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Welcome to Blogin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'SFPRODISPLAYLIGHTITALIC',
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Write stories, read inspiration, and find a like-minded community. At Blogin, you can express your ideas, share your experiences, or just read interesting writing from fellow writers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5, // Line spacing
                      fontFamily: 'SFPRODISPLAYLIGHTITALIC',
                    ),
                  ),
                  const Spacer(), // Pushes the button to the bottom
                  SizedBox(
                    // Wrap button in SizedBox for width control
                    width: double.infinity, // Make button take full width
                    child: CustomButton(
                      text: 'Get started',
                      onPressed: () {
                        // Navigate using named route
                        Navigator.pushReplacementNamed(context, signUpRoute);
                      },
                    ),
                  ),
                  const SizedBox(height: 20), // Padding below the button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
