import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAromaData().then((data) {
      analyzeData(data).then((result) {
        setState(() {
          isLoading = result;
        });
      });
    });
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
        ResultModel.instance.ICAA);
    if (isLoading) {
      return Scaffold(
          backgroundColor: Theme.of(context).primaryColorDark,
          body: Stack(children: [
            Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: Colors.white, size: 100),
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
          ]));
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
                    content: _results(
                        'Image CNN+VGG',
                        ResultModel.instance.CNN ? "RIPE" : "UNRIPE",
                        ResultModel.instance.CNNA,
                        queryData.size.height * .045,
                        queryData.size.height * .02),
                  ),
                  Spacer(),
                  CardWidget(
                    cardHeight: queryData.size.width * .45,
                    cardWidth: queryData.size.width * .45,
                    content: _results(
                        'Image Color Analysis',
                        ResultModel.instance.ICA ? "RIPE" : "UNRIPE",
                        ResultModel.instance.ICAA,
                        queryData.size.height * .045,
                        queryData.size.height * .02),
                  ),
                  Spacer(),
                ],
              ),
              Spacer(),
              CardWidget(
                cardHeight: queryData.size.width * .45,
                cardWidth: queryData.size.width * .45,
                content: _results(
                    'Aroma ANN',
                    ResultModel.instance.ANN ? "RIPE" : "UNRIPE",
                    ResultModel.instance.ANNA,
                    queryData.size.height * .045,
                    queryData.size.height * .025),
              ),
              Spacer(),
              CardWidget(
                cardHeight: queryData.size.width * .6,
                cardWidth: queryData.size.width * .6,
                content: _results(
                    'Overall',
                    overallResults.$1 ? "RIPE" : "UNRIPE",
                    overallResults.$2.toStringAsFixed(2),
                    queryData.size.height * .075,
                    queryData.size.height * .035),
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

double calculateAverageOfArray(numbers) {
  double sum = 0.0;
  for (double number in numbers) {
    sum += number;
  }
  return sum / numbers.length;
}

Future<Object> fetchAromaData() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Durio Aroma Test').get();
    List<Map<String, dynamic>> resultsData =
        snapshot.docs.map((e) => e.data()).toList();
    List<double> aromaValues = [];
    for (int i = 1; i <= 60; i++) {
      aromaValues
          .add(double.parse(resultsData[0]["dataset"]["data $i"]["value"]));
    }
    return aromaValues;
  } catch (e) {
    print('Error fetching data: $e');
    return {};
  }
}

Future<bool> analyzeData(aromaData) async {
  UserInput.instance.setAromaData(aromaData);
  final armInterpreter =
      await Interpreter.fromAsset('lib/assets/ann_model.tflite');
  final imgInterpreter =
      await Interpreter.fromAsset('lib/assets/cnn_model.tflite');
  try {
    bool isReady1 = feedToANNModel(armInterpreter);
    Future<bool> isReady2Future = feedToCNNModel(imgInterpreter);
    Future<bool> isReady3Future = testRipenessByColor();
    var isReady2 = await isReady2Future;
    var isReady3 = await isReady3Future;
    return isReady1 && isReady2 && isReady3;
  } catch (e) {
    print('error: $e');
    return true;
  }
}

bool feedToANNModel(Interpreter interpreter) {
  var input = [UserInput.instance.aromaData];
  var output = [1.0];
  interpreter.run(input, output);
  ResultModel.instance.setIsRipeANN(output[0] >= 50);
  ResultModel.instance.setANNA(
      output[0] <= 100 ? (output[0] >= 50 ? output[0] : 100 - output[0]): 100);
  return false;
}

Future<bool> feedToCNNModel(Interpreter interpreter) async {
  var imagePaths = [
    UserInput.instance.image1.path,
    UserInput.instance.image2.path,
    UserInput.instance.image3.path,
    UserInput.instance.image4.path
  ];
  var ripeAccuracy = [];
  var unripeAccuracy = [];
  for (var i = 0; i < 4; i++) {
    var image = await convertXfiletoTensor4D(imagePaths[i], 1, 100, 100, 3);
    var results = List.filled(1, List.filled(2, 0.0), growable: false);
    print(image.shape);
    print(interpreter.getInputTensors());
    interpreter.run(image, results);
    ripeAccuracy.add(results[0][0]);
    unripeAccuracy.add(results[0][1]);
  }
  print(ripeAccuracy);
  print(unripeAccuracy);
  var ripeAccuracyOverall = calculateAverageOfArray(ripeAccuracy);
  var unripeAccuracyOverall = calculateAverageOfArray(unripeAccuracy);
  if(ripeAccuracyOverall >= unripeAccuracyOverall) {
    ResultModel.instance.setIsRipeCNN(true);
    ResultModel.instance.setCNNA(ripeAccuracyOverall * 100);
  } else {
    ResultModel.instance.setIsRipeCNN(false);
    ResultModel.instance.setCNNA(unripeAccuracyOverall * 100);
  }
  return false;
}

Future<List<List<List<List<int>>>>> convertXfiletoTensor4D(String imagePath, int batch, int height, int width, int imageChannel) async {
  var image = await img.decodeImageFile(imagePath);
  var size = image?.width;
  var startX = 0;
  var startY = (image!.height - size!) ~/ 2;
  var croppedImage = img.copyCrop(image, x: startX, y: startY, height: size, width: size);
  var resizedImage = img.copyResize(croppedImage, width: width, height: height);
  var imageData = resizedImage.toUint8List();

  List<List<List<List<int>>>> result = List.generate(batch, (_) =>
      List.generate(height, (_) =>
          List.generate(width, (_) =>
              List.generate(imageChannel, (_) => 0))));

  int index = 0;
  for (int i = 0; i < batch; i++) {
    for (int j = 0; j < height; j++) {
      for (int k = 0; k < width; k++) {
        for (int l = 0; l < imageChannel; l++) {
          result[i][j][k][l] = imageData[index++];
        }
      }
    }
  }
  return result;
}

Future<bool> testRipenessByColor() async {
  var imagePaths = [
    UserInput.instance.image1.path,
    UserInput.instance.image2.path,
    UserInput.instance.image3.path,
    UserInput.instance.image4.path
  ];
  var ripeAccuracy = [];
  var unripeAccuracy = [];
  var masked = [];
  for (var path in imagePaths) {
    var image = await img.decodeImageFile(path);
    if (image == null) {
      print("image empty");
      continue;
    }
    // var hsv = Cv2.cvtColor(pathString: path, outputType: Cv2.COLOR_RGB2HSV);
    var size = image.width;
    var startX = 0;
    var startY = (image.height - size) ~/ 2;
    var croppedImage = img.copyCrop(image, x: startX, y: startY, height: size, width: size);
    var imageData = croppedImage.getBytes(order: img.ChannelOrder.rgb);
    int brownPixelCount = 0;
    int greenPixelCount = 0;
    for (int j = 0; j < imageData.lengthInBytes; j += 3) {
      int r = imageData[j];
      int g = imageData[j + 1];
      int b = imageData[j + 2];
      if (r >= g &&
          r > b &&
          r >= 10 &&
          r <= 200 &&
          g >= r/4 &&
          g <= (r-(r/4)) &&
          b <= (g-(g/4))) {
        brownPixelCount++;
        imageData[j] = 255;
        imageData[j + 1] = 0;
        imageData[j + 2] = 0;
      } else if (g > r && g > b) {
        greenPixelCount++;
        imageData[j] = 0;
        imageData[j + 1] = 255;
        imageData[j + 2] = 0;
      } else {
        imageData[j] = 0;
        imageData[j + 1] = 0;
        imageData[j + 2] = 0;
      }
    }
    double brownPercentage = brownPixelCount / (brownPixelCount + greenPixelCount);
    double greenPercentage = greenPixelCount / (brownPixelCount + greenPixelCount);
    ripeAccuracy.add(brownPercentage);
    unripeAccuracy.add(greenPercentage);
    masked.add(imageData);
  }
  print(ripeAccuracy);
  print(unripeAccuracy);
  var ripeAccuracyOverall = calculateAverageOfArray(ripeAccuracy);
  var unripeAccuracyOverall = calculateAverageOfArray(unripeAccuracy);
  if(ripeAccuracyOverall >= unripeAccuracyOverall) {
    ResultModel.instance.setIsRipeICA(true);
    ResultModel.instance.setICAA(ripeAccuracyOverall * 100);
  } else {
    ResultModel.instance.setIsRipeICA(false);
    ResultModel.instance.setICAA(unripeAccuracyOverall * 100);
  }
  return false;
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
          title == 'Overall' ? 'precision:\n$percent%' : 'accuracy:\n$percent%',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize)),
      Spacer(),
    ],
  );
}

(bool, double) overallRipeness(CNN, ANN, ICA, CNNA, ANNA, ICAA) {
  bool overallPredictionIsRipe;
  double precision;
  double ripePrecision = ((CNN ? CNNA : 100 - CNNA) +
          (ANN ? ANNA : 100 - ANNA) +
          (ICA ? ICAA : 100 - ICAA)) /
      3;
  overallPredictionIsRipe =
      0 <= ((CNN ? 1 : -1) + (ANN ? 1 : -1) + (ICA ? 1 : -1)) ? true : false;
  if (overallPredictionIsRipe) {
    precision = ripePrecision;
  } else {
    precision = 100 - ripePrecision;
  }
  return (overallPredictionIsRipe, precision);
}
