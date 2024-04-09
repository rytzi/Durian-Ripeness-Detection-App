import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:thesis/ui/result.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<AnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Stack(children: [
          Center(
            child:
                LoadingAnimationWidget.inkDrop(color: Colors.white, size: 100),
          ),
          Column(
            children: [
              Spacer(flex: 3),
              AnimatedTextKit(
                isRepeatingAnimation: false,
                onFinished: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => ResultScreen(),
                    ),
                  );
                },
                animatedTexts: [
                  RotateAnimatedText(
                    'Analyzing Durian Image',
                    textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  RotateAnimatedText(
                    'Analyzing Durian Color',
                    textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  RotateAnimatedText(
                    'Analyzing Durian Aroma',
                    textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ],
              ),
              Spacer(flex: 1)
            ],
          ),
        ]
        )
    );
  }
}
