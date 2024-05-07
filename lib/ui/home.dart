import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thesis/assets/svgFiles.dart';
import 'package:thesis/ui/sensor.dart';
import 'package:thesis/widget/card.dart';
import 'package:thesis/widget/step.dart';

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
    MediaQueryData queryData = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Center(
          child: Text('Durian Ripeness Detection App'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Spacer(),
            ImageSlideshow(
              width: double.infinity,
              height: queryData.size.height * .70,
              initialPage: 0,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorBackgroundColor: Colors.grey,
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: queryData.size.height * .3,
                        width: queryData.size.height * .3,
                        child: SvgPicture.string(welcomeCat),
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 30),
                            children: <TextSpan>[
                              TextSpan(text: 'Welcome to '),
                              TextSpan(
                                  text: 'Durian Ripeness Detection App!\n\n',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      'This app helps you determine the ripeness of fruits using advanced analysis techniques. Before you begin, please follow these instructions carefully:',
                                  style: TextStyle(fontSize: 20))
                            ]),
                      ),
                    ],
                  ),
                ),
                StepWidget(
                    svgHeight: queryData.size.height * .3,
                    svgWidth: queryData.size.height * .3,
                    svg: durianPosition,
                    step: 'STEP 1: Gas Sensor Placement\n\n',
                    description:
                        'Place the gas sensor near the Durian (2-3cm). For best result place the sensor near the durian`s stalk. Turn on sensor and make sure it is connected to the internet.'),
                StepWidget(
                    svgHeight: queryData.size.height * .3,
                    svgWidth: queryData.size.height * .3,
                    svg: captureSides,
                    step: 'STEP 2: Capture Four Sides of Durian\n\n',
                    description:
                        'Position Durian on a flat surface with good lighting. Use the camera to capture images of all four sides of the fruit. Align each side with the designated section on the screen. Ensure each picture is clear and focused to facilitate accurate analysis.'),
                StepWidget(
                    svgHeight: queryData.size.height * .3,
                    svgWidth: queryData.size.height * .3,
                    svg: dataProcessing,
                    step: 'STEP 3: Analysis Process\n\n',
                    description:
                        'Once the images and gas sensor data are confirmed, the app will begin the analysis process. Our advanced algorithms will assess various aspects of the fruit, including its appearance, color, adn gas/chemical emissions'),
                StepWidget(
                    svgHeight: queryData.size.height * .3,
                    svgWidth: queryData.size.height * .3,
                    svg: viewResult,
                    step: 'STEP 4: Review Results\n\n',
                    description:
                        'After analysis completion, you shall receive detailed results for each aspect, including image CNN, color, and gas analysis results. The final accumulated result will provide an overall assessment of durian`s ripeness, accompanied by an accuracy percentage.'),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: queryData.size.height * .3,
                        width: queryData.size.height * .3,
                        child: SvgPicture.string(playfulCat),
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Ready to Get Started?\n\n',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'Press ',
                              ),
                              TextSpan(
                                  text: '"Get Started"',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      ' below to start. If you have any questions or encounter issues during the process, don`t hesitate to reach out for assistance.\nNote: For optimal results, ensure a stable internet connection and follow the instructions closely. Thank you!')
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            CardWidget(
              cardHeight: queryData.size.height * .1,
              cardWidth: queryData.size.width * .60,
              content: const Text(
                'Get Started',
                style: TextStyle(fontSize: 20),
              ),
              tapped: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GasSensorScreen()));
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
