import 'package:flutter/material.dart';

class StyledBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const StyledBackButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.arrow_back_ios,
        size: 18, // размер иконки
        color: Colors.black, // цвет иконки
      ),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500, // насыщенность шрифта
        ),
      ),
    );
  }
}
