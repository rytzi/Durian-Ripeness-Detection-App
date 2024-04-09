import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StepWidget extends StatelessWidget {
  final String svg, step, description;
  final double svgHeight, svgWidth;

  const StepWidget(
      {Key? key,
      required this.svgHeight,
      required this.svgWidth,
      required this.svg,
      required this.step,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: svgHeight,
            width: svgWidth,
            child: SvgPicture.string(svg),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 30),
                children: <TextSpan>[
                  TextSpan(
                      text: step,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: description, style: TextStyle(fontSize: 20))
                ]),
          ),
        ],
      ),
    );
  }
}
