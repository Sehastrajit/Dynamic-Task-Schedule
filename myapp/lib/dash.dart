import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:camera/camera.dart';
import 'my_home_page.dart';

class Dash extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Dash({Key? key, required this.cameras}) : super(key: key);

  @override
  DashState createState() => DashState();
}

class DashState extends State<Dash> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: const Color.fromARGB(255, 255, 127, 39),
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/back.jpg"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: MyHomePage(cameras: widget.cameras),
    );
  }
}