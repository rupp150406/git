import 'dart:async';
import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';

class SaveProfileDoneSplashScreen extends StatefulWidget {
  const SaveProfileDoneSplashScreen({super.key});

  @override
  State<SaveProfileDoneSplashScreen> createState() =>
      _SaveProfileDoneSplashScreenState();
}

class _SaveProfileDoneSplashScreenState
    extends State<SaveProfileDoneSplashScreen>
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
        Navigator.of(context).pushReplacementNamed(profilePageRoute);
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
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    final TextStyle subtitleStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[600],
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
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 30),
              // Title
              const Text(
                'Profile Updated!',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Your profile has been successfully\nupdated.',
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
