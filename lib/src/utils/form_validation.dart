import 'package:flutter/material.dart';

import '../localization/find_translation.dart';
import 'brands.dart';

String formValidation(
  String fieldName,
  TextEditingController cardController,
  String lang,
) {
  String result = '';
  switch (fieldName) {
    case 'cardNumber':
      if (cardController.text.isEmpty) {
        return findTranslation(lang, 'begateway_card_number_required');
      } else if (cardController.text.length < 19 || findCardBrand(cardController.text).name == '') {
        return findTranslation(lang, 'begateway_card_number_invalid');
      }
      break;
    case 'expiration':
      if (cardController.text.length == 5) {
        final List<String> parts = cardController.text.split('/');
        final month = int.tryParse(parts[0])!.toInt();
        final year = int.tryParse(parts[1])!.toInt();
        final DateTime now = DateTime.now();
        final int currentMonth = now.month;
        final int lastTwoDigitsOfYear = now.year % 100;

        if (month > 12 || month < 1) {
          return findTranslation(lang, 'begateway_expiration_invalid');
        }
        if (currentMonth > month && year <= lastTwoDigitsOfYear) {
          return findTranslation(lang, 'begateway_expiration_invalid');
        }
        if (year < lastTwoDigitsOfYear) {
          return findTranslation(lang, 'begateway_expiration_invalid');
        }
      } else {
        if (cardController.text.isEmpty) {
          return findTranslation(lang, 'begateway_expiration_required');
        }
        if (cardController.text.length < 5) {
          return findTranslation(lang, 'begateway_expiration_invalid');
        }
      }

      break;
    case 'cvv':
      if (cardController.text.isEmpty) {
        return findTranslation(lang, 'begateway_cvv_required');
      } else if (cardController.text.length < 3) {
        return findTranslation(lang, 'begateway_cvv_invalid');
      }
      break;
    case 'holderName':
      if (cardController.text.isEmpty) {
        return findTranslation(lang, 'begateway_cardholder_name_required');
      } else if (cardController.text.length < 2) {
        return findTranslation(lang, 'begateway_cardholder_name_required');
      }
      break;
  }
  return result;
}
