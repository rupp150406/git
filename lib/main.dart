import 'package:flutter/material.dart';
import 'package:blogin/services/local_backend_service.dart';
import 'package:blogin/services/hive_backend.dart'; // Import the hive_backend.dart file
import 'package:blogin/routes/route.dart' as router; // Import your router

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await LocalBackendService.instance.init(); // Initialize Shared Preferences
  await initializeHiveForBlog(); // Initialize Hive (top-level function)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogin App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: router.splashRoute,
    );
  }
}
