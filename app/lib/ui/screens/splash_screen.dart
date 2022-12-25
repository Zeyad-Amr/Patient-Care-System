import 'package:app/core/services/service.dart';
import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SplashScreenView(
            navigateRoute: const Services(),
            duration: 4000,
            imageSize: 350,
            imageSrc: "assets/logo.png",
            text: 'Smart Hemodialysis',
            textType: TextType.TyperAnimatedText,
            textStyle: const TextStyle(
              fontSize: 30.0,
            ),
            backgroundColor: Colors.white,
          ),
          Positioned(
            bottom: 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Powered by Akwa Mix'),
                Text('Team 15'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
