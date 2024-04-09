import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:thesis/ui/camera.dart';
import 'package:thesis/widget/card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Center(
            child: Text('Durian Ripeness Detection App'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            CardWidget(
                title: 'Open Camera',
                tapped: () {Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CameraScreen()));},
                ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
