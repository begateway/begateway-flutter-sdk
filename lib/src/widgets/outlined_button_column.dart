import 'package:flutter/material.dart';

import '../models/save_card_model.dart';
import 'pay_modal_bottom_sheet.dart';
import 'save_card.dart';


class OutlinedButtonColumn extends StatelessWidget {
  final List<SaveCardModel> savedCards;
  final Function(String) removeCard;
  final BuildContext context;

  const OutlinedButtonColumn({super.key, 
    required this.savedCards,
    required this.removeCard,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: savedCards.map((saveCard) {
        return CustomOutlinedButton(
          link: saveCard.brand!,
          buttonText: saveCard.lastFourNumbers!,
          token: saveCard.saveToken!,
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
                  link: saveCard.brand!,
                  text: saveCard.lastFourNumbers!,
                  token: saveCard.saveToken!,
                );
              },
            );
          },
        );
      }).toList(),
    );
  }
}
