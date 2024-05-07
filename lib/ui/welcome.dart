import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:thesis/ui/home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Center(
          child: AnimatedTextKit(
            isRepeatingAnimation: false,
            onFinished: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Home(),
                ),
              );
            },
            animatedTexts: [
              FadeAnimatedText(
                'Welcome! \n Durian Ripeness Detection App',
                textAlign: TextAlign.center,
                textStyle: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        )
    );
  }
}
