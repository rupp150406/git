import 'package:flutter/material.dart';
import 'package:blogin/routes/route.dart';
import 'package:blogin/widgets/loading/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload the video in background
  VideoLoader().getController();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'PlusJakartaSans-VariableFont_wght',
      ),
      initialRoute: splashRoute,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
    );
  }
}
