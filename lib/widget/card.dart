import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final content, tapped;
  final double cardHeight, cardWidth;

  const CardWidget({
    Key? key,
    this.tapped, required this.cardHeight, required this.cardWidth, this.content
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: cardHeight,
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 10),
              blurRadius: 10,
              spreadRadius: -15,
              color: Colors.black,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: tapped,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
