import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';

import 'pay_modal_bottom_sheet.dart';
import 'save_card.dart';

class OutlinedButtonColumn extends StatelessWidget {
  final List<SaveCardModel> savedCards;
  final Function(String) removeCard;
  final BuildContext context;

  const OutlinedButtonColumn({
    super.key,
    required this.savedCards,
    required this.removeCard,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: savedCards.map((saveCard) {
        final brand = saveCard.brand ?? '';
        final lastFour = saveCard.lastFourNumbers ?? '';
        final token = saveCard.saveToken ?? '';
        return CustomOutlinedButton(
          link: brand,
          buttonText: lastFour,
          token: token,
          borderColor: Colors.blue,
          removeCard: removeCard,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              builder: (BuildContext context) {
                return PayModalBottomSheet(
                  link: brand,
                  text: lastFour,
                  token: token,
                );
              },
            );
          },
        );
      }).toList(),
    );
  }
}
