import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:thesis/ui/home.dart';
import 'package:thesis/ui/welcome.dart';

late List<CameraDescription> cameras;

void logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Durian Ripeness Detection App',
      theme: ThemeData(
        fontFamily: 'Georgia',
        primaryColor: const Color(0xFFB1FF96),
        primaryColorDark: const Color(0xFF427624),
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}