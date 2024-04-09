import 'package:flutter/material.dart';
import 'package:thesis/widget/step.dart';

import '../assets/svgFiles.dart';

class GasSensorScreen extends StatefulWidget {
  const GasSensorScreen({super.key});

  @override
  State<GasSensorScreen> createState() => _GasSensorScreenState();
}

class _GasSensorScreenState extends State<GasSensorScreen> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);

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
                'Before proceeding with the analysis, it`s essential to place the gas sensor properly',
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
                            ' away from the durian or as shown in the illustration.',
                      )
                    ]),
              ),
              Spacer(),
              TextButton(
                  //TODO: Fetch Aroma Data from ESP and save to Firebase
                  onPressed: () {},
                  child: Text('Ready to Measure')),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
