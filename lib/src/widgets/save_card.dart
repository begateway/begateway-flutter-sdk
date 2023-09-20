import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'delete_modal_bottom_sheet.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String link;
  final String buttonText;
  final String token;
  final Color borderColor;
  final VoidCallback onPressed;
  final void Function(String) removeCard;

  const CustomOutlinedButton({
    super.key,
    required this.link,
    required this.buttonText,
    required this.token,
    required this.borderColor,
    required this.onPressed,
    required this.removeCard
  });

  @override
  Widget build(BuildContext context) {
    final String svgAssetPath = 'packages/begateway_flutter_sdk/assets/svg/${link.toUpperCase()}.svg';
    final String cardNumber = '****$buttonText';
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.only(top: 12.0),
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: borderColor),
              backgroundColor: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    svgAssetPath,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                   cardNumber,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.black,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: DeleteModalBottomSheet(
                          svgAsset: svgAssetPath,
                          text: cardNumber,
                          token: token,
                          removeCard: removeCard,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
