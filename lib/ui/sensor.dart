import 'package:flutter/material.dart';
import 'package:thesis/ui/camera.dart';

class GasSensorScreen extends StatefulWidget {
  const GasSensorScreen({super.key});

  @override
  State<GasSensorScreen> createState() => _GasSensorScreenState();
}

class _GasSensorScreenState extends State<GasSensorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text('Gas Sensor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              Spacer(),
              Text(
                'To ensure an accurate reading, place the gas sensor properly',
                style: TextStyle(fontSize: 20),
              ),
              Spacer(),
              Image.asset('lib/assets/sensorDistance.png'),
              Spacer(),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    children: <TextSpan>[
                      TextSpan(text: 'Place the gas sensor within '),
                      TextSpan(
                          text: '2-5 centimeters',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text:
                            ' away from the durian or as shown in the illustration.'
                                '\n\nTurn your sensor on and wait for the led to light up,'
                                ' an indication that it had been connected to the internet.'
                                '\n\nAroma Data acquisition will take approx. 1min.'
                                ' Blinking led indicates that data has been acquired.'
                                ' (Sensor can be turned off after).',
                      )
                    ]),
              ),
              Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => CameraScreen(),
                      ),
                    );
                  },
                  child: Text('Proceed')),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
