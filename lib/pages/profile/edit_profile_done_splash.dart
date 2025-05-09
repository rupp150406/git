import 'dart:async';
import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';

class EditProfileDoneSplashScreen extends StatefulWidget {
  const EditProfileDoneSplashScreen({super.key});

  @override
  State<EditProfileDoneSplashScreen> createState() =>
      _EditProfileDoneSplashScreenState();
}

class _EditProfileDoneSplashScreenState
    extends State<EditProfileDoneSplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Fade-in duration
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );

    // Start the animation
    _animationController!.forward();

    // Navigate after a delay
    Timer(const Duration(seconds: 2), () {
      // Total time on this screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(signUpRoute);
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define text styles consistently
    const String fontFamily = 'PlusJakartaSans-VariableFont_wght';
    const TextStyle titleStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 26, // Estimated size from image
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    final TextStyle subtitleStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14, // Estimated size from image
      color: Colors.grey[600], // Standard subtitle grey
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation!,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Check Icon in Black Circle
              Container(
                width: 90, // Estimated size from image
                height: 90, // Estimated size from image
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 45, // Estimated size from image
                ),
              ),
              const SizedBox(height: 30), // Spacing
              // Title
              const Text(
                'Congrats, it\'s done!',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Spacing
              // Subtitle
              Text(
                'Your Account Has Been Deleted. Thank you for \nusing Blogin.',
                style: subtitleStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
