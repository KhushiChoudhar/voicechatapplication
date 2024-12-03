import 'package:flutter/material.dart';
import 'package:voicechatapplication/pallete.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descriptionText;

  const FeatureBox({
    super.key,
    required this.color,
    required this.headerText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(
        horizontal: 35,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 15,
          right: 15, // Added for consistent horizontal padding
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
          children: [
            Text(
              headerText,
              style: const TextStyle(
                fontFamily: 'Schyler',
                color: Pallete.blackColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Add spacing between the header and description
            Padding(
              padding: const EdgeInsets.only(right:20),
              child: Text(
                descriptionText,
                style: const TextStyle(
                  fontFamily: 'Schyler',
                  color: Pallete.blackColor,
                  fontSize: 14, // Adjusted font size for better readability
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
