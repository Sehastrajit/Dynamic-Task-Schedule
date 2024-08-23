//lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/dash.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text('Time Table Generator', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}