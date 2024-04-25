import 'package:flutter/material.dart';
import 'package:thesis/ui/home.dart';
import 'package:thesis/widget/card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    if (analyzeData()) {
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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Ripeness Result')
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              List<Map<String, dynamic>?>? resultsData = snapshot
                  .data?.docs
                  .map((e) => e.data() as Map<String, dynamic>?)
                  .toList();
              var overallResults = overallRipeness(
                resultsData![0]?["Convolutional Neural Network Analysis"],
                resultsData[0]?["Artificial Neural Network Analysis"],
                resultsData[0]?["Image Color Analysis"],
                resultsData[0]?["CNN Accuracy"],
                resultsData[0]?["ANN Accuracy"],
                resultsData[0]?["ICA Accuracy"],
              );
            return Column(
              children: [
                Spacer(),
                Row(
                  children: [
                    Spacer(),
                    CardWidget(
                      cardHeight: queryData.size.width * .45,
                      cardWidth: queryData.size.width * .45,
                      content: _results('Image CNN+VGG',
                          resultsData[0]?["Convolutional Neural Network Analysis"]
                              ? "RIPE" : "UNRIPE",
                          resultsData[0]?["CNN Accuracy"],
                          queryData.size.height * .045, queryData.size.height * .02),
                    ),
                    Spacer(),
                    CardWidget(
                      cardHeight: queryData.size.width * .45,
                      cardWidth: queryData.size.width * .45,
                      content: _results('Image Color Analysis',
                          resultsData[0]?["Image Color Analysis"]
                              ? "RIPE" : "UNRIPE",
                          resultsData[0]?["ICA Accuracy"],
                          queryData.size.height * .045, queryData.size.height * .02),
                    ),
                    Spacer(),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Spacer(),
                    CardWidget(
                      cardHeight: queryData.size.width * .45,
                      cardWidth: queryData.size.width * .45,
                      content: _results('Aroma ANN',
                          resultsData[0]?["Artificial Neural Network Analysis"]
                              ? "RIPE" : "UNRIPE",
                          resultsData[0]?["ANN Accuracy"],
                          queryData.size.height * .045, queryData.size.height * .025),
                    ),
                    Spacer(),
                  ],
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
            );}
          ),
        ),
      );
    }
  }
}

bool analyzeData() {
  bool analyzeDone = true;
  return !analyzeDone;
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