import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.black,
    this.fontSize = 20.0,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
