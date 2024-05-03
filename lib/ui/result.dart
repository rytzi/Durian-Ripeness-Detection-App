import 'package:flutter/material.dart';
import 'package:thesis/helper/result.dart';
import 'package:thesis/ui/home.dart';
import 'package:thesis/widget/card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper/input.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAromaData()
        .then((data) {
      analyzeData(data)
          .then((result) {
        setState(() {
          isLoading = result;
        });
      });
    })
    ;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    var overallResults = overallRipeness(
        ResultModel.instance.CNN,
        ResultModel.instance.ANN,
        ResultModel.instance.ICA,
        ResultModel.instance.CNNA,
        ResultModel.instance.ANNA,
        ResultModel.instance.ICAA
    );
    if (isLoading) {
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
                  repeatForever: true,
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
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColorDark,
          title: const Center(
            child: Text('Durian Ripeness Results'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  CardWidget(
                    cardHeight: queryData.size.width * .45,
                    cardWidth: queryData.size.width * .45,
                    content: _results('Image CNN+VGG',
                        ResultModel.instance.CNN
                            ? "RIPE" : "UNRIPE",
                        ResultModel.instance.CNNA,
                        queryData.size.height * .045, queryData.size.height * .02),
                  ),
                  Spacer(),
                  CardWidget(
                    cardHeight: queryData.size.width * .45,
                    cardWidth: queryData.size.width * .45,
                    content: _results('Image Color Analysis',
                        ResultModel.instance.ICA
                            ? "RIPE" : "UNRIPE",
                        ResultModel.instance.ICAA,
                        queryData.size.height * .045, queryData.size.height * .02),
                  ),
                  Spacer(),
                ],
              ),
              Spacer(),
              CardWidget(
                cardHeight: queryData.size.width * .45,
                cardWidth: queryData.size.width * .45,
                content: _results('Aroma ANN',
                    ResultModel.instance.ANN
                        ? "RIPE" : "UNRIPE",
                    ResultModel.instance.ANNA,
                    queryData.size.height * .045, queryData.size.height * .025),
              ),
              Spacer(),
              CardWidget(
                cardHeight: queryData.size.width * .6,
                cardWidth: queryData.size.width * .6,
                content: _results('Overall',
                    overallResults.$1
                        ? "RIPE" : "UNRIPE",
                    overallResults.$2.toStringAsFixed(2),
                    queryData.size.height * .075, queryData.size.height * .035),
              ),
              Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            Home(),
                      ),
                    );
                  },
                  child: Text('Detect Another'))
            ],
          ),
        ),
      );
    }
  }
}

Future<Object> fetchAromaData() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance
        .collection('Durio Aroma Test')
        .get();
    List<Map<String, dynamic>> resultsData =
    snapshot.docs
        .map((e) => e.data() as Map<String, dynamic>)
        .toList();

    UserInput.instance.setAromaData(resultsData);
    return resultsData;
  } catch (e) {
    print('Error fetching data: $e');
    return {};
  }
}

Future<bool> analyzeData(aromaData) async {
  final interpreter = await Interpreter.fromAsset('lib/assets/ann_model.tflite');
  try {
    List<double> aromaValues = [];
    for (int i = 1; i <= 60; i++) {
      aromaValues.add(double.parse(UserInput.instance.aromaData[0]["dataset"]["data $i"]["value"]));
    }
    print(aromaValues.toString());
    var input = [aromaValues];
    var output = List.filled(1, List.filled(1, 0.0), growable: false);
    interpreter.run(input, output);
    ResultModel.instance.setIsRipeANN(output[0][0] >= 0.5);
    ResultModel.instance.setANNA(output[0][0] >= 0.5 ? output[0][0]*100 : 100-output[0][0]*100);
    return false;
  } catch (e) {
    print('error: $e');
    return true;
  }
}

_results(title, result, percent, resultSize, fontSize) {
  return Column(
    children: [
      Spacer(),
      Text(
        title + ' Results',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      Spacer(),
      Text(
        result,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: result == 'RIPE' ? Colors.green : Colors.red,
            fontSize: resultSize,
            fontWeight: FontWeight.bold),
      ),
      Spacer(),
      Text(
          title == 'Overall'
              ? 'precision:\n$percent%'
              : 'accuracy:\n$percent%',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize)),
      Spacer(),
    ],
  );
}

(bool, double) overallRipeness(CNN, ANN, ICA, CNNA, ANNA, ICAA) {
  bool overallPredictionIsRipe;
  double precision;
  double ripePrecision = ((CNN?CNNA:100-CNNA)+(ANN?ANNA:100-ANNA)+(ICA?ICAA:100-ICAA)) / 3;
  overallPredictionIsRipe = 0 <= ((CNN?1:-1)+(ANN?1:-1)+(ICA?1:-1)) ? true : false;
  if (overallPredictionIsRipe) {
    precision = ripePrecision;
  } else {
    precision = 100 - ripePrecision;
  }
  return (overallPredictionIsRipe, precision);
}