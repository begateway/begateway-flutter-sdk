import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class CardPaymentButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const CardPaymentButton({super.key, 
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(8),
          // ),
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style:TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorConstants.whiteColor,
          ),
        ),
      ),
    );
  }
}
