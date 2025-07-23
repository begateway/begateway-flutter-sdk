import 'dart:convert';

import 'package:begateway_flutter_sdk/src/api/fetch_pay_card.dart';
import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:flutter/material.dart';

Future<void> fetchPayWithToken(
  AppState appState,
  String cardNumber,
  String expiration,
  String cvv,
  String nameHolder,
) async {
  final url = Uri.parse(ApiConstants.checkoutUrl);
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '2.1',
    'Authorization': appState.publicKey!,
  };

  final requestData = {
    'checkout': {
      'test': appState.test,
      'transaction_type': appState.transactionType,
      'attempts': 3,
      'settings': {
        'save_card_toggle': {
          'customer_contract': appState.customerContract,
        },
        'auto_return': 0,
        'button_text': appState.buttonText,
        'language': appState.language,
        'customer_fields': {
          'visible': ['first_name', 'last_name'],
          'read_only': ['email'],
        },
        'credit_card_fields': {
          'holder': appState.holder,
          'read_only': ['holder'],
        },
      },
      'order': {
        'currency': appState.currency,
        'amount': appState.amount,
        'description': appState.description,
        'additional_data': {
          //'receipt_text': props.receipt_text,
          'contract': ['oneclick'],
        },
      },
      // 'card_on_file': {
      //   'initiator': props.initiator,
      //   'type': props.type,
      // },
      'customer': {
        'address': 'Baker street 221b',
        'country': appState.customerCountry,
        'city': 'London',
        'email': appState.customerEmail,
      },
    },
    // Add other data fields as needed
  };
  try {
    appState.setIsLoading(true);
    final response =
        await http.post(url, headers: headers, body: jsonEncode(requestData));
    Map<String, dynamic> answearSend = await json.decode(response.body);
    if (response.statusCode == 201) {
      // Successful request
      String token = await json.decode(response.body)["checkout"]["token"];
      appState.setToken(token);
      await fetchPayCard(appState, token, nameHolder, cardNumber, expiration,
          cvv, appState.isSaveCard, appState.saveCardToken);

      //debugPrint('Response data: $pay');
      //appState.setIsLoading(false);
    } else {
      // Unsuccessful request
      appState.answearBegateway(answearSend);
      appState.updateIsBegateway(false);

      appState.setIsLoading(false);
    }
  } catch (e) {
    // Error Handling
    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
}
