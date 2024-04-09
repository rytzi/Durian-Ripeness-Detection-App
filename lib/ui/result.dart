import 'package:flutter/material.dart';
import 'package:thesis/ui/home.dart';
import 'package:thesis/widget/card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);

    const int i1 = 50, i2 = 80, a1 = 90, a2 = 30, a3 = 50;

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
                  cardHeight: queryData.size.width * .40,
                  cardWidth: queryData.size.width * .40,
                  content: _results('Image CNN+VGG', 'RIPE', i1, 40.0, 20.0),
                ),
                Spacer(),
                CardWidget(
                  cardHeight: queryData.size.width * .40,
                  cardWidth: queryData.size.width * .40,
                  content: _results('Image Color', 'UNRIPE', i2, 40.0, 20.0),
                ),
                Spacer(),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Spacer(),
                CardWidget(
                  cardHeight: queryData.size.width * .40,
                  cardWidth: queryData.size.width * .40,
                  content: _results('Aroma Ethyl', 'RIPE', a1, 40.0, 20.0),
                ),
                Spacer(),
                CardWidget(
                  cardHeight: queryData.size.width * .40,
                  cardWidth: queryData.size.width * .40,
                  content: _results('Aroma Sulphur', 'RIPE', a2, 40.0, 20.0),
                ),
                Spacer(),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Spacer(),
                CardWidget(
                  cardHeight: queryData.size.width * .40,
                  cardWidth: queryData.size.width * .40,
                  content: _results('Aroma Acid', 'UNRIPE', a3, 40.0, 20.0),
                ),
                Spacer(),
              ],
            ),
            Spacer(),
            CardWidget(
              cardHeight: queryData.size.width * .50,
              cardWidth: queryData.size.width * .50,
              content: _results('Overall', 'RIPE',
                  _overallPrecision(i1, i2, a1, a2, a3).toInt(), 60.0, 30.0),
            ),
            Spacer(),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => Home(),
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
              ? 'precision:\n' + percent.toString() + '%'
              : 'accuracy:\n' + percent.toString() + '%',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize))
    ],
  );
}

double _overallPrecision(i1, i2, a1, a2, a3) {
  return ((i1 * .2) + (i2 * .2) + (a1 * .2) + (a2 * .2) + (a3 * .2));
}
