//main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:myapp/dash.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request camera permission
  await Permission.camera.request();

  cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}



class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yolo detection',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 127, 39)),
        useMaterial3: true,
      ),
      home: Dash(cameras: cameras), // Pass the cameras list to the Dash widget
    );
  }
}