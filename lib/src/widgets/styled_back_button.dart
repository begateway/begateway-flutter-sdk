import 'package:flutter/material.dart';

class StyledBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const StyledBackButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.arrow_back_ios,
        size: 18, // Adjust the size of the icon
        color: Colors.black, // Icon color
      ),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black, textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500, // You can adjust the font weight here
        ),
      ),
    );
  }
}
