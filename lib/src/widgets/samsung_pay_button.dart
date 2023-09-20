import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SamsungPayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SamsungPayButton({super.key, 
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: SvgPicture.asset(
          'packages/begateway_flutter_sdk/assets/svg/samsungpay.svg', // Replace with your SVG image path
        ),
      ),
    );
  }
}
