import 'dart:convert';
import 'package:begateway_flutter_sdk/src/api/fetch_pay_check.dart';
import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';

import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/utils/storage_servise.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> fetchPayCard(
  AppState appState,
  String token,
  String nameHolder,
  String cardNumber,
  String expiration,
  String cvv,
  bool isSaveCard,
  String saveCardToken,
) async {
  final url = Uri.parse(ApiConstants.paymentUrl);

  final headersData = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '2.1',
    'Authorization': token,
  };

  final paymentData = {
    'request': {
      'customer': {
        'first_name': nameHolder.split(' ')[0],
        'last_name': nameHolder.split(' ')[1],
        'device_id': '363',
      },
      'payment_method': 'credit_card',
      'token': token,
      'credit_card': saveCardToken.isEmpty
          ? {
              'save_card': isSaveCard,
              'holder': nameHolder,
              'number': cardNumber,
              'exp_date': expiration,
              'verification_value': cvv,
            }
          : {'token': saveCardToken},
    },
  };

  try {
    final response = await http.post(url,
        headers: headersData, body: jsonEncode(paymentData));
    String answear = await json.decode(response.body)["response"]["status"];
    
    Map<String, dynamic> answearSend = await json.decode(response.body);
    String? brand =
        await json.decode(response.body)["response"]["credit_card"]["brand"];
    String? lastFourNumbers =
        await json.decode(response.body)["response"]["credit_card"]["last_4"];
    String? saveToken =
        await json.decode(response.body)["response"]["credit_card"]["token"];
    if (answear == 'incomplete') {
      if (saveToken != null && appState.isSaveCard) {
        await addCardToStorage(SaveCardModel(
          brand: brand,
          lastFourNumbers: lastFourNumbers,
          saveToken: saveToken,
        ));
      }
      String urlLink = await json.decode(response.body)["response"]["url"];
      String resultUrl =
          await json.decode(response.body)["response"]["result_url"];
      appState.setUrlLink(urlLink);
      appState.setResultUrl(resultUrl);
      appState.setIsLoading(false);
      appState.setIsShowWebview(true);
      return;
    } else if (answear == 'successful' || answear == 'failed') {
      if (saveToken != null && appState.isSaveCard) {
        await addCardToStorage(SaveCardModel(
          brand: brand,
          lastFourNumbers: lastFourNumbers,
          saveToken: saveToken,
        ));
      }
      fetchPayCheck(appState);
      return;
    } else if (answear == 'error') {
      appState.answearBegateway(answearSend);
      appState.updateIsBegateway(false);
      appState.setIsLoading(false);
      return;
    }
  } catch (e) {
     appState.setIsLoading(false);
    debugPrint('Error: $e');
   
  }
}
